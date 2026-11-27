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

/// Un intento de pagar una orden (V2-M08.02 y V2-M08.07). Nunca trae el
/// numero de la tarjeta.
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
  });

  final int id;
  final int ordenId;
  final int vehiculoId;

  /// Total de la orden con IVA, en pesos.
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

/// Lo que se cobra de una orden, leido de su ticket: el desglose, si se puede
/// pagar en la app y, si ya se pago, con que.
class OrdenPorPagar {
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
  final double total;
  final bool pagable;
  final Pago? pago;
}

/// Con que quiere pagar la persona: una tarjeta de prueba nueva o una
/// guardada.
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

/// Por que el servidor no tomo el pago.
enum MotivoRechazoPago { ordenNoPagable, pagoEnCurso, pagoNoPendiente }

/// El servidor no tomo el pago por una regla (409).
class PagoRechazado implements Exception {
  const PagoRechazado(this.motivo, [this.mensaje]);

  final MotivoRechazoPago motivo;
  final String? mensaje;

  @override
  String toString() => 'PagoRechazado($motivo)';
}
