import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../sesion/controlador_sesion.dart';
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

  final enrutador = GoRouter(
    initialLocation: Rutas.inicio,
    refreshListenable: cambios,
    routes: rutasDeLaApp(),
    redirect: (context, state) {
      // 1. Un enlace externo se vuelve ruta interna antes de cualquier regla.
      final interna = EnlacesApp.aRutaInterna(state.uri);
      if (interna != null) return interna.toString();
      // 2. La guardia de sesion.
      return redirigirPorSesion(
        destino: state.uri,
        estado: ref.read(estadoSesionProvider),
        contrasenaCambiada: ref.read(contrasenaCambiadaProvider),
      );
    },
    // Una ruta que no existe (enlace viejo o mal escrito) no deja pantalla
    // en blanco: se va al inicio, y la guardia decide si pide sesion.
    onException: (context, state, router) => router.go(Rutas.inicio),
  );

  ref.onDispose(() {
    enrutador.dispose();
    cambios.dispose();
  });
  return enrutador;
}, name: 'enrutadorProvider');
