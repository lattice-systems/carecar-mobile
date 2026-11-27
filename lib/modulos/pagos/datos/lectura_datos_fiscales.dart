import '../../../api/modelos/comun.dart';
import '../dominio/datos_fiscales.dart';

/// Lee `CatalogoFiscal` y `PerfilFiscal` del contrato. Lanza [FormatException]
/// si falta algo obligatorio.
class LecturaDatosFiscales {
  const LecturaDatosFiscales();

  CatalogoFiscal catalogo(Map<String, Object?> json) => CatalogoFiscal(
    regimenes: _lista(json['regimenes'], 'regimenes', _regimen),
    usosCfdi: _lista(json['usosCfdi'], 'usosCfdi', _uso),
  );

  PerfilFiscal perfil(Map<String, Object?> json) => PerfilFiscal(
    id: leerEntero(json['id'], 'id'),
    rfc: leerTexto(json['rfc'], 'rfc'),
    tipoPersona: TipoPersona.desde(json['tipoPersona'] as String?),
    razonSocial: leerTexto(json['razonSocial'], 'razonSocial'),
    regimenFiscal: leerTexto(json['regimenFiscal'], 'regimenFiscal'),
    codigoPostal: leerTexto(json['codigoPostal'], 'codigoPostal'),
    usoCfdi: leerTexto(json['usoCfdi'], 'usoCfdi'),
    correo: json['correo'] as String?,
    predeterminado: leerBool(json['predeterminado'], 'predeterminado'),
    creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
  );

  RegimenFiscal _regimen(Map<String, Object?> json) => RegimenFiscal(
    clave: leerTexto(json['clave'], 'clave'),
    descripcion: leerTexto(json['descripcion'], 'descripcion'),
    fisica: leerBool(json['fisica'], 'fisica'),
    moral: leerBool(json['moral'], 'moral'),
  );

  UsoCfdi _uso(Map<String, Object?> json) {
    final regimenes = json['regimenes'];
    if (regimenes is! List) {
      throw const FormatException('El campo «regimenes» no es una lista');
    }
    return UsoCfdi(
      clave: leerTexto(json['clave'], 'clave'),
      descripcion: leerTexto(json['descripcion'], 'descripcion'),
      fisica: leerBool(json['fisica'], 'fisica'),
      moral: leerBool(json['moral'], 'moral'),
      regimenes: {for (final r in regimenes) leerTexto(r, 'regimenes')},
    );
  }

  static List<T> _lista<T>(
    Object? valor,
    String campo,
    T Function(Map<String, Object?>) leer,
  ) {
    if (valor is! List) {
      throw FormatException('El campo «$campo» no es una lista');
    }
    return [for (final e in valor) leer((e as Map).cast<String, Object?>())];
  }
}
