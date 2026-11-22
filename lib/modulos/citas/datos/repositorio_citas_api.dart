import '../../../api/carecar_api.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/repositorio_citas.dart';

/// Lee `GET /agenda/disponibilidad` y lo traduce a modelos de dominio.
///
/// Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal cual: la
/// presentacion decide como mostrarlas.
class RepositorioCitasApi implements RepositorioCitas {
  const RepositorioCitasApi(this._api);

  final CarecarApi _api;

  @override
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final dto = await _api.disponibilidad(desde: desde, hasta: hasta);
    return DisponibilidadTaller(
      dto.map(
        (d) => FranjaDisponible(
          franjaId: d.franjaId,
          fecha: d.fecha,
          horaInicio: d.horaInicio,
          horaFin: d.horaFin,
          cupo: d.cupoDisponible,
        ),
      ),
    );
  }
}
