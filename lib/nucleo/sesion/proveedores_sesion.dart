import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sesion/controlador_sesion.dart';

/// Expone el `ControladorSesion` de la v1 mientras dura la migracion.
///
/// Lo arma `main.dart` (necesita el almacen seguro y la API) y lo inyecta con
/// `overrides`. Para acciones (iniciar o cerrar sesion) se lee este proveedor;
/// para reaccionar al estado se observa [estadoSesionProvider].
final controladorSesionProvider = Provider<ControladorSesion>(
  (ref) => throw StateError(
    'controladorSesionProvider no esta inyectado. Agrega '
    '`controladorSesionProvider.overrideWithValue(...)` en el ProviderScope.',
  ),
  name: 'controladorSesionProvider',
);

/// Estado actual de la sesion; se reconstruye cuando el controlador avisa.
///
/// Es el puente entre el `ChangeNotifier` v1 y el modelo reactivo de Riverpod:
/// los modulos nuevos observan esto y no necesitan `addListener`.
final estadoSesionProvider = NotifierProvider<_EstadoSesion, EstadoSesion>(
  _EstadoSesion.new,
  name: 'estadoSesionProvider',
);

class _EstadoSesion extends Notifier<EstadoSesion> {
  @override
  EstadoSesion build() {
    final controlador = ref.watch(controladorSesionProvider);
    void alCambiar() => state = controlador.estado;
    controlador.addListener(alCambiar);
    ref.onDispose(() => controlador.removeListener(alCambiar));
    return controlador.estado;
  }
}
