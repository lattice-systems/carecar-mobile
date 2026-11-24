import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'coordenada.dart';
import 'errores_mapas.dart';
import 'proveedor_ubicacion.dart';

/// [ProveedorUbicacion] real sobre `geolocator`. Es el único archivo del
/// proyecto que lo importa junto con sus proveedores.
///
/// Solo primer plano: pide el permiso "cuando la app está en uso" y lee la
/// posición una vez; no hay flujo continuo ni permiso "siempre".
class UbicacionGeolocator implements ProveedorUbicacion {
  UbicacionGeolocator({GeolocatorPlatform? plataforma})
    : _plataforma = plataforma ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform _plataforma;

  @override
  Future<PermisoUbicacion> estadoDelPermiso() async =>
      _traducir(await _plataforma.checkPermission());

  @override
  Future<PermisoUbicacion> pedirPermiso() async =>
      _traducir(await _plataforma.requestPermission());

  @override
  Future<Coordenada> posicionActual({
    Duration limite = const Duration(seconds: 15),
  }) async {
    if (!await _plataforma.isLocationServiceEnabled()) {
      throw const UbicacionServicioApagado();
    }
    var permiso = await estadoDelPermiso();
    if (permiso == PermisoUbicacion.denegado) permiso = await pedirPermiso();
    switch (permiso) {
      case PermisoUbicacion.concedido:
        break;
      case PermisoUbicacion.denegado:
        throw const UbicacionPermisoDenegado();
      case PermisoUbicacion.denegadoParaSiempre:
        throw const UbicacionPermisoDenegadoParaSiempre();
    }
    try {
      final p = await _plataforma
          .getCurrentPosition(
            locationSettings: LocationSettings(timeLimit: limite),
          )
          .timeout(limite);
      return Coordenada(p.latitude, p.longitude);
    } on TimeoutException {
      throw const UbicacionTiempoAgotado();
    } on PermissionDeniedException {
      throw const UbicacionPermisoDenegado();
    } on LocationServiceDisabledException {
      throw const UbicacionServicioApagado();
    }
  }

  PermisoUbicacion _traducir(LocationPermission permiso) => switch (permiso) {
    LocationPermission.whileInUse ||
    LocationPermission.always => PermisoUbicacion.concedido,
    LocationPermission.deniedForever => PermisoUbicacion.denegadoParaSiempre,
    LocationPermission.denied ||
    LocationPermission.unableToDetermine => PermisoUbicacion.denegado,
  };
}
