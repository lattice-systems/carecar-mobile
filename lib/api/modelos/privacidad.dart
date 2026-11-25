import 'comun.dart';

/// El aviso de privacidad vigente y si esta cuenta ya lo aceptó (V2-M22.01,
/// `AvisoPrivacidad`). Un aviso publicado no cambia: una versión nueva es otro
/// aviso con otro `id`.
class AvisoPrivacidad {
  const AvisoPrivacidad({
    required this.id,
    required this.version,
    required this.texto,
    required this.vigenteDesde,
    required this.aceptado,
    this.aceptadoEn,
  });

  factory AvisoPrivacidad.fromJson(Map<String, Object?> json) =>
      AvisoPrivacidad(
        id: leerEntero(json['id'], 'id'),
        version: leerEntero(json['version'], 'version'),
        texto: leerTexto(json['texto'], 'texto'),
        vigenteDesde: leerMomentoUtc(json['vigenteDesde'], 'vigenteDesde'),
        aceptado: leerBool(json['aceptado'], 'aceptado'),
        aceptadoEn: json['aceptadoEn'] == null
            ? null
            : leerMomentoUtc(json['aceptadoEn'], 'aceptadoEn'),
      );

  final int id;
  final int version;

  /// Texto completo; los párrafos van separados por una línea en blanco.
  final String texto;
  final DateTime vigenteDesde;

  /// Si esta cuenta ya aceptó esta versión.
  final bool aceptado;
  final DateTime? aceptadoEn;
}

/// La aceptación que el servidor registró (V2-M22.01, `AceptacionAviso`).
class AceptacionAviso {
  const AceptacionAviso({
    required this.avisoId,
    required this.version,
    required this.aceptadoEn,
  });

  factory AceptacionAviso.fromJson(Map<String, Object?> json) =>
      AceptacionAviso(
        avisoId: leerEntero(json['avisoId'], 'avisoId'),
        version: leerEntero(json['version'], 'version'),
        aceptadoEn: leerMomentoUtc(json['aceptadoEn'], 'aceptadoEn'),
      );

  final int avisoId;
  final int version;
  final DateTime aceptadoEn;
}
