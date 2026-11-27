import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/conexion/senal_de_conexion.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../dominio/reglas_contrasena.dart';
import 'pantalla_cambiar_contrasena.dart' show ListaDeReglas;
import 'proveedores_acceso.dart';

/// Cambiar mi contrasena cuando yo quiera · V2-M01.10.
///
/// No se confunde con `PantallaCambiarContrasena`, que es el cambio
/// **obligatorio** de la temporal (V2-M01.03) y a proposito no tiene salida.
/// Esta se abre desde Ajustes, se puede abandonar y agrega lo unico que el
/// criterio pide de mas: cerrar las demas sesiones, **opcionalmente**.
///
/// ## Por que la casilla dice «todos» y no «los demas»
///
/// El criterio habla de cerrar «las demas» sesiones, pero el contrato solo
/// tiene `DELETE /sesiones`, que cierra **todas, incluida la de quien llama**,
/// y hoy no hay manera de saber cual de la lista es este celular: eso espera
/// el claim `sid` en el JWT, que es de otra persona del equipo. Dejar de
/// ofrecerlo seria peor -quien cambia su contrasena porque sospecha que
/// alguien entro necesita justo esto- y fingir que solo cierra las otras
/// seria mentir. Asi que la casilla lo dice tal cual y, al terminar, la app
/// suelta su propia sesion: el access token en curso sigue valiendo hasta que
/// expire, asi que si se quedara dentro el cliente creeria que no se cerro
/// nada.
class PantallaMiContrasena extends ConsumerStatefulWidget {
  const PantallaMiContrasena({super.key});

  static const campoActual = Key('mi_contrasena_actual');
  static const campoNueva = Key('mi_contrasena_nueva');
  static const campoConfirmar = Key('mi_contrasena_confirmar');
  static const casillaCerrarOtras = Key('mi_contrasena_cerrar_otras');
  static const botonGuardar = Key('mi_contrasena_guardar');
  static const explicacionSinRed = Key('mi_contrasena_sin_red');
  static const avisoDeError = Key('mi_contrasena_aviso_error');

  @override
  ConsumerState<PantallaMiContrasena> createState() =>
      _EstadoPantallaMiContrasena();
}

class _EstadoPantallaMiContrasena extends ConsumerState<PantallaMiContrasena> {
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  bool _cerrarTodas = false;
  bool _guardando = false;
  bool _listo = false;
  Fallo? _fallo;
  String? _errorConfirmar;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  RevisionContrasena get _revision => ReglasContrasena.revisar(
    _nueva.text,
    actual: _actual.text.isEmpty ? null : _actual.text,
  );

  bool get _puedeGuardar => !_guardando && !_listo;

  Future<void> _guardar() async {
    if (!_puedeGuardar) return;
    final textos = AppLocalizations.of(context);

    final coinciden = _nueva.text == _confirmar.text;
    setState(
      () => _errorConfirmar = coinciden ? null : textos.accesoCambiarNoCoincide,
    );

    // No se le pide al servidor lo que ya sabemos que va a rechazar.
    if (!_revision.cumpleTodo || !coinciden) return;

    setState(() {
      _guardando = true;
      _fallo = null;
    });

    // Se toman antes de esperar: cerrar todas se lleva esta sesion, asi que la
    // pantalla puede dejar de existir mientras el servidor contesta.
    final repo = ref.read(repositorioAccesoProvider);
    final sesionLocal = ref.read(controladorSesionProvider);

    try {
      await repo.cambiarContrasena(actual: _actual.text, nueva: _nueva.text);
    } on Object catch (error) {
      // Se atrapa cualquier cosa y se tipa al vuelo: esta pantalla es la
      // ultima linea antes del usuario y un bug no debe tumbar un formulario
      // a medio llenar.
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _fallo = falloDe(error);
      });
      return;
    }

    if (mounted) {
      setState(() {
        _guardando = false;
        _listo = true;
      });
    }

    // La contrasena **ya cambio**: que falle cerrar las sesiones no vuelve
    // mentira lo anterior, asi que el aviso de exito se queda y el fallo se
    // anade aparte.
    if (!_cerrarTodas) return;
    try {
      await repo.cerrarTodasLasSesiones();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _fallo = falloDe(error));
      return;
    }
    await sesionLocal.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    // V2-M21.04: cambiar la contrasena necesita servidor.
    final sinRed = ref.watch(sinConexionProvider);
    final fallo = _fallo;

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
                    textos.accesoMiContrasenaTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  if (!_listo)
                    Text(
                      textos.accesoMiContrasenaExplicacion,
                      style: tokens.tipografia.cuerpo.copyWith(
                        color: tokens.colores.textoSecundario,
                      ),
                    ),
                  const SizedBox(height: Espaciado.e6),
                  if (_listo) ...[
                    Aviso(
                      tono: Tono.exito,
                      titulo: textos.accesoMiContrasenaListo,
                      mensaje: textos.accesoMiContrasenaListoMensaje,
                    ),
                    if (fallo != null) ...[
                      const SizedBox(height: Espaciado.e4),
                      Aviso(
                        key: PantallaMiContrasena.avisoDeError,
                        tono: Tono.advertencia,
                        titulo: textos.accesoSesionesFalloCerrar,
                        mensaje: fallo.mensaje,
                      ),
                    ],
                  ] else ...[
                    if (fallo != null) ...[
                      Aviso(
                        key: PantallaMiContrasena.avisoDeError,
                        tono: fallo.esSinConexion
                            ? Tono.advertencia
                            : Tono.peligro,
                        titulo: fallo.esSinConexion
                            ? textos.accesoSinConexionTitulo
                            : textos.accesoCambiarFalloTitulo,
                        mensaje: fallo.mensaje,
                      ),
                      const SizedBox(height: Espaciado.e4),
                    ],
                    CampoContrasena(
                      key: PantallaMiContrasena.campoActual,
                      etiqueta: textos.accesoCambiarActualEtiqueta,
                      controlador: _actual,
                      habilitado: _puedeGuardar,
                      accionTeclado: TextInputAction.next,
                      alCambiar: (_) => setState(() {}),
                    ),
                    const SizedBox(height: Espaciado.e4),
                    CampoContrasena(
                      key: PantallaMiContrasena.campoNueva,
                      etiqueta: textos.accesoCambiarNuevaEtiqueta,
                      controlador: _nueva,
                      habilitado: _puedeGuardar,
                      accionTeclado: TextInputAction.next,
                      alCambiar: (_) => setState(() {}),
                    ),
                    const SizedBox(height: Espaciado.e4),
                    CampoContrasena(
                      key: PantallaMiContrasena.campoConfirmar,
                      etiqueta: textos.accesoCambiarConfirmarEtiqueta,
                      controlador: _confirmar,
                      error: _errorConfirmar,
                      habilitado: _puedeGuardar,
                      accionTeclado: TextInputAction.done,
                      alCambiar: (_) => setState(() {}),
                      alEnviar: _puedeGuardar ? (_) => _guardar() : null,
                    ),
                    const SizedBox(height: Espaciado.e5),
                    ListaDeReglas(revision: _revision),
                    const SizedBox(height: Espaciado.e5),
                    Casilla(
                      key: PantallaMiContrasena.casillaCerrarOtras,
                      etiqueta: textos.accesoMiContrasenaCerrarOtras,
                      descripcion: textos.accesoMiContrasenaCerrarOtrasDetalle,
                      valor: _cerrarTodas,
                      alCambiar: _puedeGuardar
                          ? (valor) => setState(() => _cerrarTodas = valor)
                          : null,
                    ),
                    const SizedBox(height: Espaciado.e6),
                    Boton(
                      key: PantallaMiContrasena.botonGuardar,
                      texto: _guardando
                          ? textos.accesoCambiarGuardando
                          : textos.accesoMiContrasenaGuardar,
                      alPresionar: _puedeGuardar && !sinRed ? _guardar : null,
                      cargando: _guardando,
                      anchoCompleto: true,
                    ),
                    // V2-M21.04: deshabilitado no basta, hay que decir por
                    // que. Un boton apagado sin explicacion se lee como un
                    // error de la app.
                    if (sinRed) ...[
                      const SizedBox(height: Espaciado.e2),
                      Text(
                        textos.conexionAccionSinRed,
                        key: PantallaMiContrasena.explicacionSinRed,
                        style: tokens.tipografia.cuerpoChico.copyWith(
                          color: tokens.colores.textoSecundario,
                        ),
                        textAlign: TextAlign.center,
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
