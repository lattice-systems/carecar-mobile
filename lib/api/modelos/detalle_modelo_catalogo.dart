import 'comun.dart';
import 'modelo_catalogo.dart';

/// Un modelo del catalogo con su galeria, sus versiones y su ficha resumida
/// (`DetalleModeloCatalogo`, V2-M03.02).
///
/// Las tres listas pueden venir vacias mientras la agencia no las capture, y
/// si el backend las omite se leen como vacias.
class DetalleModeloCatalogo {
  const DetalleModeloCatalogo({
    required this.modelo,
    this.imagenes = const [],
    this.versiones = const [],
    this.especificaciones = const [],
  });

  factory DetalleModeloCatalogo.fromJson(Map<String, Object?> json) =>
      DetalleModeloCatalogo(
        modelo: ModeloCatalogo.fromJson(json),
        imagenes: _lista(json['imagenes'], ImagenModeloCatalogo.fromJson),
        versiones: _lista(json['versiones'], VersionModelo.fromJson),
        especificaciones: _lista(
          json['especificaciones'],
          EspecificacionModelo.fromJson,
        ),
      );

  /// Los datos del propio modelo, los mismos que trae `GET /catalogo`.
  final ModeloCatalogo modelo;

  /// Galeria, ya ordenada por `orden`.
  final List<ImagenModeloCatalogo> imagenes;

  /// Versiones activas de la misma marca, modelo y anio.
  final List<VersionModelo> versiones;

  /// Ficha resumida, ya ordenada por `orden`.
  final List<EspecificacionModelo> especificaciones;

  Map<String, Object?> toJson() => {
    ...modelo.toJson(),
    'imagenes': [for (final i in imagenes) i.toJson()],
    'versiones': [for (final v in versiones) v.toJson()],
    'especificaciones': [for (final e in especificaciones) e.toJson()],
  };
}

List<T> _lista<T>(Object? json, T Function(Map<String, Object?>) leer) {
  if (json is! List) return const [];
  final elementos = [
    for (final e in json)
      if (e is Map) leer(e.cast<String, Object?>()),
  ];
  return List.unmodifiable(elementos);
}

String? _texto(Object? v) {
  if (v is! String) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

/// Una foto de la galeria (`ImagenModelo` del contrato).
class ImagenModeloCatalogo {
  const ImagenModeloCatalogo({
    required this.id,
    required this.url,
    required this.orden,
    this.color,
    this.descripcion,
  });

  factory ImagenModeloCatalogo.fromJson(Map<String, Object?> json) =>
      ImagenModeloCatalogo(
        id: leerEntero(json['id'], 'id'),
        url: leerTexto(json['url'], 'url'),
        orden: leerEntero(json['orden'], 'orden'),
        color: _texto(json['color']),
        descripcion: _texto(json['descripcion']),
      );

  final int id;
  final String url;
  final int orden;

  /// Color del auto en la foto.
  final String? color;

  /// Texto para el lector de pantalla.
  final String? descripcion;

  Map<String, Object?> toJson() => {
    'id': id,
    'url': url,
    'orden': orden,
    'color': color,
    'descripcion': descripcion,
  };
}

/// Una version que se vende del mismo modelo (`VersionModelo`).
class VersionModelo {
  const VersionModelo({
    required this.id,
    required this.nombre,
    this.precioDesde,
  });

  factory VersionModelo.fromJson(Map<String, Object?> json) => VersionModelo(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    precioDesde: json['precioDesde'] == null
        ? null
        : leerDecimal(json['precioDesde'], 'precioDesde'),
  );

  /// Id del modelo del catalogo de esa version.
  final int id;
  final String nombre;
  final double? precioDesde;

  Map<String, Object?> toJson() => {
    'id': id,
    'nombre': nombre,
    'precioDesde': precioDesde,
  };
}

/// Un dato de la ficha resumida (`EspecificacionModelo`).
class EspecificacionModelo {
  const EspecificacionModelo({
    required this.etiqueta,
    required this.valor,
    this.orden = 0,
  });

  factory EspecificacionModelo.fromJson(Map<String, Object?> json) =>
      EspecificacionModelo(
        etiqueta: leerTexto(json['etiqueta'], 'etiqueta'),
        valor: leerTexto(json['valor'], 'valor'),
        orden: json['orden'] == null ? 0 : leerEntero(json['orden'], 'orden'),
      );

  final String etiqueta;
  final String valor;
  final int orden;

  Map<String, Object?> toJson() => {
    'etiqueta': etiqueta,
    'valor': valor,
    'orden': orden,
  };
}
