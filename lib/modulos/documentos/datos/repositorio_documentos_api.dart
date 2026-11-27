import '../../../nucleo/api/api_cliente.dart';
import '../dominio/documento_vehiculo.dart';
import '../dominio/repositorio_documentos.dart';
import 'lectura_documentos.dart';

/// `GET /vehiculos/{id}/documentos` con el cliente del nucleo. Las excepciones
/// de la API (404 de un vehiculo ajeno, sin conexion...) pasan tal cual.
class RepositorioDocumentosApi implements RepositorioDocumentos {
  const RepositorioDocumentosApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaDocumentos();

  @override
  Future<List<DocumentoVehiculo>> documentos(int vehiculoId) => _cliente
      .obtenerLista('/vehiculos/$vehiculoId/documentos', _lectura.documento);
}
