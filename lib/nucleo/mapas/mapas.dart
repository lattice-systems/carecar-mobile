/// API pública de `nucleo/mapas`. Los módulos importan solo este archivo; nunca
/// `flutter_map`, `geolocator`, `geocoding` ni `latlong2` (decisión 0006).
library;

export 'configuracion_teselas.dart';
export 'coordenada.dart';
export 'errores_mapas.dart';
export 'falsos.dart';
export 'geocodificador.dart';
export 'proveedor_ubicacion.dart';
export 'proveedores_mapas.dart';
