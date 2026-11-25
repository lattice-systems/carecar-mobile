import 'gasto.dart';

/// Gastos de un vehículo (V2-M18). Lanza `KmInvalido` si el servidor rechaza
/// el km; los errores de red de la API pasan tal cual.
abstract interface class RepositorioBitacora {
  /// Todos los gastos del vehículo, del más reciente al más viejo.
  Future<List<Gasto>> gastos(int vehiculoId);

  Future<Gasto> registrar(int vehiculoId, BorradorGasto borrador);

  Future<Gasto> editar(int id, BorradorGasto borrador);

  Future<void> borrar(int id);
}
