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
  });

  final int id;
  final TipoTraslado tipo;
  final double costo;
  final DateTime fecha;
  final String ventanaInicio;
  final String ventanaFin;
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
