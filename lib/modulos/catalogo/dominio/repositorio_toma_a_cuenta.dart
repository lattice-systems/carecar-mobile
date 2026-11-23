import 'toma_a_cuenta.dart';

/// Contrato que la presentacion usa para estimar la toma a cuenta.
abstract interface class RepositorioTomaACuenta {
  /// Calcula el rango y lo guarda como estimacion del cliente.
  ///
  /// Lanza `NoEncontrado` si el vehiculo no es del cliente o el modelo ya no
  /// esta vigente, y `SinParametrosDeValuacion` si la agencia aun no valua ese
  /// auto.
  Future<Estimacion> estimar(SolicitudEstimacion solicitud);
}
