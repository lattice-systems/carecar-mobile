import 'comun.dart';

/// Un renglon del ticket: `importe` es `cantidad` por `precio`, con IVA.
class RenglonTicket {
  const RenglonTicket({
    required this.concepto,
    required this.cantidad,
    required this.precio,
    required this.importe,
  });

  factory RenglonTicket.fromJson(Map<String, Object?> json) => RenglonTicket(
    concepto: leerTexto(json['concepto'], 'concepto'),
    cantidad: leerEntero(json['cantidad'], 'cantidad'),
    precio: leerDecimal(json['precio'], 'precio'),
    importe: leerDecimal(json['importe'], 'importe'),
  );

  final String concepto;
  final int cantidad;
  final double precio;
  final double importe;
}

/// Ticket de una orden de servicio (`ServicioDetalle`, V2-M02.06).
class ServicioDetalle {
  const ServicioDetalle({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.kilometraje,
    required this.estatus,
    required this.manoDeObra,
    required this.refacciones,
    required this.totalManoDeObra,
    required this.totalRefacciones,
    required this.subtotal,
    required this.iva,
    required this.total,
    this.fechaCierre,
    this.puntosGanados,
  });

  factory ServicioDetalle.fromJson(
    Map<String, Object?> json,
  ) => ServicioDetalle(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    kilometraje: leerEntero(json['kilometraje'], 'kilometraje'),
    estatus: leerTexto(json['estatus'], 'estatus'),
    fechaCierre: leerFechaHoraOpcional(json['fechaCierre'], 'fechaCierre'),
    manoDeObra: _renglones(json['manoDeObra'], 'manoDeObra'),
    refacciones: _renglones(json['refacciones'], 'refacciones'),
    totalManoDeObra: leerDecimal(json['totalManoDeObra'], 'totalManoDeObra'),
    totalRefacciones: leerDecimal(json['totalRefacciones'], 'totalRefacciones'),
    subtotal: leerDecimal(json['subtotal'], 'subtotal'),
    iva: leerDecimal(json['iva'], 'iva'),
    total: leerDecimal(json['total'], 'total'),
    puntosGanados: leerEnteroOpcional(json['puntosGanados'], 'puntosGanados'),
  );

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final int kilometraje;
  final String estatus;
  final DateTime? fechaCierre;
  final List<RenglonTicket> manoDeObra;
  final List<RenglonTicket> refacciones;
  final double totalManoDeObra;
  final double totalRefacciones;
  final double subtotal;
  final double iva;
  final double total;

  /// Puntos de lealtad que dio la orden (V2-M12.02); nulo si no dio.
  final int? puntosGanados;
}

List<RenglonTicket> _renglones(Object? valor, String campo) {
  if (valor is! List) {
    throw FormatException('El campo «$campo» no es una lista');
  }
  return [
    for (final r in valor)
      RenglonTicket.fromJson((r as Map).cast<String, Object?>()),
  ];
}
