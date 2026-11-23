import 'package:carecar_mobile/nucleo/mapas/coordenada.dart';
import 'package:carecar_mobile/nucleo/mapas/errores_mapas.dart';
import 'package:carecar_mobile/nucleo/mapas/geocodificador_nativo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  test('coordenadasDe usa el primer resultado', () async {
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async => [
        const Location(latitude: 19.4, longitude: -99.1),
        const Location(latitude: 0, longitude: 0),
      ],
      buscarDireccion: (la, lo) async => [],
    );
    expect(await g.coordenadasDe('Reforma 1'), const Coordenada(19.4, -99.1));
  });

  test('coordenadasDe sin resultados devuelve null', () async {
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async => throw const NoResultFoundException(),
      buscarDireccion: (la, lo) async => [],
    );
    expect(await g.coordenadasDe('???'), isNull);
  });

  test('coordenadasDe con texto vacío no consulta el servicio', () async {
    var consultas = 0;
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async {
        consultas++;
        return [];
      },
      buscarDireccion: (la, lo) async => [],
    );
    expect(await g.coordenadasDe('   '), isNull);
    expect(consultas, 0);
  });

  test('direccionDe arma el texto con calle, colonia, ciudad y estado', () async {
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async => [],
      buscarDireccion: (la, lo) async => [
        const Placemark(
          thoroughfare: 'Av. Reforma',
          subThoroughfare: '1',
          subLocality: 'Centro',
          locality: 'CDMX',
          administrativeArea: 'Ciudad de México',
          postalCode: '06000',
        ),
      ],
    );
    final d = await g.direccionDe(const Coordenada(19.4, -99.1));
    expect(d!.texto, 'Av. Reforma 1, Centro, CDMX, Ciudad de México, 06000');
    expect(d.calle, 'Av. Reforma 1');
    expect(d.colonia, 'Centro');
    expect(d.ciudad, 'CDMX');
    expect(d.estado, 'Ciudad de México');
    expect(d.codigoPostal, '06000');
  });

  test('direccionDe sin resultados devuelve null', () async {
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async => [],
      buscarDireccion: (la, lo) async => [],
    );
    expect(await g.direccionDe(const Coordenada(0, 0)), isNull);
  });

  test('cualquier otra falla del servicio es ErrorGeocodificacion', () async {
    final g = GeocodificadorNativo(
      buscarCoordenadas: (d) async => throw Exception('red'),
      buscarDireccion: (la, lo) async => throw Exception('red'),
    );
    await expectLater(
      g.coordenadasDe('Reforma'),
      throwsA(isA<ErrorGeocodificacion>()),
    );
    await expectLater(
      g.direccionDe(const Coordenada(1, 1)),
      throwsA(isA<ErrorGeocodificacion>()),
    );
  });
}
