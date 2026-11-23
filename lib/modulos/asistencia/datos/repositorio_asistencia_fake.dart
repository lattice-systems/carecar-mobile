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
/// Con [abierta] arranca con una solicitud ya abierta; con [fallo] cada
/// llamada lanza ese error; con [espera] no contesta hasta que se complete,
/// para ver el estado de carga.
class RepositorioAsistenciaFake implements RepositorioAsistencia {
  RepositorioAsistenciaFake({this.abierta, this.fallo, this.espera});

  SolicitudAsistencia? abierta;
  Object? fallo;
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
    final error = fallo;
    if (error != null) throw error;
    return abierta;
  }
}
