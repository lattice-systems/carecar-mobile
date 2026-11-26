import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/cambio_de_correo_pendiente.dart';
import '../dominio/correo.dart';
import '../dominio/fallos_acceso.dart';
import 'proveedores_acceso.dart';

/// Cambiar el correo del cliente, en dos pasos · V2-M01.07.
///
/// **El correo no cambia hasta confirmar.** El primer paso solo manda un
/// código al correo nuevo; guardarlo antes dejaría al cliente con uno que no
/// ha probado que es suyo y, como con el correo se entra a la app, sin poder
/// entrar.
///
/// Pide la contraseña actual por lo mismo: sin eso, alguien con el celular
/// desbloqueado podría cambiar el correo al suyo y quedarse con la cuenta.
///
/// **Los tres errores se ven distintos**, y es el punto más delicado de la
/// pantalla: la contraseña equivocada y el correo mal escrito llegan los dos
/// como 400 del servidor. Confundirlos le diría a la persona que corrija lo
/// que estaba bien.
///
/// El teléfono no se edita aquí: verificarlo exige mandar un código por SMS y
/// todavía no hay con qué.
class PantallaCambiarCorreo extends ConsumerStatefulWidget {
  const PantallaCambiarCorreo({super.key});

  static const campoCorreo = Key('cambiar_correo_campo_correo');
  static const campoContrasena = Key('cambiar_correo_campo_contrasena');
  static const campoCodigo = Key('cambiar_correo_campo_codigo');
  static const botonEnviar = Key('cambiar_correo_boton_enviar');
  static const botonConfirmar = Key('cambiar_correo_boton_confirmar');

  @override
  ConsumerState<PantallaCambiarCorreo> createState() =>
      _EstadoPantallaCambiarCorreo();
}

class _EstadoPantallaCambiarCorreo
    extends ConsumerState<PantallaCambiarCorreo> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _codigo = TextEditingController();

  /// Null mientras no se ha pedido el cambio: es lo que separa los dos pasos.
  CambioDeCorreoPendiente? _pendiente;
  String _correoPedido = '';
  bool _listo = false;

  bool _trabajando = false;
  String? _errorCorreo;
  String? _errorContrasena;
  String? _errorCodigo;

  /// Lo que no es culpa de un campo: sin conexión, el servidor, el correo en
  /// uso. Va arriba, en un aviso.
  String? _avisoTitulo;
  String? _avisoMensaje;
  Tono _avisoTono = Tono.peligro;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _codigo.dispose();
    super.dispose();
  }

  void _limpiarAviso() {
    _avisoTitulo = null;
    _avisoMensaje = null;
  }

  Future<void> _pedir() async {
    if (_trabajando) return;
    final textos = AppLocalizations.of(context);
    final correo = _correo.text.trim();

    // Se valida aquí para no gastar un viaje ni hacer que el servidor nos
    // enseñe lo que ya sabemos.
    setState(() {
      _limpiarAviso();
      _errorCorreo = pareceCorreo(correo)
          ? null
          : textos.accesoCambiarCorreoCorreoInvalido;
      _errorContrasena = _contrasena.text.isEmpty
          ? textos.accesoCambiarCorreoContrasenaFalta
          : null;
    });
    if (_errorCorreo != null || _errorContrasena != null) return;

    setState(() => _trabajando = true);
    try {
      final pendiente = await ref
          .read(repositorioAccesoProvider)
          .pedirCambioDeCorreo(
            correo: correo,
            contrasenaActual: _contrasena.text,
          );
      if (!mounted) return;
      setState(() {
        _pendiente = pendiente;
        _correoPedido = correo;
        _codigo.clear();
        _trabajando = false;
      });
    } on ContrasenaNoCoincide {
      // Al campo, no al aviso de arriba: es lo que la persona tiene que
      // corregir, y culpar al correo la haría cambiar lo que estaba bien.
      if (!mounted) return;
      setState(() {
        _errorContrasena = textos.accesoCambiarCorreoContrasenaNoCoincide;
        _trabajando = false;
      });
    } on CorreoEnUso {
      if (!mounted) return;
      setState(() {
        _errorCorreo = textos.accesoCambiarCorreoCorreoEnUso;
        _trabajando = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _mostrarFallo(error, textos);
        _trabajando = false;
      });
    }
  }

  Future<void> _confirmar() async {
    if (_trabajando) return;
    final textos = AppLocalizations.of(context);
    final pendiente = _pendiente;
    if (pendiente == null) return;

    final codigo = _codigo.text.trim();
    setState(() {
      _limpiarAviso();
      _errorCodigo = codigo.length == 6
          ? null
          : textos.accesoCambiarCorreoCodigoCorto;
    });
    if (_errorCodigo != null) return;

    // Si ya pasaron los 15 minutos no se gasta un viaje condenado: se ofrece
    // pedir otro antes de que escriba seis dígitos para nada.
    if (pendiente.yaVencio(DateTime.now())) {
      setState(() {
        _avisoTono = Tono.advertencia;
        _avisoTitulo = textos.accesoCambiarCorreoVencio;
        _avisoMensaje = textos.accesoCambiarCorreoPedirOtro;
        _pendiente = null;
      });
      return;
    }

    setState(() => _trabajando = true);
    try {
      await ref
          .read(repositorioAccesoProvider)
          .confirmarCambioDeCorreo(id: pendiente.id, codigo: codigo);
      if (!mounted) return;
      // El perfil cambió: quien lo esté mostrando tiene que volver a pedirlo.
      ref.invalidate(perfilProvider);
      setState(() {
        _listo = true;
        _trabajando = false;
      });
    } on CodigoNoValido {
      if (!mounted) return;
      setState(() {
        _errorCodigo = textos.accesoCambiarCorreoCodigoInvalido;
        _trabajando = false;
      });
    } on CorreoEnUso {
      if (!mounted) return;
      setState(() {
        _avisoTono = Tono.peligro;
        _avisoMensaje = textos.accesoCambiarCorreoCorreoEnUso;
        _pendiente = null;
        _trabajando = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _mostrarFallo(error, textos);
        _trabajando = false;
      });
    }
  }

  void _mostrarFallo(Object error, AppLocalizations textos) {
    final fallo = falloDe(error);
    // Sin conexión es una espera, no algo que la persona pueda corregir aquí.
    _avisoTono = fallo.esSinConexion ? Tono.advertencia : Tono.peligro;
    _avisoTitulo = fallo.esSinConexion
        ? textos.accesoSinConexionTitulo
        : textos.accesoCambiarCorreoFalloTitulo;
    _avisoMensaje = fallo.mensaje;
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final enElCodigo = _pendiente != null && !_listo;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: CentradoDesplazable(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    textos.accesoCambiarCorreoTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    _listo
                        ? textos.accesoCambiarCorreoListoMensaje(_correoPedido)
                        : enElCodigo
                        ? textos.accesoCambiarCorreoPasoDosExplicacion(
                            _correoPedido,
                          )
                        : textos.accesoCambiarCorreoExplicacion,
                    style: tokens.tipografia.cuerpo.copyWith(
                      color: tokens.colores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e6),
                  if (_listo) ...[
                    Aviso(
                      tono: Tono.exito,
                      titulo: textos.accesoCambiarCorreoListoTitulo,
                      mensaje: textos.accesoCambiarCorreoListoMensaje(
                        _correoPedido,
                      ),
                    ),
                  ] else ...[
                    if (_avisoMensaje != null) ...[
                      Aviso(
                        tono: _avisoTono,
                        titulo: _avisoTitulo,
                        mensaje: _avisoMensaje!,
                      ),
                      const SizedBox(height: Espaciado.e4),
                    ],
                    if (enElCodigo) ...[
                      CampoTexto(
                        key: PantallaCambiarCorreo.campoCodigo,
                        etiqueta: textos.accesoCambiarCorreoCodigoEtiqueta,
                        controlador: _codigo,
                        error: _errorCodigo,
                        habilitado: !_trabajando,
                        teclado: TextInputType.number,
                        accionTeclado: TextInputAction.done,
                        alEnviar: _trabajando ? null : (_) => _confirmar(),
                      ),
                      const SizedBox(height: Espaciado.e6),
                      Boton(
                        key: PantallaCambiarCorreo.botonConfirmar,
                        texto: _trabajando
                            ? textos.accesoCambiarCorreoConfirmando
                            : textos.accesoCambiarCorreoConfirmar,
                        alPresionar: _trabajando ? null : _confirmar,
                        cargando: _trabajando,
                        anchoCompleto: true,
                      ),
                    ] else ...[
                      CampoTexto(
                        key: PantallaCambiarCorreo.campoCorreo,
                        etiqueta: textos.accesoCambiarCorreoCorreoEtiqueta,
                        controlador: _correo,
                        error: _errorCorreo,
                        habilitado: !_trabajando,
                        teclado: TextInputType.emailAddress,
                        pistasAutocompletar: const [AutofillHints.email],
                      ),
                      const SizedBox(height: Espaciado.e4),
                      CampoTexto(
                        key: PantallaCambiarCorreo.campoContrasena,
                        etiqueta: textos.accesoCambiarCorreoContrasenaEtiqueta,
                        controlador: _contrasena,
                        error: _errorContrasena,
                        habilitado: !_trabajando,
                        ocultarTexto: true,
                        accionTeclado: TextInputAction.done,
                        alEnviar: _trabajando ? null : (_) => _pedir(),
                      ),
                      const SizedBox(height: Espaciado.e2),
                      Text(
                        textos.accesoCambiarCorreoContrasenaPista,
                        style: tokens.tipografia.cuerpoChico.copyWith(
                          color: tokens.colores.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: Espaciado.e6),
                      Boton(
                        key: PantallaCambiarCorreo.botonEnviar,
                        texto: _trabajando
                            ? textos.accesoCambiarCorreoEnviando
                            : textos.accesoCambiarCorreoEnviar,
                        alPresionar: _trabajando ? null : _pedir,
                        cargando: _trabajando,
                        anchoCompleto: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
