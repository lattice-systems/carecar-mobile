import 'campana_seguridad.dart';
import 'garantia_vehiculo.dart';

/// Por que no se pudo agendar una campana (V2-M10.03).
enum MotivoRechazoCampana {
  /// La campana ya estaba agendada o atendida.
  yaAgendada,

  /// La franja se lleno mientras el cliente la elegia.
  sinCupo,

  /// El vehiculo ya tiene una cita ese dia.
  citaDuplicada,
}

/// Fallo esperado al agendar una campana: la pantalla lo explica en vez de
/// mostrar un error generico.
class AgendaCampanaRechazada implements Exception {
  const AgendaCampanaRechazada(this.motivo);

  final MotivoRechazoCampana motivo;
}

/// Lo que el modulo `garantia` necesita de la API (V2-M10.01 a V2-M10.03).
abstract interface class RepositorioGarantia {
  Future<GarantiaVehiculo> garantia(int vehiculoId);

  Future<List<CampanaSeguridad>> campanas(int vehiculoId);

  /// Lanza [AgendaCampanaRechazada] si la campana ya no se puede agendar, la
  /// franja se lleno o el vehiculo ya tiene cita ese dia.
  Future<CitaDeCampana> agendarCampana({
    required int vehiculoId,
    required int campanaId,
    required int franjaId,
    required DateTime fecha,
  });
}
