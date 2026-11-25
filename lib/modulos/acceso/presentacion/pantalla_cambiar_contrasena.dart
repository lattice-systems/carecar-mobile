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
import '../../../nucleo/navegacion/proveedores_navegacion.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../dominio/reglas_contrasena.dart';
import 'proveedores_acceso.dart';

/// Cambio obligatorio de la contrasena temporal · V2-M01.03.
///
/// **No hay salida salvo cambiarla o cerrar sesion.** No lleva barra con
/// flecha de regreso, ni «omitir», ni «despues»: el criterio es que no se
/// pueda llegar a otra pantalla hasta cambiarla, y de eso se encarga tambien
/// el guardia del enrutador, que manda aqui mientras
/// `debeCambiarContrasena` siga en `true`.
///
/// Al terminar marca [contrasenaCambiadaProvider]. Hace falta porque **el
/// contrato no devuelve una sesion nueva**: `debeCambiarContrasena` se queda
/// en `true` y sin la marca el guardia volveria a mandar aqui para siempre.
class PantallaCambiarContrasena extends ConsumerStatefulWidget {
  const PantallaCambiarContrasena({super.key});

  static const campoActual = Key('cambiar_actual');
  static const campoNueva = Key('cambiar_nueva');
  static const campoConfirmar = Key('cambiar_confirmar');
  static const botonGuardar = Key('cambiar_guardar');
  static const botonCerrarSesion = Key('cambiar_cerrar_sesion');
  static const avisoDeError = Key('cambiar_aviso_error');

  @override
  ConsumerState<PantallaCambiarContrasena> createState() =>
      _EstadoPantallaCambiarContrasena();
}

class _EstadoPantallaCambiarContrasena
    extends ConsumerState<PantallaCambiarContrasena> {
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  bool _guardando = false;
  Fallo? _fallo;
  String? _errorConfirmar;

  /// Ya se cambio con exito.
  ///
  /// Despues de eso aqui no queda nada por hacer y el guardia esta a punto de
  /// sacar al usuario. No se depende de que llegue primero: un segundo toque
  /// mandaria otro cambio con una contrasena temporal que ya no sirve, y el
  /// servidor responderia un 401 sobre una operacion que si funciono.
  bool _yaCambio = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  /// Las reglas, recalculadas en cada tecla: es lo que el criterio llama
  /// «reglas en vivo».
  RevisionContrasena get _revision => ReglasContrasena.revisar(
    _nueva.text,
    actual: _actual.text.isEmpty ? null : _actual.text,
  );

  bool get _puedeGuardar => !_guardando && !_yaCambio;

  Future<void> _guardar() async {
    if (!_puedeGuardar) return;
    final textos = AppLocalizations.of(context);

    final coinciden = _nueva.text == _confirmar.text;
    setState(
      () => _errorConfirmar = coinciden ? null : textos.accesoCambiarNoCoincide,
    );

    // No se le pide al servidor lo que ya sabemos que va a rechazar: un 400
    // de mas no ayuda a nadie.
    if (!_revision.cumpleTodo || !coinciden) return;

    setState(() {
      _guardando = true;
      _fallo = null;
    });

    try {
      await ref
          .read(repositorioAccesoProvider)
          .cambiarContrasena(actual: _actual.text, nueva: _nueva.text);
      if (!mounted) return;
      ref.read(contrasenaCambiadaProvider.notifier).marcarCambiada();
      setState(() {
        _guardando = false;
        _yaCambio = true;
      });
    } catch (error) {
      // Se atrapa cualquier cosa y se tipa al vuelo, igual que hace
      // `VistaAsincrona` al pintar: esta pantalla es la ultima linea antes
      // del usuario, y un bug no debe tumbar un formulario a medio llenar.
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
    final fallo = _fallo;

    return Scaffold(
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
                    textos.accesoCambiarTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    textos.accesoCambiarExplicacion,
                    style: tokens.tipografia.cuerpo.copyWith(
                      color: tokens.colores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e6),
                  if (fallo != null) ...[
                    Aviso(
                      key: PantallaCambiarContrasena.avisoDeError,
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
                    key: PantallaCambiarContrasena.campoActual,
                    etiqueta: textos.accesoCambiarActualEtiqueta,
                    controlador: _actual,
                    habilitado: _puedeGuardar,
                    accionTeclado: TextInputAction.next,
                    alCambiar: (_) => setState(() {}),
                  ),
                  const SizedBox(height: Espaciado.e4),
                  CampoContrasena(
                    key: PantallaCambiarContrasena.campoNueva,
                    etiqueta: textos.accesoCambiarNuevaEtiqueta,
                    controlador: _nueva,
                    habilitado: _puedeGuardar,
                    accionTeclado: TextInputAction.next,
                    alCambiar: (_) => setState(() {}),
                  ),
                  const SizedBox(height: Espaciado.e4),
                  CampoContrasena(
                    key: PantallaCambiarContrasena.campoConfirmar,
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
                  const SizedBox(height: Espaciado.e6),
                  Boton(
                    key: PantallaCambiarContrasena.botonGuardar,
                    texto: _guardando
                        ? textos.accesoCambiarGuardando
                        : textos.accesoCambiarGuardar,
                    alPresionar: _puedeGuardar ? _guardar : null,
                    cargando: _guardando,
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Boton(
                    key: PantallaCambiarContrasena.botonCerrarSesion,
                    texto: textos.accesoCambiarCerrarSesion,
                    variante: VarianteBoton.terciario,
                    alPresionar: _guardando
                        ? null
                        : () => ref
                              .read(controladorSesionProvider)
                              .cerrarSesion(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Las reglas de la contrasena, marcandose mientras se escribe.
///
/// Se muestran **todas desde el principio** y no solo las que faltan: asi
/// quien llega sabe que se le va a pedir antes de escribir, en vez de
/// descubrirlo a base de errores.
class ListaDeReglas extends StatelessWidget {
  const ListaDeReglas({required this.revision, super.key});

  final RevisionContrasena revision;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    final reglas = <String, bool>{
      textos.accesoCambiarReglaLargo: revision.largoSuficiente,
      textos.accesoCambiarReglaLetra: revision.tieneLetra,
      textos.accesoCambiarReglaNumero: revision.tieneNumero,
      textos.accesoCambiarReglaDistinta: revision.esDistintaDeLaActual,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textos.accesoCambiarReglasTitulo,
          style: tokens.tipografia.cuerpoChico.copyWith(
            color: tokens.colores.textoSecundario,
          ),
        ),
        const SizedBox(height: Espaciado.e2),
        for (final regla in reglas.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.e1),
            child: Row(
              children: [
                // El icono acompana al color para que el estado no dependa
                // solo del color (guia de estilos).
                Icon(
                  regla.value
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                  size: 16,
                  color: regla.value
                      ? tokens.colores.exito
                      : tokens.colores.textoSecundario,
                ),
                const SizedBox(width: Espaciado.e2),
                Expanded(
                  child: Text(
                    regla.key,
                    style: tokens.tipografia.cuerpoChico.copyWith(
                      color: regla.value
                          ? tokens.colores.texto
                          : tokens.colores.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
