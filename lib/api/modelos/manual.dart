import 'comun.dart';

/// Manual o ficha tecnica por modelo y anio (ADM-1).
///
/// Fuera del MVP: la lista puede venir vacia mientras no se carguen manuales.
class Manual {
  const Manual({
    required this.id,
    required this.modelo,
    required this.anio,
    required this.url,
    this.marca,
    this.titulo,
  });

  factory Manual.fromJson(Map<String, Object?> json) => Manual(
    id: leerEntero(json['id'], 'id'),
    modelo: leerTexto(json['modelo'], 'modelo'),
    anio: leerEntero(json['anio'], 'anio'),
    url: leerTexto(json['url'], 'url'),
    // El backend los manda aunque el contrato v1 no los nombra.
    marca: json['marca'] as String?,
    titulo: json['titulo'] as String?,
  );

  final int id;
  final String modelo;
  final int anio;

  /// Enlace para descargar el PDF. El contrato no dice si pide token:
  /// pregunta RIC-17.
  final String url;

  final String? marca;

  /// Nombre del documento, por ejemplo «Manual de propietario».
  final String? titulo;
}
