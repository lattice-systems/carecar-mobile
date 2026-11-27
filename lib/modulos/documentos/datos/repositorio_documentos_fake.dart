import '../dominio/documento_vehiculo.dart';
import '../dominio/repositorio_documentos.dart';

/// Repositorio en memoria para pruebas. Los datos de ejemplo viven en las
/// pruebas.
class RepositorioDocumentosFake implements RepositorioDocumentos {
  RepositorioDocumentosFake({
    List<DocumentoVehiculo> documentos = const [],
    this.falla,
  }) : documentosActuales = documentos;

  List<DocumentoVehiculo> documentosActuales;

  /// Si no es nulo, cada lectura lo lanza.
  Object? falla;

  /// Cuantas veces se pidieron los documentos, para saber si se recargo.
  var lecturas = 0;

  @override
  Future<List<DocumentoVehiculo>> documentos(int vehiculoId) async {
    lecturas++;
    if (falla != null) throw falla!;
    return [
      for (final documento in documentosActuales)
        if (documento.vehiculoId == vehiculoId) documento,
    ];
  }
}
