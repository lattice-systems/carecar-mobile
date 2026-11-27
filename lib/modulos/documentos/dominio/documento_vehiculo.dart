/// Tipos fijos de documento del vehiculo (V2-M09.01). Un valor que la app no
/// conoce se muestra como [otro] en vez de romper la lista.
enum TipoDocumento {
  poliza('POLIZA'),
  tarjetaCirculacion('TARJETA_CIRCULACION'),
  verificacion('VERIFICACION'),
  tenencia('TENENCIA'),
  licencia('LICENCIA'),
  garantia('GARANTIA'),
  factura('FACTURA'),
  otro('OTRO');

  const TipoDocumento(this.codigo);

  /// El valor del contrato.
  final String codigo;

  static TipoDocumento desde(String? codigo) => TipoDocumento.values.firstWhere(
    (tipo) => tipo.codigo == codigo,
    orElse: () => TipoDocumento.otro,
  );
}

/// Estado segun el vencimiento, calculado por el servidor con la fecha de la
/// agencia. Un valor desconocido cae en [sinFecha]: la app no afirma que algo
/// esta vigente ni vencido sin que el servidor lo diga.
enum EstadoDocumento {
  vigente('VIGENTE'),
  porVencer('POR_VENCER'),
  vencido('VENCIDO'),
  sinFecha('SIN_FECHA');

  const EstadoDocumento(this.codigo);

  final String codigo;

  static EstadoDocumento desde(String? codigo) =>
      EstadoDocumento.values.firstWhere(
        (estado) => estado.codigo == codigo,
        orElse: () => EstadoDocumento.sinFecha,
      );
}

/// Quien cargo el documento.
enum OrigenDocumento {
  cliente('CLIENTE'),
  agencia('AGENCIA');

  const OrigenDocumento(this.codigo);

  final String codigo;

  static OrigenDocumento desde(String? codigo) =>
      OrigenDocumento.values.firstWhere(
        (origen) => origen.codigo == codigo,
        orElse: () => OrigenDocumento.cliente,
      );
}

/// Un documento del vehiculo con su estado (`Documento` del contrato).
///
/// Dart puro. No trae la direccion del archivo: solo si lo tiene
/// ([tieneArchivo]); la descarga firmada llega con V2-M09.02.
class DocumentoVehiculo {
  const DocumentoVehiculo({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.estado,
    this.titulo,
    this.numero,
    this.emitidoEn,
    this.venceEn,
    this.diasRestantes,
    this.origen = OrigenDocumento.cliente,
    this.tieneArchivo = false,
    this.aseguradora,
    this.telefonoAseguradora,
  });

  final int id;
  final int vehiculoId;
  final TipoDocumento tipo;

  /// Nombre libre; siempre viene con [TipoDocumento.otro].
  final String? titulo;

  /// Folio o numero de poliza.
  final String? numero;
  final DateTime? emitidoEn;
  final DateTime? venceEn;
  final EstadoDocumento estado;

  /// Negativo si ya vencio; nulo sin fecha de vencimiento.
  final int? diasRestantes;
  final OrigenDocumento origen;
  final bool tieneArchivo;

  /// Solo en la poliza.
  final String? aseguradora;
  final String? telefonoAseguradora;
}
