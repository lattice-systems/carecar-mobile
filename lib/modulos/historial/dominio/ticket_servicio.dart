import 'orden_historial.dart';

/// Un renglon del ticket: `importe` es `cantidad` por `precio`, con IVA.
class RenglonTicketServicio {
  const RenglonTicketServicio({
    required this.concepto,
    required this.cantidad,
    required this.precio,
    required this.importe,
  });

  final String concepto;
  final int cantidad;
  final double precio;
  final double importe;
}

/// Con que quedo pagada una orden (V2-M08.02), para su ticket.
class PagoDelTicket {
  const PagoDelTicket({
    required this.id,
    required this.enCaja,
    required this.referencia,
    this.marca,
    this.ultimos4,
    this.pagadoEn,
  });

  final int id;

  /// Se cobro en el mostrador de la agencia.
  final bool enCaja;
  final String referencia;
  final String? marca;
  final String? ultimos4;
  final DateTime? pagadoEn;
}

/// Ticket de una orden de servicio (V2-M02.06): mano de obra y refacciones con
/// sus importes, y los totales. Los precios traen el IVA incluido.
class TicketServicio {
  const TicketServicio({
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
    this.pago,
    this.pagable = false,
  });

  final int id;
  final int vehiculoId;
  final DateTime fecha;
  final DateTime? fechaCierre;
  final int kilometraje;
  final EstatusOrden estatus;
  final List<RenglonTicketServicio> manoDeObra;
  final List<RenglonTicketServicio> refacciones;
  final double totalManoDeObra;
  final double totalRefacciones;
  final double subtotal;
  final double iva;
  final double total;

  /// Puntos de lealtad que dio la orden al entregarse (V2-M12.02); nulo si no
  /// dio.
  final int? puntosGanados;

  /// Con que quedo pagada (V2-M08.02); nulo si no se ha pagado.
  final PagoDelTicket? pago;

  /// Se puede pagar en la app: viene del taller, esta lista o entregada, tiene
  /// total y nadie la ha pagado (V2-M08.02).
  final bool pagable;

  static const _centavo = 0.005;

  /// La mano de obra mas las refacciones dan el total, y cada renglon es su
  /// cantidad por su precio. Si algo no cuadra, la pantalla lo avisa.
  bool get cuadra {
    bool iguales(double a, double b) => (a - b).abs() < _centavo;
    double suma(List<RenglonTicketServicio> renglones) =>
        renglones.fold(0, (acumulado, r) => acumulado + r.importe);
    final renglonesCuadran = [
      ...manoDeObra,
      ...refacciones,
    ].every((r) => iguales(r.cantidad * r.precio, r.importe));
    return renglonesCuadran &&
        iguales(suma(manoDeObra), totalManoDeObra) &&
        iguales(suma(refacciones), totalRefacciones) &&
        iguales(totalManoDeObra + totalRefacciones, total) &&
        iguales(subtotal + iva, total);
  }

  /// Nombre del PDF al compartirlo.
  String get nombrePdf => 'ticket-$id.pdf';
}
