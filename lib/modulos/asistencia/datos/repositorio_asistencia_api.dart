import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/repositorio_asistencia.dart';
import '../dominio/solicitud_asistencia.dart';

/// `POST /asistencia` y `GET /asistencia?activa=true` con el cliente del
/// nucleo.
///
/// No hay cache: ni la respuesta ni la ubicacion se guardan en el telefono.
/// Las fallas de red pasan tal cual; solo el 409 `SOLICITUD_ABIERTA` se
/// traduce.
class RepositorioAsistenciaApi implements RepositorioAsistencia {
  const RepositorioAsistenciaApi(this._cliente);

  final ApiCliente _cliente;

  @override
  Future<SolicitudAsistencia> pedirAyuda({
    required int vehiculoId,
    required TipoAsistencia tipo,
    Coordenada? ubicacion,
    String? comentario,
  }) async {
    final texto = comentario?.trim();
    try {
      return await _cliente.enviar(
        '/asistencia',
        cuerpo: {
          'vehiculoId': vehiculoId,
          'tipo': tipo.enElContrato,
          if (ubicacion != null) 'lat': ubicacion.latitud,
          if (ubicacion != null) 'lng': ubicacion.longitud,
          if (texto != null && texto.isNotEmpty) 'comentario': texto,
        },
        leer: SolicitudAsistencia.desdeJson,
      );
    } on Conflicto catch (conflicto) {
      if (conflicto.problema?.codigo == CodigoProblema.solicitudAbierta) {
        throw const SolicitudAbierta();
      }
      rethrow;
    }
  }

  @override
  Future<SolicitudAsistencia?> activa() => _cliente.obtenerOpcional(
    '/asistencia',
    SolicitudAsistencia.desdeJson,
    consulta: const {'activa': 'true'},
  );
}
