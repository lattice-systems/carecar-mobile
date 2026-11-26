import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'configuracion_teselas.dart';
import 'fuente_teselas.dart';
import 'geocodificador.dart';
import 'geocodificador_nativo.dart';
import 'proveedor_ubicacion.dart';
import 'ubicacion_geolocator.dart';

/// Posición del teléfono. Las pruebas la sustituyen con `UbicacionFalsa`.
final proveedorUbicacionProvider = Provider<ProveedorUbicacion>(
  (ref) => UbicacionGeolocator(),
  name: 'proveedorUbicacionProvider',
);

/// Dirección a coordenadas y al revés. Las pruebas usan `GeocodificadorFalso`.
final geocodificadorProvider = Provider<Geocodificador>(
  (ref) => GeocodificadorNativo(),
  name: 'geocodificadorProvider',
);

/// URL de teselas y atribución del build (ver [ConfiguracionTeselas]).
final configuracionTeselasProvider = Provider<ConfiguracionTeselas>(
  (ref) => ConfiguracionTeselas.delEntorno,
  name: 'configuracionTeselasProvider',
);

/// Nulo en la app: las teselas se descargan del servidor configurado. Las
/// pruebas de una pantalla con mapa lo sustituyen por `TeselasLisas`.
final fuenteTeselasProvider = Provider<FuenteTeselas?>(
  (ref) => null,
  name: 'fuenteTeselasProvider',
);
