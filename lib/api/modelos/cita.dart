import 'comun.dart';

/// Estados de cita que declara el contrato.
enum EstadoCita {
  confirmada('CONFIRMADA'),
  atendida('ATENDIDA'),
  noAsistio('NO_ASISTIO'),
  cancelada('CANCELADA'),

  /// Un estado que el contrato todavia no declara.
  ///
  /// Existe para que agregar un estado del lado del backend no tumbe la app.
  /// La prueba de contrato avisa cuando el enum del YAML cambia, asi que esto
  /// es una red de seguridad, no una excusa para no actualizarlo.
  desconocido('');

  const EstadoCita(this.enElContrato);

  /// El valor tal como viaja en el JSON.
  final String enElContrato;

  static EstadoCita desdeContrato(String valor) => values.firstWhere(
    (e) => e.enElContrato == valor,
    orElse: () => desconocido,
  );
}

/// Cuerpo de `POST /citas`.
class NuevaCita {
  const NuevaCita({
    required this.vehiculoId,
    required this.franjaId,
    required this.fecha,
  });

  final int vehiculoId;
  final int franjaId;
  final DateTime fecha;

  Map<String, Object?> toJson() => {
    'vehiculoId': vehiculoId,
    'franjaId': franjaId,
    'fecha': escribirFecha(fecha),
  };
}

/// Cita de servicio del cliente (APP-3.3).
class Cita {
  const Cita({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, Object?> json) => Cita(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
    horaFin: leerTexto(json['horaFin'], 'horaFin'),
    estado: EstadoCita.desdeContrato(leerTexto(json['estado'], 'estado')),
  );

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final EstadoCita estado;

  /// La respuesta no incluye `franjaId`, asi que no se puede saber con que
  /// franja quedo agendada: es la pregunta RIC-10.
  bool get sePuedeCancelar => estado == EstadoCita.confirmada;
}
