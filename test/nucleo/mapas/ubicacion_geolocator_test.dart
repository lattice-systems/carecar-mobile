import 'dart:async';

import 'package:carecar_mobile/nucleo/mapas/coordenada.dart';
import 'package:carecar_mobile/nucleo/mapas/errores_mapas.dart';
import 'package:carecar_mobile/nucleo/mapas/proveedor_ubicacion.dart';
import 'package:carecar_mobile/nucleo/mapas/ubicacion_geolocator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class _PlataformaFalsa extends GeolocatorPlatform {
  LocationPermission permiso = LocationPermission.whileInUse;
  LocationPermission permisoTrasPedir = LocationPermission.whileInUse;
  bool servicio = true;
  Object? falla;
  int peticiones = 0;

  @override
  Future<LocationPermission> checkPermission() async => permiso;

  @override
  Future<LocationPermission> requestPermission() async {
    peticiones++;
    permiso = permisoTrasPedir;
    return permisoTrasPedir;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => servicio;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    if (falla != null) throw falla!;
    return Position(
      longitude: -99.13,
      latitude: 19.43,
      timestamp: DateTime(2026),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

void main() {
  late _PlataformaFalsa plataforma;
  late UbicacionGeolocator ubicacion;

  setUp(() {
    plataforma = _PlataformaFalsa();
    ubicacion = UbicacionGeolocator(plataforma: plataforma);
  });

  test('estadoDelPermiso traduce los permisos del paquete', () async {
    final casos = {
      LocationPermission.whileInUse: PermisoUbicacion.concedido,
      LocationPermission.always: PermisoUbicacion.concedido,
      LocationPermission.denied: PermisoUbicacion.denegado,
      LocationPermission.unableToDetermine: PermisoUbicacion.denegado,
      LocationPermission.deniedForever: PermisoUbicacion.denegadoParaSiempre,
    };
    for (final c in casos.entries) {
      plataforma.permiso = c.key;
      expect(await ubicacion.estadoDelPermiso(), c.value, reason: '${c.key}');
    }
  });

  test('pedirPermiso devuelve el resultado traducido', () async {
    plataforma.permiso = LocationPermission.denied;
    plataforma.permisoTrasPedir = LocationPermission.whileInUse;
    expect(await ubicacion.pedirPermiso(), PermisoUbicacion.concedido);
    expect(plataforma.peticiones, 1);
  });

  test('posicionActual devuelve la coordenada con permiso concedido', () async {
    expect(await ubicacion.posicionActual(), const Coordenada(19.43, -99.13));
    expect(plataforma.peticiones, 0);
  });

  test('si el permiso está denegado lo pide una vez antes de leer', () async {
    plataforma.permiso = LocationPermission.denied;
    expect(await ubicacion.posicionActual(), const Coordenada(19.43, -99.13));
    expect(plataforma.peticiones, 1);
  });

  test('servicio apagado lanza el error sin pedir permiso', () async {
    plataforma.servicio = false;
    plataforma.permiso = LocationPermission.denied;
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionServicioApagado>()),
    );
    expect(plataforma.peticiones, 0);
  });

  test('permiso que sigue denegado tras pedirlo lanza el error', () async {
    plataforma.permiso = LocationPermission.denied;
    plataforma.permisoTrasPedir = LocationPermission.denied;
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionPermisoDenegado>()),
    );
  });

  test('denegado para siempre no vuelve a pedir y lo avisa', () async {
    plataforma.permiso = LocationPermission.deniedForever;
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionPermisoDenegadoParaSiempre>()),
    );
    expect(plataforma.peticiones, 0);
  });

  test('el tiempo agotado del paquete se vuelve UbicacionTiempoAgotado', () async {
    plataforma.falla = TimeoutException('lento');
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionTiempoAgotado>()),
    );
  });

  test('las excepciones de permiso y servicio del paquete se traducen', () async {
    plataforma.falla = const PermissionDeniedException('no');
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionPermisoDenegado>()),
    );
    plataforma.falla = const LocationServiceDisabledException();
    await expectLater(
      ubicacion.posicionActual(),
      throwsA(isA<UbicacionServicioApagado>()),
    );
  });
}
