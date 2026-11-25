import '../../../api/excepciones.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/repositorio_asistencia.dart';
import '../dominio/solicitud_asistencia.dart';

/// Lo que se le pidio al fake, para que las pruebas lo comprueben.
class PedidoDeAyuda {
  const PedidoDeAyuda({
    required this.vehiculoId,
    required this.tipo,
    this.ubicacion,
    this.comentario,
  });

  final int vehiculoId;
  final TipoAsistencia tipo;
  final Coordenada? ubicacion;
  final String? comentario;
}

/// Repositorio en memoria para pruebas y el flavor `desarrollo`.
///
/// Con [abierta] arranca con una solicitud ya abierta; con [fallo] crear la
/// solicitud lanza ese error y con [falloAlConsultar] lo hace consultar la
/// abierta; con [espera] no contesta hasta que se complete, para ver el
/// estado de carga.
class RepositorioAsistenciaFake implements RepositorioAsistencia {
  RepositorioAsistenciaFake({
    this.abierta,
    this.fallo,
    this.falloAlConsultar,
    this.espera,
  });

  SolicitudAsistencia? abierta;
  Object? fallo;
  Object? falloAlConsultar;
  final Future<void>? espera;

  final List<PedidoDeAyuda> pedidos = [];
  int _siguienteId = 1;

  @override
  Future<SolicitudAsistencia> pedirAyuda({
    required int vehiculoId,
    required TipoAsistencia tipo,
    Coordenada? ubicacion,
    String? comentario,
  }) async {
    pedidos.add(
      PedidoDeAyuda(
        vehiculoId: vehiculoId,
        tipo: tipo,
        ubicacion: ubicacion,
        comentario: comentario,
      ),
    );
    await espera;
    final error = fallo;
    if (error != null) throw error;
    if (abierta != null) throw const SolicitudAbierta();
    return abierta = SolicitudAsistencia(
      id: _siguienteId++,
      vehiculoId: vehiculoId,
      tipo: tipo,
      estado: EstadoSolicitud.recibida,
      creadaEn: DateTime.now(),
      ubicacion: ubicacion,
      comentario: comentario,
    );
  }

  @override
  Future<SolicitudAsistencia?> activa() async {
    await espera;
    final error = falloAlConsultar;
    if (error != null) throw error;
    return abierta;
  }

  /// Cuantas veces se consulto una solicitud por id.
  int consultas = 0;

  @override
  Future<SolicitudAsistencia> obtener(int id) async {
    consultas++;
    await espera;
    final error = falloAlConsultar;
    if (error != null) throw error;
    final solicitud = abierta;
    if (solicitud == null || solicitud.id != id) {
      throw const NoEncontrado('No existe la solicitud');
    }
    return solicitud;
  }
}
