import 'sucursal.dart';

/// Contrato que la presentación usa para leer las sucursales (V2-M27.02).
abstract interface class RepositorioSucursales {
  /// Las sucursales activas, la principal primero; vacío si no hay ninguna.
  ///
  /// Lanza `SinConexion` sin red. «Abierto ahora» llega calculado por el
  /// servidor, por eso cada llamada vuelve a pedirlo.
  Future<List<Sucursal>> sucursales();
}
