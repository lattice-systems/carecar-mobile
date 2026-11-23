import 'cita_agendada.dart';
import 'cita_cliente.dart';
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

  /// Una página de las citas del cliente, de la más reciente a la más antigua
  /// según el orden del servidor. `pagina` empieza en 0.
  Future<PaginaDeCitas> misCitas({int pagina = 0, int tamano = 20});

  /// Cancela una cita confirmada futura y libera su cupo.
  ///
  /// Lanza `CitaNoModificable` si ya no está confirmada o pasó el plazo.
  Future<CitaCliente> cancelar(int citaId);

  /// Cambia la cita a `franja` y libera la anterior en la misma operación.
  ///
  /// Lanza `FranjaSinCupo` si la franja nueva se llenó y `CitaNoModificable`
  /// si la cita ya no se puede cambiar.
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  });
}
