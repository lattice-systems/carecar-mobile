/// Que tan grave es una campana de seguridad (V2-M10.02).
enum GravedadCampana {
  baja('BAJA'),
  media('MEDIA'),
  alta('ALTA'),
  critica('CRITICA');

  const GravedadCampana(this.codigo);

  final String codigo;

  /// Una gravedad que esta version no conoce se trata como alta: es mas
  /// seguro llamar la atencion que esconderla.
  static GravedadCampana desde(String? codigo) => values.firstWhere(
    (gravedad) => gravedad.codigo == codigo,
    orElse: () => alta,
  );
}

/// En que va la campana para el vehiculo (V2-M10.02 y V2-M10.03).
enum EstadoCampana {
  abierta('ABIERTA'),
  agendada('AGENDADA'),
  atendida('ATENDIDA');

  const EstadoCampana(this.codigo);

  final String codigo;

  static EstadoCampana desde(String? codigo) => values.firstWhere(
    (estado) => estado.codigo == codigo,
    orElse: () => abierta,
  );
}

/// Una campana de seguridad (recall) para un vehiculo del cliente.
class CampanaSeguridad {
  const CampanaSeguridad({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.descripcion,
    required this.queHacer,
    required this.gravedad,
    required this.estado,
    required this.publicadaEn,
    this.citaId,
  });

  final int id;
  final String codigo;
  final String titulo;
  final String descripcion;
  final String queHacer;
  final GravedadCampana gravedad;
  final EstadoCampana estado;

  /// La cita que la atiende; nula si aun no se agenda.
  final int? citaId;
  final DateTime publicadaEn;

  bool get abierta => estado == EstadoCampana.abierta;
}

/// La cita que se agendo para atender una campana (V2-M10.03).
class CitaDeCampana {
  const CitaDeCampana({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
  });

  final int id;
  final DateTime fecha;

  /// `HH:mm`, hora de la agencia, tal como la manda el contrato.
  final String horaInicio;
  final String horaFin;
}
