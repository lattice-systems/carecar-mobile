import 'documento_vehiculo.dart';

/// Lo que el modulo `documentos` necesita de la API (V2-M09.01).
abstract interface class RepositorioDocumentos {
  /// Los documentos del vehiculo con su estado, por vencimiento; vacia si no
  /// hay. Un vehiculo ajeno responde 404 (`NoEncontrado`).
  Future<List<DocumentoVehiculo>> documentos(int vehiculoId);
}
