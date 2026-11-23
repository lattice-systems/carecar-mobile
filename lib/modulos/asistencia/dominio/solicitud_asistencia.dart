import '../../../nucleo/mapas/mapas.dart';

/// Tipo de problema por el que se pide ayuda (V2-M11.01).
enum TipoAsistencia {
  llanta('llanta'),
  bateria('bateria'),
  choque('choque'),
  sinGasolina('sin_gasolina'),
  otro('otro');

  const TipoAsistencia(this.enElContrato);

  /// Valor que viaja en el contrato.
  final String enElContrato;

  static TipoAsistencia? desde(String? valor) {
    for (final t in values) {
      if (t.enElContrato == valor) return t;
    }
    return null;
  }
}

/// Ciclo de vida de una solicitud (el seguimiento es V2-M11.04).
enum EstadoSolicitud {
  recibida('recibida'),
  enCamino('en_camino'),
  atendida('atendida'),
  cancelada('cancelada');

  const EstadoSolicitud(this.enElContrato);

  final String enElContrato;

  /// Mientras esta abierta la agencia puede necesitar la ubicacion; despues
  /// ya no se comparte.
  bool get abierta => this == recibida || this == enCamino;

  /// Un estado que la app aun no conoce se trata como `recibida`: es lo mas
  /// prudente, la solicitud sigue viva.
  static EstadoSolicitud desde(String? valor) {
    for (final e in values) {
      if (e.enElContrato == valor) return e;
    }
    return recibida;
  }
}

/// Solicitud de ayuda ya recibida por la agencia. Dart puro.
class SolicitudAsistencia {
  const SolicitudAsistencia({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.estado,
    required this.creadaEn,
    this.ubicacion,
    this.comentario,
  });

  /// Lee el cuerpo de `POST /asistencia` o `GET /asistencia`. Lanza
  /// [FormatException] si falta algo obligatorio o el tipo no es del contrato.
  factory SolicitudAsistencia.desdeJson(Map<String, Object?> json) {
    final id = json['id'];
    final vehiculoId = json['vehiculoId'];
    final tipo = TipoAsistencia.desde(json['tipo'] as String?);
    final creada = DateTime.tryParse('${json['creadaEn']}');
    if (id is! num || vehiculoId is! num || tipo == null || creada == null) {
      throw const FormatException('La solicitud de asistencia esta incompleta.');
    }
    final lat = json['lat'];
    final lng = json['lng'];
    final comentario = (json['comentario'] as String?)?.trim();
    return SolicitudAsistencia(
      id: id.toInt(),
      vehiculoId: vehiculoId.toInt(),
      tipo: tipo,
      estado: EstadoSolicitud.desde(json['estado'] as String?),
      creadaEn: creada,
      ubicacion: lat is num && lng is num
          ? Coordenada(lat.toDouble(), lng.toDouble())
          : null,
      comentario: comentario == null || comentario.isEmpty ? null : comentario,
    );
  }

  final int id;
  final int vehiculoId;
  final TipoAsistencia tipo;
  final EstadoSolicitud estado;
  final DateTime creadaEn;

  /// Nula si el cliente no la compartio.
  final Coordenada? ubicacion;
  final String? comentario;
}
