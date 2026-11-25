import '../../../api/modelos/traslado.dart' show EstadoTraslado;

/// Si el traslado recoge el auto o lo entrega.
enum TipoTraslado { recoger, entregar }

/// Un traslado ya creado y ligado a una cita.
class TrasladoAgendado {
  const TrasladoAgendado({
    required this.id,
    required this.tipo,
    required this.costo,
    required this.fecha,
    required this.ventanaInicio,
    required this.ventanaFin,
    this.estado = EstadoTraslado.programado,
  });

  final int id;
  final TipoTraslado tipo;

  /// Cómo va el traslado. Al agendar nace `programado`; `GET /citas` trae el
  /// que lleva (V2-M17.03).
  final EstadoTraslado estado;
  final double costo;
  final DateTime fecha;
  final String ventanaInicio;
  final String ventanaFin;

  /// El chofer ya dejó su checklist de este traslado: al recoger, desde que
  /// recoge el auto; al entregar, hasta que lo devuelve.
  bool get tieneChecklist => switch (tipo) {
    TipoTraslado.recoger =>
      estado == EstadoTraslado.recogido ||
          estado == EstadoTraslado.enTaller ||
          estado == EstadoTraslado.deRegreso ||
          estado == EstadoTraslado.entregado,
    TipoTraslado.entregar => estado == EstadoTraslado.entregado,
  };
}

/// La recolección que viene con una cita recién agendada (V2-M17.02).
class RecoleccionAgendada {
  const RecoleccionAgendada({
    required this.direccionId,
    required this.costoTotal,
    required this.traslados,
  });

  final int direccionId;
  final double costoTotal;
  final List<TrasladoAgendado> traslados;

  TrasladoAgendado? get recoger => _de(TipoTraslado.recoger);
  TrasladoAgendado? get entregar => _de(TipoTraslado.entregar);

  TrasladoAgendado? _de(TipoTraslado tipo) {
    for (final t in traslados) {
      if (t.tipo == tipo) return t;
    }
    return null;
  }
}
