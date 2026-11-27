/// Estado de un pago (V2-M08.02). Nace pendiente y queda pagado o fallido;
/// reembolsado lo pone la agencia.
enum EstadoPago {
  pendiente('PENDIENTE'),
  pagado('PAGADO'),
  fallido('FALLIDO'),
  reembolsado('REEMBOLSADO');

  const EstadoPago(this.enLaApi);

  final String enLaApi;

  static EstadoPago desde(String? valor) => values.firstWhere(
    (e) => e.enLaApi == valor,
    orElse: () => throw FormatException('Estado de pago desconocido: $valor'),
  );
}

/// Con que se pago: tarjeta, billetera simulada o en caja.
enum MedioPago {
  tarjeta('TARJETA'),
  applePay('APPLE_PAY'),
  googlePay('GOOGLE_PAY'),
  caja('CAJA');

  const MedioPago(this.enLaApi);

  final String enLaApi;

  static MedioPago desde(String? valor) => values.firstWhere(
    (e) => e.enLaApi == valor,
    orElse: () => throw FormatException('Medio de pago desconocido: $valor'),
  );
}

/// Por que no se cobro. `otro` cubre uno que esta version aun no conoce.
enum MotivoFalloPago {
  fondosInsuficientes('FONDOS_INSUFICIENTES'),
  autenticacionFallida('AUTENTICACION_FALLIDA'),
  autenticacionVencida('AUTENTICACION_VENCIDA'),
  pagadaEnCaja('PAGADA_EN_CAJA'),
  otro('');

  const MotivoFalloPago(this.enLaApi);

  final String enLaApi;

  static MotivoFalloPago? desde(String? valor) {
    if (valor == null) return null;
    return values.firstWhere(
      (m) => m != otro && m.enLaApi == valor,
      orElse: () => otro,
    );
  }
}

/// Credito o debito.
enum TipoTarjeta {
  credito('CREDITO'),
  debito('DEBITO');

  const TipoTarjeta(this.enLaApi);

  final String enLaApi;

  static TipoTarjeta? desde(String? valor) {
    for (final tipo in values) {
      if (tipo.enLaApi == valor) return tipo;
    }
    return null;
  }
}

/// Un intento de pagar una orden (V2-M08.02 y V2-M08.07) o un pedido de la
/// tienda (V2-M14.04). Nunca trae el numero de la tarjeta.
class Pago {
  const Pago({
    required this.id,
    required this.ordenId,
    required this.vehiculoId,
    required this.monto,
    required this.medio,
    required this.estado,
    required this.requiereAutenticacion,
    required this.referencia,
    required this.simulado,
    required this.creadoEn,
    this.marca,
    this.ultimos4,
    this.tipoTarjeta,
    this.motivoFallo,
    this.metodoPagoId,
    this.perfilFiscalId,
    this.pagadoEn,
    this.pedidoId,
    this.factura,
    this.facturable = false,
  });

  final int id;

  /// La orden pagada. Nula si el pago es de un pedido de la tienda.
  final int? ordenId;

  /// El pedido de la tienda pagado (V2-M14.04). Nulo si es de una orden.
  final int? pedidoId;

  /// El vehiculo de la orden. Un pedido de la tienda puede no traerlo.
  final int? vehiculoId;

  /// Total de la orden con IVA o del pedido, en pesos.
  final double monto;
  final MedioPago medio;
  final String? marca;
  final String? ultimos4;
  final TipoTarjeta? tipoTarjeta;
  final EstadoPago estado;
  final MotivoFalloPago? motivoFallo;

  /// Sigue pendiente porque el banco simulado pide confirmar (3-D Secure).
  final bool requiereAutenticacion;

  /// Folio del procesador simulado o de caja.
  final String referencia;

  /// Lo cobro el procesador simulado; falso si se pago en caja.
  final bool simulado;
  final int? metodoPagoId;
  final int? perfilFiscalId;
  final DateTime? pagadoEn;
  final DateTime creadoEn;

  /// La factura timbrada del pago (V2-M08.06); nula si aun no tiene.
  final Factura? factura;

  /// Se puede facturar desde la app: pagado, no en caja y sin factura.
  final bool facturable;
}

/// La factura simulada de un pago (V2-M08.06): sin validez fiscal (ADR 0009).
class Factura {
  const Factura({
    required this.id,
    required this.pagoId,
    required this.folio,
    required this.uuid,
    required this.rfcReceptor,
    required this.razonSocialReceptor,
    required this.usoCfdi,
    required this.total,
    required this.timbradaEn,
  });

  final int id;
  final int pagoId;

  /// Serie y folio, por ejemplo `A-000124`.
  final String folio;

  /// Folio fiscal del timbre simulado.
  final String uuid;
  final String rfcReceptor;
  final String razonSocialReceptor;
  final String usoCfdi;
  final double total;
  final DateTime timbradaEn;
}

/// En que formato se descarga una factura.
enum FormatoFactura {
  pdf('pdf', 'application/pdf'),
  xml('xml', 'application/xml');

  const FormatoFactura(this.extension, this.tipoContenido);

  final String extension;
  final String tipoContenido;
}

/// El PDF o el XML de una factura, listo para compartir.
class ArchivoFactura {
  const ArchivoFactura({
    required this.bytes,
    required this.nombre,
    required this.formato,
  });

  final List<int> bytes;

  /// `factura-A-000124.pdf`
  final String nombre;
  final FormatoFactura formato;
}

/// Por que el servidor no tomo la factura (409).
enum MotivoRechazoFactura { yaFacturado, pagoNoFacturable }

/// El servidor no facturo el pago por una regla (409).
class FacturaRechazada implements Exception {
  const FacturaRechazada(this.motivo);

  final MotivoRechazoFactura motivo;

  @override
  String toString() => 'FacturaRechazada($motivo)';
}

/// El timbrado simulado rechazo los datos fiscales (422
/// `TIMBRADO_RECHAZADO`): [campos] dice que corregir del perfil fiscal, con el
/// nombre del campo del contrato (`razonSocial`, `codigoPostal`...).
class TimbradoRechazado implements Exception {
  const TimbradoRechazado(this.campos);

  final Set<String> campos;

  @override
  String toString() => 'TimbradoRechazado($campos)';
}

/// Una pagina de mis pagos, del mas nuevo al mas viejo.
class PaginaPagos {
  const PaginaPagos({
    required this.pagos,
    required this.pagina,
    required this.hayMas,
  });

  final List<Pago> pagos;
  final int pagina;
  final bool hayMas;
}

/// Una tarjeta guardada (V2-M08.04): marca, ultimos 4 y vencimiento.
class MetodoPago {
  const MetodoPago({
    required this.id,
    required this.marca,
    required this.ultimos4,
    required this.tipo,
    required this.mesVence,
    required this.anioVence,
    required this.vencida,
    required this.predeterminado,
  });

  final int id;
  final String marca;
  final String ultimos4;
  final TipoTarjeta? tipo;
  final int mesVence;
  final int anioVence;
  final bool vencida;
  final bool predeterminado;
}

/// Lo que se cobra en la app: una orden de servicio (V2-M08.02) o un pedido
/// de la tienda (V2-M14.04). La pantalla de pago es la misma para los dos.
sealed class ObjetivoCobro {
  const ObjetivoCobro();

  double get total;

  bool get pagable;

  /// El pago con que quedo pagado, si ya se pago.
  Pago? get pago;
}

/// Lo que se cobra de una orden, leido de su ticket: el desglose, si se puede
/// pagar en la app y, si ya se pago, con que.
class OrdenPorPagar extends ObjetivoCobro {
  const OrdenPorPagar({
    required this.ordenId,
    required this.vehiculoId,
    required this.fecha,
    required this.totalManoDeObra,
    required this.totalRefacciones,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.pagable,
    this.pago,
  });

  final int ordenId;
  final int vehiculoId;
  final DateTime fecha;
  final double totalManoDeObra;
  final double totalRefacciones;
  final double subtotal;
  final double iva;
  @override
  final double total;
  @override
  final bool pagable;
  @override
  final Pago? pago;
}

/// Lo que se cobra de un pedido de la tienda (V2-M14.04), leido del pedido:
/// el total de sus renglones, si se puede pagar en la app y, si ya se pago,
/// con que.
class PedidoPorPagar extends ObjetivoCobro {
  const PedidoPorPagar({
    required this.pedidoId,
    required this.total,
    required this.pagable,
    this.pago,
  });

  final int pedidoId;
  @override
  final double total;
  @override
  final bool pagable;
  @override
  final Pago? pago;
}

/// Con que quiere pagar la persona: una tarjeta de prueba nueva, una
/// guardada o una billetera simulada.
sealed class MedioElegido {
  const MedioElegido();
}

/// Una tarjeta nueva ya convertida en token por la pasarela: el numero nunca
/// sale del telefono.
class TarjetaNueva extends MedioElegido {
  const TarjetaNueva({
    required this.token,
    required this.mesVence,
    required this.anioVence,
    required this.guardar,
  });

  final String token;
  final int mesVence;
  final int anioVence;
  final bool guardar;
}

class TarjetaGuardada extends MedioElegido {
  const TarjetaGuardada(this.metodoPagoId);

  final int metodoPagoId;
}

/// Apple Pay o Google Pay simulados (V2-M08.03): no usan la billetera del
/// telefono ni piden cuentas.
class Billetera extends MedioElegido {
  const Billetera(this.medio)
    : assert(medio == MedioPago.applePay || medio == MedioPago.googlePay);

  final MedioPago medio;
}

/// Por que el servidor no tomo el pago.
enum MotivoRechazoPago {
  ordenNoPagable,
  pagoEnCurso,
  pagoNoPendiente,

  /// V2-M14.04: el pedido ya no se puede pagar en la app.
  pedidoNoPagable,
}

/// El servidor no tomo el pago por una regla (409).
class PagoRechazado implements Exception {
  const PagoRechazado(this.motivo, [this.mensaje]);

  final MotivoRechazoPago motivo;
  final String? mensaje;

  @override
  String toString() => 'PagoRechazado($motivo)';
}
