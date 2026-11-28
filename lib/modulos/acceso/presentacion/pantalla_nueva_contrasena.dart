import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../dominio/fallos_acceso.dart';
import '../dominio/reglas_contrasena.dart';
import 'pantalla_cambiar_contrasena.dart' show ListaDeReglas;
import 'proveedores_acceso.dart';

/// El paso final de la recuperacion: el codigo del correo (o el enlace) y la
/// contrasena nueva · V2-M01.04 y V2-T02.27.
///
/// - **Con [correo] y sin [token]** (lo de hoy): pide el codigo de 6 digitos
///   que trae el correo, ademas de la contrasena. Ofrece pedir otro codigo.
/// - **Con [token]**: llego por el enlace; no pide codigo.
/// - **Sin ninguno**: no hay con que restablecer; ofrece pedir el codigo.
///
/// Llega por enlace profundo: `carecar://restablecer?token=…` o el enlace
/// universal `https://<host>/app/restablecer?token=…`, que el nucleo traduce
/// a esta ruta (V2-T01.03).
///
/// ## Los dos 400 que no se pueden confundir
///
/// Un enlace vencido o usado y una contrasena que no cumple **llegan los dos
/// como 400**, y solo los separa `Problema.codigo`. La diferencia para quien
/// usa la app es grande:
///
/// - **Enlace vencido o usado** → no hay nada que corregir aqui. Se retira el
///   formulario y se ofrece pedir otro enlace.
/// - **Contrasena rechazada** → el enlace sirve. Se conserva el formulario
///   para corregir y volver a intentar; mandar a pedir otro enlace seria
///   hacer empezar de cero sin motivo.
class PantallaNuevaContrasena extends ConsumerStatefulWidget {
  const PantallaNuevaContrasena({required this.token, this.correo, super.key});

  /// El token que venia en el enlace. Nulo si el enlace llego sin el.
  final String? token;

  /// El correo al que se envio el codigo, cuando se llega desde «Recupera tu
  /// contrasena».
  final String? correo;

  static const campoCodigo = Key('nueva_codigo');
  static const botonReenviar = Key('nueva_reenviar');
  static const avisoReenviado = Key('nueva_aviso_reenviado');

  static const campoNueva = Key('nueva_contrasena');
  static const campoConfirmar = Key('nueva_confirmar');
  static const botonGuardar = Key('nueva_guardar');
  static const botonPedirOtro = Key('nueva_pedir_otro');
  static const botonIrAlAcceso = Key('nueva_ir_acceso');
  static const avisoDeError = Key('nueva_aviso_error');
  static const avisoEnlaceNoValido = Key('nueva_aviso_enlace');
  static const avisoListo = Key('nueva_aviso_listo');

  @override
  ConsumerState<PantallaNuevaContrasena> createState() =>
      _EstadoPantallaNuevaContrasena();
}

class _EstadoPantallaNuevaContrasena
    extends ConsumerState<PantallaNuevaContrasena> {
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  /// Con codigo cuando no hay token y si hay correo.
  bool get _conCodigo =>
      (widget.token ?? '').trim().isEmpty &&
      (widget.correo ?? '').trim().isNotEmpty;

  String? _errorCodigo;
  bool _reenviando = false;
  bool _reenviado = false;

  bool _guardando = false;
  bool _listo = false;
  Fallo? _fallo;
  String? _errorConfirmar;

  /// El enlace no sirve: llego sin token, o el servidor lo rechazo.
  ///
  /// Arranca en `true` cuando no hay token, para no pedirle una contrasena a
  /// alguien que de todos modos no la va a poder guardar.
  late bool _enlaceRoto =
      (widget.token ?? '').trim().isEmpty &&
      (widget.correo ?? '').trim().isEmpty;

  /// El servidor rechazo el codigo: se conserva el formulario para corregirlo.
  bool _codigoRechazado = false;

  @override
  void dispose() {
    _codigo.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  RevisionContrasena get _revision => ReglasContrasena.revisar(_nueva.text);

  Future<void> _guardar() async {
    if (_guardando || _listo || _enlaceRoto) return;
    final textos = AppLocalizations.of(context);

    final coinciden = _nueva.text == _confirmar.text;
    final codigo = _codigo.text.trim();
    final codigoCompleto = !_conCodigo || RegExp(r'^\d{6}$').hasMatch(codigo);
    setState(() {
      _errorConfirmar = coinciden ? null : textos.accesoCambiarNoCoincide;
      _errorCodigo = codigoCompleto ? null : textos.accesoCodigoIncompleto;
    });
    if (!_revision.cumpleTodo || !coinciden || !codigoCompleto) return;

    setState(() {
      _guardando = true;
      _fallo = null;
      _codigoRechazado = false;
    });

    try {
      final repositorio = ref.read(repositorioAccesoProvider);
      if (_conCodigo) {
        await repositorio.restablecerConCodigo(
          correo: widget.correo!.trim(),
          codigo: codigo,
          contrasenaNueva: _nueva.text,
        );
      } else {
        await repositorio.restablecerConEnlace(
          token: widget.token!.trim(),
          contrasenaNueva: _nueva.text,
        );
      }
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _listo = true;
      });
    } on CodigoNoValido {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _codigoRechazado = true;
      });
    } on EnlaceNoValido {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _enlaceRoto = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _fallo = falloDe(error);
      });
    }
  }

  /// Pide otro codigo al mismo correo, sin salir de la pantalla.
  Future<void> _reenviar() async {
    if (_reenviando) return;
    setState(() {
      _reenviando = true;
      _reenviado = false;
      _fallo = null;
    });
    try {
      await ref
          .read(repositorioAccesoProvider)
          .pedirEnlaceDeRecuperacion(widget.correo!.trim());
      if (!mounted) return;
      setState(() {
        _reenviando = false;
        _reenviado = true;
        _codigoRechazado = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reenviando = false;
        _fallo = falloDe(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final titulo = _enlaceRoto
        ? (_conCodigo || (widget.token ?? '').trim().isNotEmpty
              ? textos.accesoEnlaceNoValidoTitulo
              : textos.accesoCodigoSinCorreo)
        : _conCodigo && !_listo
        ? textos.accesoCodigoTitulo
        : textos.accesoNuevaTitulo;
    final subtitulo = _enlaceRoto || _listo
        ? null
        : _conCodigo
        ? textos.accesoCodigoExplicacion(widget.correo!.trim())
        : textos.accesoNuevaExplicacion;

    return MarcoPantalla(
      titulo: titulo,
      subtitulo: subtitulo,
      conRegreso: true,
      icono: LucideIcons300.lockKeyhole,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.margenTelefono,
            Espaciado.e4,
            Espaciado.margenTelefono,
            Espaciado.e8,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _contenido(textos),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _contenido(AppLocalizations textos) {
    if (_enlaceRoto) {
      return [
        Aviso(
          key: PantallaNuevaContrasena.avisoEnlaceNoValido,
          tono: Tono.advertencia,
          titulo: textos.accesoEnlaceNoValidoTitulo,
          mensaje: textos.accesoEnlaceNoValidoMensaje,
        ),
        const SizedBox(height: Espaciado.e5),
        Boton(
          key: PantallaNuevaContrasena.botonPedirOtro,
          texto: textos.accesoEnlacePedirOtro,
          anchoCompleto: true,
          alPresionar: () =>
              context.go(Rutas.localizacionRecuperar(correo: widget.correo)),
        ),
      ];
    }

    if (_listo) {
      return [
        Aviso(
          key: PantallaNuevaContrasena.avisoListo,
          tono: Tono.exito,
          titulo: textos.accesoNuevaListoTitulo,
          mensaje: textos.accesoNuevaListoMensaje,
        ),
        const SizedBox(height: Espaciado.e5),
        Boton(
          key: PantallaNuevaContrasena.botonIrAlAcceso,
          texto: textos.accesoNuevaIrAlAcceso,
          anchoCompleto: true,
          alPresionar: () => context.go(Rutas.acceso),
        ),
      ];
    }

    final fallo = _fallo;
    return [
      if (_reenviado) ...[
        Aviso(
          key: PantallaNuevaContrasena.avisoReenviado,
          tono: Tono.informacion,
          titulo: textos.accesoCodigoReenviado,
          mensaje: textos.accesoRecuperarEnviadoMensaje,
        ),
        const SizedBox(height: Espaciado.e4),
      ],
      if (_codigoRechazado) ...[
        Aviso(
          key: PantallaNuevaContrasena.avisoEnlaceNoValido,
          tono: Tono.advertencia,
          titulo: textos.accesoCodigoNoValidoTitulo,
          mensaje: textos.accesoCodigoNoValidoMensaje,
        ),
        const SizedBox(height: Espaciado.e4),
      ],
      if (fallo != null) ...[
        Aviso(
          key: PantallaNuevaContrasena.avisoDeError,
          tono: fallo.esSinConexion ? Tono.advertencia : Tono.peligro,
          titulo: fallo.esSinConexion
              ? textos.accesoSinConexionTitulo
              : textos.accesoNuevaFalloTitulo,
          mensaje: fallo.mensaje,
        ),
        const SizedBox(height: Espaciado.e4),
      ],
      if (_conCodigo) ...[
        CampoTexto(
          key: PantallaNuevaContrasena.campoCodigo,
          etiqueta: textos.accesoCodigoEtiqueta,
          controlador: _codigo,
          error: _errorCodigo,
          habilitado: !_guardando,
          teclado: TextInputType.number,
          pistasAutocompletar: const [AutofillHints.oneTimeCode],
          formatos: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          accionTeclado: TextInputAction.next,
        ),
        const SizedBox(height: Espaciado.e4),
      ],
      CampoContrasena(
        key: PantallaNuevaContrasena.campoNueva,
        etiqueta: textos.accesoCambiarNuevaEtiqueta,
        controlador: _nueva,
        habilitado: !_guardando,
        accionTeclado: TextInputAction.next,
        alCambiar: (_) => setState(() {}),
      ),
      const SizedBox(height: Espaciado.e4),
      CampoContrasena(
        key: PantallaNuevaContrasena.campoConfirmar,
        etiqueta: textos.accesoCambiarConfirmarEtiqueta,
        controlador: _confirmar,
        error: _errorConfirmar,
        habilitado: !_guardando,
        accionTeclado: TextInputAction.done,
        alCambiar: (_) => setState(() {}),
        alEnviar: _guardando ? null : (_) => _guardar(),
      ),
      const SizedBox(height: Espaciado.e5),
      // Sin la regla de «distinta de la temporal»: aqui no hay temporal que
      // conocer, asi que siempre se cumpliria y solo confundiria.
      ListaDeReglas(revision: _revision, mostrarDistinta: false),
      const SizedBox(height: Espaciado.e6),
      Boton(
        key: PantallaNuevaContrasena.botonGuardar,
        texto: _guardando
            ? textos.accesoNuevaGuardando
            : textos.accesoNuevaGuardar,
        alPresionar: _guardando ? null : _guardar,
        cargando: _guardando,
        anchoCompleto: true,
      ),
      if (_conCodigo) ...[
        const SizedBox(height: Espaciado.e2),
        Boton(
          key: PantallaNuevaContrasena.botonReenviar,
          texto: textos.accesoCodigoReenviar,
          variante: VarianteBoton.terciario,
          alPresionar: _guardando || _reenviando ? null : _reenviar,
          cargando: _reenviando,
        ),
      ],
    ];
  }
}
