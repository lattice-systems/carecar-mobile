import '../../../api/modelos/comun.dart';
import '../dominio/pagos.dart';

/// Lee `Pago`, `MetodoPago`, el ticket (`ServicioDetalle`) y lo que se cobra
/// del pedido de la tienda (`Pedido`) del contrato. Lanza [FormatException] si
/// falta algo obligatorio.
class LecturaPagos {
  const LecturaPagos();

  Pago pago(Map<String, Object?> json) => Pago(
    id: leerEntero(json['id'], 'id'),
    ordenId: leerEnteroOpcional(json['ordenId'], 'ordenId'),
    pedidoId: leerEnteroOpcional(json['pedidoId'], 'pedidoId'),
    vehiculoId: leerEnteroOpcional(json['vehiculoId'], 'vehiculoId'),
    monto: leerDecimal(json['monto'], 'monto'),
    medio: MedioPago.desde(json['medio'] as String?),
    marca: json['marca'] as String?,
    ultimos4: json['ultimos4'] as String?,
    tipoTarjeta: TipoTarjeta.desde(json['tipoTarjeta'] as String?),
    estado: EstadoPago.desde(json['estado'] as String?),
    motivoFallo: MotivoFalloPago.desde(json['motivoFallo'] as String?),
    requiereAutenticacion: leerBool(
      json['requiereAutenticacion'],
      'requiereAutenticacion',
    ),
    referencia: leerTexto(json['referencia'], 'referencia'),
    simulado: leerBool(json['simulado'], 'simulado'),
    metodoPagoId: leerEnteroOpcional(json['metodoPagoId'], 'metodoPagoId'),
    perfilFiscalId: leerEnteroOpcional(
      json['perfilFiscalId'],
      'perfilFiscalId',
    ),
    pagadoEn: json['pagadoEn'] == null
        ? null
        : leerMomentoUtc(json['pagadoEn'], 'pagadoEn'),
    creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
  );

  MetodoPago metodo(Map<String, Object?> json) => MetodoPago(
    id: leerEntero(json['id'], 'id'),
    marca: leerTexto(json['marca'], 'marca'),
    ultimos4: leerTexto(json['ultimos4'], 'ultimos4'),
    tipo: TipoTarjeta.desde(json['tipo'] as String?),
    mesVence: leerEntero(json['mesVence'], 'mesVence'),
    anioVence: leerEntero(json['anioVence'], 'anioVence'),
    vencida: leerBool(json['vencida'], 'vencida'),
    predeterminado: leerBool(json['predeterminado'], 'predeterminado'),
  );

  OrdenPorPagar orden(Map<String, Object?> json) {
    final pago = json['pago'];
    return OrdenPorPagar(
      ordenId: leerEntero(json['id'], 'id'),
      vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
      fecha: leerFecha(json['fecha'], 'fecha'),
      totalManoDeObra: leerDecimal(json['totalManoDeObra'], 'totalManoDeObra'),
      totalRefacciones: leerDecimal(
        json['totalRefacciones'],
        'totalRefacciones',
      ),
      subtotal: leerDecimal(json['subtotal'], 'subtotal'),
      iva: leerDecimal(json['iva'], 'iva'),
      total: leerDecimal(json['total'], 'total'),
      pagable: json['pagable'] == true,
      pago: pago is Map ? this.pago(pago.cast<String, Object?>()) : null,
    );
  }

  /// Solo lo que se cobra del `Pedido` de la tienda (V2-M14.04).
  PedidoPorPagar pedido(Map<String, Object?> json) {
    final pago = json['pago'];
    return PedidoPorPagar(
      pedidoId: leerEntero(json['id'], 'id'),
      total: leerDecimal(json['total'], 'total'),
      pagable: json['pagable'] == true,
      pago: pago is Map ? this.pago(pago.cast<String, Object?>()) : null,
    );
  }
}
