import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../dominio/fallos_acceso.dart';
import '../dominio/reglas_contrasena.dart';
import 'pantalla_cambiar_contrasena.dart' show ListaDeReglas;
import 'proveedores_acceso.dart';

/// A donde abre el enlace del correo · V2-M01.04.
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
  const PantallaNuevaContrasena({required this.token, super.key});

  /// El token que venia en el enlace. Nulo si el enlace llego sin el.
  final String? token;

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
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  bool _guardando = false;
  bool _listo = false;
  Fallo? _fallo;
  String? _errorConfirmar;

  /// El enlace no sirve: llego sin token, o el servidor lo rechazo.
  ///
  /// Arranca en `true` cuando no hay token, para no pedirle una contrasena a
  /// alguien que de todos modos no la va a poder guardar.
  late bool _enlaceRoto = (widget.token ?? '').trim().isEmpty;

  @override
  void dispose() {
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  RevisionContrasena get _revision => ReglasContrasena.revisar(_nueva.text);

  Future<void> _guardar() async {
    if (_guardando || _listo || _enlaceRoto) return;
    final textos = AppLocalizations.of(context);

    final coinciden = _nueva.text == _confirmar.text;
    setState(
      () => _errorConfirmar = coinciden ? null : textos.accesoCambiarNoCoincide,
    );
    if (!_revision.cumpleTodo || !coinciden) return;

    setState(() {
      _guardando = true;
      _fallo = null;
    });

    try {
      await ref
          .read(repositorioAccesoProvider)
          .restablecerConEnlace(
            token: widget.token!.trim(),
            contrasenaNueva: _nueva.text,
          );
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _listo = true;
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

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

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
                    _enlaceRoto
                        ? textos.accesoEnlaceNoValidoTitulo
                        : textos.accesoNuevaTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  if (!_enlaceRoto && !_listo)
                    Text(
                      textos.accesoNuevaExplicacion,
                      style: tokens.tipografia.cuerpo.copyWith(
                        color: tokens.colores.textoSecundario,
                      ),
                    ),
                  const SizedBox(height: Espaciado.e6),
                  ..._contenido(textos),
                ],
              ),
            ),
          ),
        ),
      ),
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
          alPresionar: () => context.go(Rutas.recuperar),
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
    ];
  }
}
