import 'comun.dart';

/// Franja del taller con cupo libre (APP-3.3 y ERP-3.3).
///
/// El contrato solo devuelve franjas con `cupoDisponible` mayor a cero.
class Disponibilidad {
  const Disponibilidad({
    required this.fecha,
    required this.franjaId,
    required this.horaInicio,
    required this.horaFin,
    required this.cupoDisponible,
  });

  factory Disponibilidad.fromJson(Map<String, Object?> json) => Disponibilidad(
    fecha: leerFecha(json['fecha'], 'fecha'),
    franjaId: leerEntero(json['franjaId'], 'franjaId'),
    horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
    horaFin: leerTexto(json['horaFin'], 'horaFin'),
    cupoDisponible: leerEntero(json['cupoDisponible'], 'cupoDisponible'),
  );

  final DateTime fecha;
  final int franjaId;

  /// Formato `HH:mm`, sin zona horaria (pregunta RIC-13).
  final String horaInicio;
  final String horaFin;
  final int cupoDisponible;
}
