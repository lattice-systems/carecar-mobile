import 'comun.dart';

/// Un traslado de la recolección de una cita (`Traslado` del contrato).
class TrasladoCita {
  const TrasladoCita({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.costo,
    required this.fecha,
    required this.ventanaInicio,
    required this.ventanaFin,
  });

  factory TrasladoCita.fromJson(Map<String, Object?> json) => TrasladoCita(
    id: leerEntero(json['id'], 'id'),
    tipo: leerTexto(json['tipo'], 'tipo'),
    estado: leerTexto(json['estado'], 'estado'),
    costo: leerDecimal(json['costo'], 'costo'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    ventanaInicio: leerTexto(json['ventanaInicio'], 'ventanaInicio'),
    ventanaFin: leerTexto(json['ventanaFin'], 'ventanaFin'),
  );

  final int id;

  /// `recoger` o `entregar`.
  final String tipo;

  /// Nace `programado`; el resto de los estados llega con V2-M17.03.
  final String estado;
  final double costo;
  final DateTime fecha;
  final String ventanaInicio;
  final String ventanaFin;
}

/// La recolección que trae la cita recién agendada (`RecoleccionCita`).
class RecoleccionCita {
  const RecoleccionCita({
    required this.direccionId,
    required this.costoTotal,
    required this.traslados,
  });

  factory RecoleccionCita.fromJson(Map<String, Object?> json) {
    final lista = json['traslados'];
    if (lista is! List) {
      throw const FormatException('traslados: se esperaba una lista');
    }
    return RecoleccionCita(
      direccionId: leerEntero(json['direccionId'], 'direccionId'),
      costoTotal: leerDecimal(json['costoTotal'], 'costoTotal'),
      traslados: [
        for (final t in lista)
          TrasladoCita.fromJson((t as Map).cast<String, Object?>()),
      ],
    );
  }

  final int direccionId;
  final double costoTotal;
  final List<TrasladoCita> traslados;
}
