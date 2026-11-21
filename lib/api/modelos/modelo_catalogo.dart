import 'comun.dart';

/// Modelo vigente del catalogo (APP-4.1).
///
/// Todos los campos salvo `modelo` son opcionales: el backend puede omitirlos.
class ModeloCatalogo {
  const ModeloCatalogo({
    required this.modelo,
    this.id,
    this.marca,
    this.anio,
    this.version,
    this.precioDesde,
    this.imagenUrl,
    this.descripcion,
  });

  factory ModeloCatalogo.fromJson(Map<String, Object?> json) => ModeloCatalogo(
    id: json['id'] == null ? null : leerEntero(json['id'], 'id'),
    modelo: leerTexto(json['modelo'], 'modelo'),
    marca: _texto(json['marca']),
    anio: json['anio'] == null ? null : leerEntero(json['anio'], 'anio'),
    version: _texto(json['version']),
    precioDesde: json['precioDesde'] == null
        ? null
        : leerDecimal(json['precioDesde'], 'precioDesde'),
    imagenUrl: _texto(json['imagenUrl']),
    descripcion: _texto(json['descripcion']),
  );

  static String? _texto(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  final int? id;
  final String modelo;
  final String? marca;
  final int? anio;
  final String? version;
  final double? precioDesde;
  final String? imagenUrl;
  final String? descripcion;
}
