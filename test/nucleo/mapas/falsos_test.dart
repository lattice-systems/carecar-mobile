import 'package:carecar_mobile/nucleo/mapas/coordenada.dart';
import 'package:carecar_mobile/nucleo/mapas/errores_mapas.dart';
import 'package:carecar_mobile/nucleo/mapas/falsos.dart';
import 'package:carecar_mobile/nucleo/mapas/geocodificador.dart';
import 'package:carecar_mobile/nucleo/mapas/proveedor_ubicacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UbicacionFalsa', () {
    test('devuelve la posición configurada', () async {
      final f = UbicacionFalsa(posicion: const Coordenada(1, 2));
      expect(await f.posicionActual(), const Coordenada(1, 2));
      expect(f.consultasDePosicion, 1);
    });

    test('lanza el error configurado', () {
      final f = UbicacionFalsa(error: const UbicacionServicioApagado());
      expect(f.posicionActual(), throwsA(isA<UbicacionServicioApagado>()));
    });

    test('pedirPermiso cambia el estado y cuenta la petición', () async {
      final f = UbicacionFalsa(
        permiso: PermisoUbicacion.denegado,
        permisoTrasPedir: PermisoUbicacion.concedido,
      );
      expect(await f.estadoDelPermiso(), PermisoUbicacion.denegado);
      expect(await f.pedirPermiso(), PermisoUbicacion.concedido);
      expect(await f.estadoDelPermiso(), PermisoUbicacion.concedido);
      expect(f.peticionesDePermiso, 1);
    });
  });

  group('GeocodificadorFalso', () {
    test('devuelve datos de las tablas configuradas', () async {
      const dir = Direccion(texto: 'Av. Reforma 1, Centro');
      final f = GeocodificadorFalso(
        coordenadasPorDireccion: {'Av. Reforma 1': const Coordenada(1, 2)},
        direccionesPorCoordenada: {const Coordenada(1, 2): dir},
      );
      expect(await f.coordenadasDe('Av. Reforma 1'), const Coordenada(1, 2));
      expect(await f.direccionDe(const Coordenada(1, 2)), dir);
    });

    test('sin coincidencia devuelve null, no lanza', () async {
      final f = GeocodificadorFalso();
      expect(await f.coordenadasDe('nada'), isNull);
      expect(await f.direccionDe(const Coordenada(0, 0)), isNull);
    });

    test('puede simular una falla del servicio', () {
      final f = GeocodificadorFalso(error: const ErrorGeocodificacion('x'));
      expect(f.coordenadasDe('x'), throwsA(isA<ErrorGeocodificacion>()));
      expect(
        f.direccionDe(const Coordenada(0, 0)),
        throwsA(isA<ErrorGeocodificacion>()),
      );
    });
  });

  test('Direccion.vacia es verdadero solo sin texto', () {
    expect(const Direccion(texto: '').vacia, isTrue);
    expect(const Direccion(texto: 'algo').vacia, isFalse);
  });
}
