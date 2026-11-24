import 'package:geocoding/geocoding.dart';

import 'coordenada.dart';
import 'errores_mapas.dart';
import 'geocodificador.dart' as propio;

/// [propio.Geocodificador] real sobre `geocoding` (geocodificador del sistema:
/// sin llave ni costo, calidad variable; decisión 0006).
///
/// Las dos funciones de búsqueda se pueden inyectar para probar sin el sistema.
class GeocodificadorNativo implements propio.Geocodificador {
  GeocodificadorNativo({
    Future<List<Location>> Function(String direccion)? buscarCoordenadas,
    Future<List<Placemark>> Function(double latitud, double longitud)?
    buscarDireccion,
  }) : _buscarCoordenadas = buscarCoordenadas ?? _geocoding.locationFromAddress,
       _buscarDireccion =
           buscarDireccion ?? _geocoding.placemarkFromCoordinates;

  static final Geocoding _geocoding = Geocoding();

  final Future<List<Location>> Function(String) _buscarCoordenadas;
  final Future<List<Placemark>> Function(double, double) _buscarDireccion;

  @override
  Future<Coordenada?> coordenadasDe(String direccion) async {
    if (direccion.trim().isEmpty) return null;
    try {
      final resultados = await _buscarCoordenadas(direccion);
      if (resultados.isEmpty) return null;
      final r = resultados.first;
      return Coordenada(r.latitude, r.longitude);
    } catch (e) {
      throw ErrorGeocodificacion('No se pudo ubicar la dirección: $e');
    }
  }

  @override
  Future<propio.Direccion?> direccionDe(Coordenada coordenada) async {
    try {
      final resultados = await _buscarDireccion(
        coordenada.latitud,
        coordenada.longitud,
      );
      if (resultados.isEmpty) return null;
      return _aDireccion(resultados.first);
    } catch (e) {
      throw ErrorGeocodificacion('No se pudo leer la dirección: $e');
    }
  }

  propio.Direccion? _aDireccion(Placemark p) {
    String? limpio(String? v) => (v == null || v.trim().isEmpty) ? null : v;
    final calle = [
      limpio(p.thoroughfare),
      limpio(p.subThoroughfare),
    ].whereType<String>().join(' ');
    final colonia = limpio(p.subLocality);
    final ciudad = limpio(p.locality);
    final estado = limpio(p.administrativeArea);
    final cp = limpio(p.postalCode);
    final texto = [
      if (calle.isNotEmpty) calle,
      ?colonia,
      ?ciudad,
      ?estado,
      ?cp,
    ].join(', ');
    if (texto.isEmpty) return null;
    return propio.Direccion(
      texto: texto,
      calle: calle.isEmpty ? null : calle,
      colonia: colonia,
      ciudad: ciudad,
      estado: estado,
      codigoPostal: cp,
    );
  }
}
