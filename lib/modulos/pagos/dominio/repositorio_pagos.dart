import 'pagos.dart';

/// Pagos de ordenes y de pedidos de la tienda, mis pagos, tarjetas guardadas
/// y facturas (V2-M08.02, V2-M08.03, V2-M08.04, V2-M08.06, V2-M08.07 y
/// V2-M14.04). Las excepciones de la API pasan tal cual, salvo los 409 de
/// pagos, que llegan como [PagoRechazado], los 409 de facturas, como
/// [FacturaRechazada], y el 422 del timbrado, como [TimbradoRechazado].
abstract interface class RepositorioPagos {
  /// El desglose de la orden y si se puede pagar, de su ticket.
  Future<OrdenPorPagar> orden(int ordenId);

  /// Cobra la orden. La misma [llave] devuelve el mismo intento y no cobra
  /// otra vez.
  Future<Pago> pagar(
    int ordenId, {
    required String llave,
    required MedioElegido medio,
    int? perfilFiscalId,
  });

  /// El total del pedido de la tienda y si se puede pagar (V2-M14.04).
  Future<PedidoPorPagar> pedido(int pedidoId);

  /// Cobra el pedido de la tienda con las mismas reglas que una orden: la
  /// misma [llave] devuelve el mismo intento y no cobra otra vez (V2-M14.04).
  Future<Pago> pagarPedido(
    int pedidoId, {
    required String llave,
    required MedioElegido medio,
    int? perfilFiscalId,
  });

  /// Lo que la persona respondio en la pantalla simulada de su banco.
  Future<Pago> autenticar(int pagoId, {required bool confirmada});

  Future<Pago> pago(int pagoId);

  Future<PaginaPagos> pagos({int pagina = 0, int tamano = 20});

  Future<List<MetodoPago>> metodos();

  Future<MetodoPago> predeterminar(int metodoPagoId);

  Future<void> borrarMetodo(int metodoPagoId);

  /// Timbra la factura del pago con esos datos fiscales (V2-M08.06).
  Future<Factura> facturar(int pagoId, {required int perfilFiscalId});

  /// El PDF o el XML de la factura.
  Future<ArchivoFactura> descargarFactura(
    Factura factura,
    FormatoFactura formato,
  );
}
