import 'cita_agendada.dart';
import 'disponibilidad_taller.dart';
import 'motivo_cita.dart';

/// Contrato que la presentacion usa para leer y agendar citas.
abstract interface class RepositorioCitas {
  /// Lo que el taller tiene libre entre `desde` y `hasta`, ambos incluidos.
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Agenda una cita en `franja` para el vehiculo.
  ///
  /// Lanza `FranjaSinCupo` si la franja se lleno y `CitaDuplicada` si el
  /// cliente ya tiene cita ese dia con ese vehiculo.
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
  });
}
