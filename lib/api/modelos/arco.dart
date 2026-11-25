import 'comun.dart';

/// Una solicitud de derechos ARCO de esta cuenta (V2-M22.02,
/// `SolicitudArco`). Hoy la app pide el acceso: una copia de sus datos.
class SolicitudArco {
  const SolicitudArco({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.creadaEn,
    this.resueltaEn,
    this.venceEn,
  });

  factory SolicitudArco.fromJson(Map<String, Object?> json) => SolicitudArco(
    id: leerEntero(json['id'], 'id'),
    tipo: leerTexto(json['tipo'], 'tipo'),
    estado: leerTexto(json['estado'], 'estado'),
    creadaEn: leerMomentoUtc(json['creadaEn'], 'creadaEn'),
    resueltaEn: json['resueltaEn'] == null
        ? null
        : leerMomentoUtc(json['resueltaEn'], 'resueltaEn'),
    venceEn: json['venceEn'] == null
        ? null
        : leerMomentoUtc(json['venceEn'], 'venceEn'),
  );

  final int id;

  /// `ACCESO`, `RECTIFICACION`, `CANCELACION` u `OPOSICION`.
  final String tipo;

  /// `PENDIENTE`, `RESUELTA`, `FALLIDA` o `VENCIDA`.
  final String estado;
  final DateTime creadaEn;
  final DateTime? resueltaEn;

  /// Hasta cuándo se puede descargar el archivo.
  final DateTime? venceEn;
}
