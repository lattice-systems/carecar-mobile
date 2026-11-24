import '../../../nucleo/mapas/mapas.dart';
import 'solicitud_asistencia.dart';

/// El cliente ya tiene una solicitud de ayuda abierta (409
/// `SOLICITUD_ABIERTA`). La pantalla la consulta con
/// [RepositorioAsistencia.activa] y la muestra en vez de crear otra.
class SolicitudAbierta implements Exception {
  const SolicitudAbierta();

  @override
  String toString() => 'SolicitudAbierta';
}

/// Contrato que la presentacion usa para pedir ayuda (V2-M11.01).
///
/// Las fallas de red (`SinConexion`, `ExcepcionApi`) pasan tal cual; solo el
/// 409 de solicitud abierta se traduce a [SolicitudAbierta].
abstract interface class RepositorioAsistencia {
  /// Crea la solicitud. [ubicacion] nula significa que el cliente no quiso o
  /// no pudo compartirla; en ese caso [comentario] suele decir donde esta.
  ///
  /// La ubicacion solo viaja en esta llamada: el repositorio no la guarda.
  Future<SolicitudAsistencia> pedirAyuda({
    required int vehiculoId,
    required TipoAsistencia tipo,
    Coordenada? ubicacion,
    String? comentario,
  });

  /// La solicitud abierta del cliente, o `null` si no tiene ninguna.
  Future<SolicitudAsistencia?> activa();
}
