import 'comun.dart';

/// Orden de servicio vista por el cliente (ERP-3.1, V2-M02.05).
class Servicio {
  const Servicio({
    required this.id,
    required this.fecha,
    required this.estatus,
    required this.total,
    this.fechaCierre,
  });

  factory Servicio.fromJson(Map<String, Object?> json) => Servicio(
    id: leerEntero(json['id'], 'id'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    estatus: leerTexto(json['estatus'], 'estatus'),
    total: leerDecimal(json['total'], 'total'),
    fechaCierre: leerFechaHoraOpcional(json['fechaCierre'], 'fechaCierre'),
  );

  final int id;
  final DateTime fecha;

  /// Uno de `RECIBIDO`, `EN_PROCESO`, `TERMINADO` o `ENTREGADO` (PO-5).
  final String estatus;

  /// Mano de obra mas refacciones.
  final double total;

  /// Cuando se cerro la orden, en hora de la agencia; nula si sigue abierta.
  final DateTime? fechaCierre;
}
