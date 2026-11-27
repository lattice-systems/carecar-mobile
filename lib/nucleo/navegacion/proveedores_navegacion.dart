import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../sesion/controlador_sesion.dart';
import '../../notificaciones/servicio_notificaciones.dart';
import '../avisos/destino_de_aviso.dart';
import '../avisos/explicacion_de_avisos.dart';
import '../bienvenida/estado_bienvenida.dart';
import '../biometria/candado_biometrico.dart';
import '../migracion/proveedores_migracion.dart';
import '../privacidad/estado_aviso.dart';
import '../sesion/proveedores_sesion.dart';
import 'enlaces.dart';
import 'guardia_sesion.dart';
import 'registro_de_rutas.dart';
import 'rutas.dart';

/// `true` cuando el cliente ya cambio su contrasena temporal en esta sesion.
///
/// El contrato no devuelve una sesion nueva al cambiarla, asi que
/// `debeCambiarContrasena` sigue en `true`; sin esta bandera la guardia
/// mandaria al cambio una y otra vez. Se apaga sola al cerrar la sesion.
final contrasenaCambiadaProvider =
    NotifierProvider<ContrasenaCambiadaNotifier, bool>(
      ContrasenaCambiadaNotifier.new,
      name: 'contrasenaCambiadaProvider',
    );

class ContrasenaCambiadaNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(estadoSesionProvider, (_, estado) {
      if (estado is! Autenticada) state = false;
    });
    return false;
  }

  void marcarCambiada() => state = true;
}

/// El enrutador de la app: une las rutas del nucleo con las de cada modulo
/// (`registro_de_rutas.dart`), traduce enlaces y aplica la guardia de sesion.
///
/// En pruebas se lee con `ProviderContainer`/`ref.read` y se navega con
/// `router.go(...)`; la sesion se sustituye con `controladorSesionProvider`.
final enrutadorProvider = Provider<GoRouter>((ref) {
  // go_router reevalua `redirect` cuando este notificador avisa.
  final cambios = ValueNotifier<int>(0);
  void avisar(Object? _, Object? _) => cambios.value++;
  ref.listen(estadoSesionProvider, avisar);
  ref.listen(contrasenaCambiadaProvider, avisar);
  ref.listen(estadoAvisoProvider, avisar);
  ref.listen(bienvenidaPendienteProvider, avisar);
  ref.listen(candadoPorAbrirProvider, avisar);
  ref.listen(avisosPorExplicarProvider, avisar);

  // V2-M06.03, app cerrada: el sistema arranco la app por un aviso y el toque
  // ya paso. No se navega -todavia no hay enrutador montado, y llamar a `go`
  // aqui revienta-: se arranca directamente ahi. Es tambien lo que hace un
  // enlace profundo en frio.
  final avisos = Notificaciones.actual;
  final deArranque = destinoDeAviso(avisos.destinoAlEntrar);
  avisos.destinoAlEntrar = null;

  final enrutador = GoRouter(
    initialLocation: deArranque ?? Rutas.inicio,
    refreshListenable: cambios,
    routes: rutasDeLaApp(ref.read(interruptorModulosProvider)),
    redirect: (context, state) {
      // 1. Un enlace externo se vuelve ruta interna antes de cualquier regla.
      final interna = EnlacesApp.aRutaInterna(state.uri);
      if (interna != null) return interna.toString();
      // 2. La guardia de sesion.
      return redirigirPorSesion(
        destino: state.uri,
        estado: ref.read(estadoSesionProvider),
        contrasenaCambiada: ref.read(contrasenaCambiadaProvider),
        avisoPorAceptar: ref.read(estadoAvisoProvider).porAceptar,
        bienvenidaPendiente: ref.read(bienvenidaPendienteProvider),
        candadoPorAbrir: ref.read(candadoPorAbrirProvider),
        avisosPorExplicar: ref.read(avisosPorExplicarProvider),
      );
    },
    // Una ruta que no existe (enlace viejo o mal escrito) no deja pantalla
    // en blanco: se va al inicio, y la guardia decide si pide sesion.
    onException: (context, state, router) => router.go(Rutas.inicio),
  );

  // V2-M06.03: tocar un aviso lleva a su pantalla. El toque lo recibe el
  // servicio de avisos, que vive fuera de Riverpod, asi que el destino entra
  // por `destinoDeAvisoProvider` y de ahi se navega.
  //
  // Se navega con `go` y no con `push`: el aviso lleva A una pantalla, no
  // encima de lo que hubiera. Si esa pantalla pide sesion, la guardia la
  // manda al acceso con `desde` y vuelve sola al entrar.
  ref.listen(destinoDeAvisoProvider, (_, destino) {
    if (destino == null) return;
    enrutador.go(destino);
    ref.read(destinoDeAvisoProvider.notifier).atendido();
  });

  void alTocarUnAviso() =>
      ref.read(destinoDeAvisoProvider.notifier).llego(avisos.ultimoDestino);
  avisos.toques.addListener(alTocarUnAviso);

  ref.onDispose(() {
    avisos.toques.removeListener(alTocarUnAviso);
    enrutador.dispose();
    cambios.dispose();
  });
  return enrutador;
}, name: 'enrutadorProvider');
