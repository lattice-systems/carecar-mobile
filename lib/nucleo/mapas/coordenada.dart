import 'package:flutter/foundation.dart';

/// Punto en el mapa en grados decimales (WGS 84).
///
/// Es el tipo de punto de todo el app: los módulos no usan `LatLng` de
/// `latlong2` ni `Position` de `geolocator`, así cambiar de paquete no los toca.
@immutable
class Coordenada {
  const Coordenada(this.latitud, this.longitud);

  final double latitud;
  final double longitud;

  /// Falso si algún valor sale del rango geográfico o no es un número.
  bool get esValida =>
      latitud >= -90 && latitud <= 90 && longitud >= -180 && longitud <= 180;

  @override
  bool operator ==(Object other) =>
      other is Coordenada &&
      other.latitud == latitud &&
      other.longitud == longitud;

  @override
  int get hashCode => Object.hash(latitud, longitud);

  @override
  String toString() => 'Coordenada($latitud, $longitud)';
}
