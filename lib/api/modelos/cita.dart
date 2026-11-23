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
    this.motivo,
  });

  final int vehiculoId;
  final int franjaId;
  final DateTime fecha;

  /// Para que viene el cliente (V2-M02.08); el backend v2 lo guarda en
  /// `cita.motivo`. Se omite del cuerpo si no se eligio.
  final String? motivo;

  Map<String, Object?> toJson() => {
    'vehiculoId': vehiculoId,
    'franjaId': franjaId,
    'fecha': escribirFecha(fecha),
    if (motivo != null) 'motivo': motivo,
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
    this.franjaId,
    this.vehiculoNombre,
    this.motivo,
  });

  factory Cita.fromJson(Map<String, Object?> json) => Cita(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
    horaFin: leerTexto(json['horaFin'], 'horaFin'),
    estado: EstadoCita.desdeContrato(leerTexto(json['estado'], 'estado')),
    // El contrato exige franjaId, pero el backend actual aun no lo manda:
    // se lee de forma tolerante hasta que llegue.
    franjaId: json['franjaId'] is num
        ? (json['franjaId']! as num).toInt()
        : null,
    vehiculoNombre: _leerNombreVehiculo(json),
    motivo: json['motivo'] is String ? json['motivo']! as String : null,
  );

  /// Acepta `vehiculoNombre` o un objeto `vehiculo` con modelo/anio.
  static String? _leerNombreVehiculo(Map<String, Object?> json) {
    final nombre = json['vehiculoNombre'] ?? json['nombreVehiculo'];
    if (nombre is String && nombre.trim().isNotEmpty) return nombre.trim();
    final vehiculo = json['vehiculo'];
    if (vehiculo is Map) {
      final partes = [
        vehiculo['modelo'],
        vehiculo['anio'],
      ].where((p) => p != null && '$p'.trim().isNotEmpty).join(' ');
      if (partes.isNotEmpty) return partes;
    }
    return null;
  }

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final EstadoCita estado;

  /// Franja con la que quedo agendada; null si el backend no la manda.
  final int? franjaId;

  /// Nombre del vehiculo si el backend lo incluye; si no, la pantalla lo
  /// resuelve con `misVehiculos()`.
  final String? vehiculoNombre;

  /// Motivo de la cita si el backend ya lo guarda (V2-M02.08).
  final String? motivo;

  bool get sePuedeCancelar => estado == EstadoCita.confirmada;
}

/// Comprobante de una cita (`GET /citas/{id}/comprobante`, V2-M02.11).
///
/// `codigo` es lo que se dibuja en el QR: el id de la cita firmado por el
/// backend. La app no lo interpreta ni lo firma; solo lo muestra.
class ComprobanteCita {
  const ComprobanteCita({
    required this.citaId,
    required this.codigo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.vehiculoNombre,
  });

  factory ComprobanteCita.fromJson(Map<String, Object?> json) =>
      ComprobanteCita(
        citaId: leerEntero(json['citaId'], 'citaId'),
        codigo: leerTexto(json['codigo'], 'codigo'),
        fecha: leerFecha(json['fecha'], 'fecha'),
        horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
        horaFin: leerTexto(json['horaFin'], 'horaFin'),
        vehiculoNombre: json['vehiculoNombre'] is String
            ? json['vehiculoNombre']! as String
            : null,
      );

  final int citaId;
  final String codigo;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String? vehiculoNombre;
}
