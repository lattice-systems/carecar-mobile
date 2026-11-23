import 'coordenada.dart';

/// Estado del permiso de ubicación **en primer plano**.
enum PermisoUbicacion {
  /// Se puede leer la posición ahora.
  concedido,

  /// No concedido; se puede pedir.
  denegado,

  /// El sistema ya no mostrará el diálogo; hay que ir a Ajustes.
  denegadoParaSiempre,
}

/// Posición del teléfono, solo con la app abierta (M11, M17).
///
/// Nunca en segundo plano: no hay flujo continuo ni permiso "siempre".
abstract interface class ProveedorUbicacion {
  /// Permiso actual, sin mostrar ningún diálogo.
  Future<PermisoUbicacion> estadoDelPermiso();

  /// Muestra el diálogo del sistema si todavía se puede y devuelve el estado.
  Future<PermisoUbicacion> pedirPermiso();

  /// Lee la posición una sola vez. Si el permiso está denegado lo pide una vez.
  ///
  /// Lanza un [ErrorUbicacion]: servicio apagado, permiso denegado, permiso
  /// denegado para siempre o tiempo agotado tras [limite].
  Future<Coordenada> posicionActual({
    Duration limite = const Duration(seconds: 15),
  });
}
