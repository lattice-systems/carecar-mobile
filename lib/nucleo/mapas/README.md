# `nucleo/mapas`

Ubicación, geocodificación y configuración de teselas (decisión [0006](../../../docs/decisiones/0006-mapas-y-geocodificacion.md)). Lo usan M11, M17, M02 y M16. El componente visual `Mapa` (V2-T02.09) vive en el sistema de diseño, en `lib/nucleo/diseno/componentes/mapa.dart`, no aquí.

**Regla:** los módulos importan solo `package:carecar_mobile/nucleo/mapas/mapas.dart`. Ningún módulo importa `flutter_map`, `geolocator`, `geocoding` ni `latlong2`; solo `ubicacion_geolocator.dart`, `geocodificador_nativo.dart` y el componente `Mapa` los tocan.

## API pública

| Pieza | Para qué |
| --- | --- |
| `Coordenada(latitud, longitud)` | Punto propio de la app (`esValida`). |
| `ProveedorUbicacion` | `estadoDelPermiso()`, `pedirPermiso()`, `posicionActual({limite})`. Solo primer plano, una lectura. |
| `PermisoUbicacion` | `concedido`, `denegado`, `denegadoParaSiempre`. |
| `ErrorUbicacion` (sellada) | `UbicacionPermisoDenegado`, `UbicacionPermisoDenegadoParaSiempre`, `UbicacionServicioApagado`, `UbicacionTiempoAgotado`. |
| `Geocodificador` | `coordenadasDe(texto)` y `direccionDe(coordenada)`; sin resultados es `null`. |
| `Direccion` | `texto`, `calle`, `colonia`, `ciudad`, `estado`, `codigoPostal`. |
| `ErrorGeocodificacion` | Falla del servicio (sin red, sin geocoder del sistema). |
| `ConfiguracionTeselas` | `urlPlantilla`, `atribucion`, `esProduccion`. |
| `proveedorUbicacionProvider`, `geocodificadorProvider`, `configuracionTeselasProvider` | Riverpod; se sustituyen con `overrideWithValue`. |
| `FuenteTeselas`, `fuenteTeselasProvider` | Teselas que no salen de la red. En la app el proveedor es nulo. |
| `TeselasLisas`, `TeselasSinConexion` | Fakes de teselas: cuadros de un color y falta de conexión. |
| `UbicacionFalsa`, `GeocodificadorFalso` | Fakes para pruebas (contadores, errores y permisos configurables). |

## Teselas

Sin definiciones, desarrollo usa el servidor público de OpenStreetMap con tráfico mínimo. Para otro proveedor:

```bash
flutter run --dart-define=TILES_URL='https://.../{z}/{x}/{y}.png' --dart-define=TILES_ATTRIBUTION='© Proveedor'
```

`ConfiguracionTeselas.delEntorno` lee esos valores; con `--dart-define=TILES_PRODUCTION=true` y sin `TILES_URL` lanza `StateError` (OSM público no se puede usar en producción). `configuracionTeselasProvider` entrega ese valor.

`cliente_teselas.dart` es interno: lo usa `Mapa` para que un error de descarga no lleve la dirección de la tesela a la consola.

## Permisos nativos

Solo ubicación en primer plano: `ACCESS_FINE_LOCATION` y `ACCESS_COARSE_LOCATION` en Android, `NSLocationWhenInUseUsageDescription` en iOS. Nada de segundo plano.

## Prueba de ejemplo

```dart
final c = ProviderContainer(overrides: [
  proveedorUbicacionProvider.overrideWithValue(
    UbicacionFalsa(error: const UbicacionServicioApagado()),
  ),
]);
```
