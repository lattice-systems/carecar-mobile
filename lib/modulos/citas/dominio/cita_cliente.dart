import '../../recoleccion/recoleccion.dart' show RecoleccionAgendada;
import 'motivo_cita.dart';

/// Estado de una cita tal como lo ve el cliente (V2-M02.09).
enum EstadoDeCita { confirmada, atendida, noAsistio, cancelada, desconocido }

/// Una cita del cliente en su lista, con su estado.
///
/// Dart puro. A diferencia de `CitaAgendada` (la que acaba de confirmarse),
/// esta puede estar atendida, cancelada o vencida.
class CitaCliente {
  const CitaCliente({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.franjaId,
    this.vehiculoNombre,
    this.motivo,
    this.recoleccion,
  });

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final EstadoDeCita estado;

  /// Franja con la que se agendó; nulo si el backend aún no la manda.
  final int? franjaId;

  /// Nombre del vehículo si el backend lo incluye.
  final String? vehiculoNombre;

  /// Nulo si el backend aún no lo guarda o es un motivo desconocido.
  final MotivoCita? motivo;

  /// Los traslados de recoger y entregar con su estado (V2-M17.03); nulo si la
  /// cita no lleva recolección.
  final RecoleccionAgendada? recoleccion;

  /// Momento en que empieza la cita: la fecha más la hora de inicio. Una hora
  /// que no se puede leer cuenta como el inicio del día.
  DateTime get inicio {
    final partes = horaInicio.split(':');
    final hora = partes.isNotEmpty ? int.tryParse(partes[0]) : null;
    final minuto = partes.length > 1 ? int.tryParse(partes[1]) : null;
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora ?? 0,
      hora == null ? 0 : (minuto ?? 0),
    );
  }

  /// Confirmada y que todavía no empieza.
  bool esProxima(DateTime ahora) =>
      estado == EstadoDeCita.confirmada && !inicio.isBefore(ahora);

  /// Solo una cita confirmada futura se cancela o se reprograma.
  bool sePuedeModificar(DateTime ahora) => esProxima(ahora);
}

/// Una página de la lista de citas.
class PaginaDeCitas {
  const PaginaDeCitas({
    required this.citas,
    required this.pagina,
    required this.totalPaginas,
  });

  final List<CitaCliente> citas;

  /// Índice de esta página, empezando en 0.
  final int pagina;
  final int totalPaginas;

  bool get hayMas => pagina + 1 < totalPaginas;
}
