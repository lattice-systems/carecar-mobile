import 'vehiculo_garaje.dart';

/// Contrato que la presentacion usa para leer el garaje del cliente.
abstract interface class RepositorioGaraje {
  Future<List<VehiculoGaraje>> vehiculos();
}
