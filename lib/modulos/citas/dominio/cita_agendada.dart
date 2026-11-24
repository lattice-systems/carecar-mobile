import '../../recoleccion/recoleccion.dart' show RecoleccionAgendada;
import 'motivo_cita.dart';

/// Una cita ya confirmada por el taller.
///
/// Dart puro. Lo que la pantalla necesita para el comprobante o para mostrar la
/// cita existente cuando hay duplicado.
class CitaAgendada {
  const CitaAgendada({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.motivo,
    this.recoleccion,
  });

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  /// Nulo si el backend aun no lo guarda o es un motivo desconocido.
  final MotivoCita? motivo;

  /// Los traslados de recoger y entregar el auto (V2-M17.02); nulo si la cita
  /// se agendó sin recolección.
  final RecoleccionAgendada? recoleccion;
}
