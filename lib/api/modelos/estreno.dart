import 'comun.dart';

/// Mensualidad estimada de un auto nuevo (V2-M16.02, `CotizacionEstreno`).
class CotizacionEstreno {
  const CotizacionEstreno({
    required this.precio,
    required this.enganche,
    required this.montoFinanciado,
    required this.tasaAnual,
    required this.plazoMeses,
    required this.mensualidad,
    required this.leyenda,
  });

  factory CotizacionEstreno.fromJson(Map<String, Object?> json) =>
      CotizacionEstreno(
        precio: leerDecimal(json['precio'], 'precio'),
        enganche: leerDecimal(json['enganche'], 'enganche'),
        montoFinanciado: leerDecimal(
          json['montoFinanciado'],
          'montoFinanciado',
        ),
        tasaAnual: leerDecimal(json['tasaAnual'], 'tasaAnual'),
        plazoMeses: leerEntero(json['plazoMeses'], 'plazoMeses'),
        mensualidad: leerDecimal(json['mensualidad'], 'mensualidad'),
        leyenda: leerTexto(json['leyenda'], 'leyenda'),
      );

  final double precio;
  final double enganche;
  final double montoFinanciado;
  final double tasaAnual;
  final int plazoMeses;
  final double mensualidad;
  final String leyenda;
}

/// Lo que se manda para pedir una prueba o una cotización (V2-M16.01).
class NuevaSolicitudEstreno {
  const NuevaSolicitudEstreno({
    required this.tipo,
    required this.modeloCatalogoId,
    this.preferenciaFecha,
    this.preferenciaFranja,
    this.enganche,
    this.plazoMeses,
    this.estimacionTomaCuentaId,
  });

  /// `PRUEBA_MANEJO` o `COTIZACION`.
  final String tipo;
  final int modeloCatalogoId;
  final DateTime? preferenciaFecha;

  /// `MANANA` o `TARDE`.
  final String? preferenciaFranja;
  final double? enganche;
  final int? plazoMeses;
  final int? estimacionTomaCuentaId;

  Map<String, Object?> toJson() => {
    'tipo': tipo,
    'modeloCatalogoId': modeloCatalogoId,
    if (preferenciaFecha != null)
      'preferenciaFecha': escribirFecha(preferenciaFecha!),
    'preferenciaFranja': ?preferenciaFranja,
    'enganche': ?enganche,
    'plazoMeses': ?plazoMeses,
    'estimacionTomaCuentaId': ?estimacionTomaCuentaId,
  };
}

/// Una solicitud de estreno con su estado (V2-M16.04).
class SolicitudEstreno {
  const SolicitudEstreno({
    required this.id,
    required this.tipo,
    required this.modeloCatalogoId,
    required this.modelo,
    required this.estado,
    required this.creadaEn,
    this.vendedor,
    this.preferenciaFecha,
    this.preferenciaFranja,
    this.cotizacion,
    this.estimacionTomaCuentaId,
  });

  factory SolicitudEstreno.fromJson(Map<String, Object?> json) =>
      SolicitudEstreno(
        id: leerEntero(json['id'], 'id'),
        tipo: leerTexto(json['tipo'], 'tipo'),
        modeloCatalogoId: leerEntero(
          json['modeloCatalogoId'],
          'modeloCatalogoId',
        ),
        modelo: leerTexto(json['modelo'], 'modelo'),
        estado: leerTexto(json['estado'], 'estado'),
        vendedor: json['vendedor'] as String?,
        preferenciaFecha: json['preferenciaFecha'] == null
            ? null
            : leerFecha(json['preferenciaFecha'], 'preferenciaFecha'),
        preferenciaFranja: json['preferenciaFranja'] as String?,
        cotizacion: json['cotizacion'] == null
            ? null
            : CotizacionEstreno.fromJson(
                json['cotizacion']! as Map<String, Object?>,
              ),
        estimacionTomaCuentaId: json['estimacionTomaCuentaId'] as int?,
        creadaEn: _leerMomento(json['creadaEn']),
      );

  final int id;
  final String tipo;
  final int modeloCatalogoId;
  final String modelo;

  /// `RECIBIDA`, `EN_ATENCION` o `CERRADA`.
  final String estado;
  final String? vendedor;
  final DateTime? preferenciaFecha;
  final String? preferenciaFranja;
  final CotizacionEstreno? cotizacion;
  final int? estimacionTomaCuentaId;
  final DateTime creadaEn;
}

/// Lee el `date-time` de creación; sin zona se toma como UTC, que es lo que
/// el contrato declara. Una fecha rota falla: no se inventa una.
DateTime _leerMomento(Object? valor) {
  final texto = leerTexto(valor, 'creadaEn');
  final momento = DateTime.tryParse(texto);
  if (momento == null) {
    throw FormatException('El campo «creadaEn» no es una fecha: $texto');
  }
  return momento.isUtc
      ? momento
      : DateTime.utc(
          momento.year,
          momento.month,
          momento.day,
          momento.hour,
          momento.minute,
          momento.second,
        );
}
