import 'package:flutter/foundation.dart';

import 'coordenada.dart';

/// Dirección legible de un punto. Todos los campos son opcionales porque el
/// geocodificador del sistema no siempre devuelve todos.
@immutable
class Direccion {
  const Direccion({
    required this.texto,
    this.calle,
    this.colonia,
    this.ciudad,
    this.estado,
    this.codigoPostal,
  });

  /// Dirección completa lista para mostrar.
  final String texto;
  final String? calle;
  final String? colonia;
  final String? ciudad;
  final String? estado;
  final String? codigoPostal;

  bool get vacia => texto.trim().isEmpty;

  @override
  bool operator ==(Object other) =>
      other is Direccion &&
      other.texto == texto &&
      other.calle == calle &&
      other.colonia == colonia &&
      other.ciudad == ciudad &&
      other.estado == estado &&
      other.codigoPostal == codigoPostal;

  @override
  int get hashCode =>
      Object.hash(texto, calle, colonia, ciudad, estado, codigoPostal);
}

/// Convierte entre direcciones y coordenadas (M17, M02, M16).
///
/// "Sin resultados" devuelve `null`; una falla del servicio lanza
/// [ErrorGeocodificacion].
abstract interface class Geocodificador {
  Future<Coordenada?> coordenadasDe(String direccion);

  Future<Direccion?> direccionDe(Coordenada coordenada);
}
