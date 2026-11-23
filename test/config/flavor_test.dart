import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/config/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flavor', () {
    test('cada flavor tiene un nombre de app distinto', () {
      expect(Flavor.desarrollo.nombreApp, 'CareCar Dev');
      expect(Flavor.pruebas.nombreApp, 'CareCar Pruebas');
      expect(Flavor.produccion.nombreApp, 'CareCar');
    });

    test('el nombre del flavor coincide con el de Gradle y los schemes', () {
      expect(Flavor.values.map((f) => f.name), [
        'desarrollo',
        'pruebas',
        'produccion',
      ]);
    });

    test('solo desarrollo permite http en claro', () {
      expect(Flavor.desarrollo.permiteHttpEnClaro, isTrue);
      expect(Flavor.pruebas.permiteHttpEnClaro, isFalse);
      expect(Flavor.produccion.permiteHttpEnClaro, isFalse);
    });

    test('desarrollo apunta al mock local, con 10.0.2.2 en Android', () {
      expect(
        Flavor.desarrollo.urlPorOmision(esAndroid: true),
        'http://10.0.2.2:3000/api/v1/app',
      );
      expect(
        Flavor.desarrollo.urlPorOmision(esAndroid: false),
        'http://localhost:3000/api/v1/app',
      );
    });

    test('pruebas y produccion traen una direccion https por omision', () {
      for (final f in [Flavor.pruebas, Flavor.produccion]) {
        expect(f.urlPorOmision(esAndroid: true), startsWith('https://'));
      }
    });

    test('actual por omision es produccion (el mas restrictivo)', () {
      expect(Flavor.actual, Flavor.produccion);
    });
  });

  group('ApiConfig.resolver', () {
    test('sin sobrescritura usa la direccion del flavor', () {
      final c = ApiConfig.resolver(Flavor.desarrollo, esAndroid: false);
      expect(c.base.toString(), 'http://localhost:3000/api/v1/app');
    });

    test('API_BASE_URL sobrescribe la direccion del flavor', () {
      final c = ApiConfig.resolver(
        Flavor.pruebas,
        sobrescritura: 'https://pruebas.example.com/api/v1/app',
        esAndroid: false,
      );
      expect(c.base.host, 'pruebas.example.com');
    });

    test('pruebas y produccion rechazan http aunque lo pidan', () {
      for (final f in [Flavor.pruebas, Flavor.produccion]) {
        expect(
          () => ApiConfig.resolver(
            f,
            sobrescritura: 'http://10.0.2.2:3000/api/v1/app',
            esAndroid: true,
          ),
          throwsA(
            isA<ApiConfigInvalida>().having(
              (e) => e.toString(),
              'mensaje',
              contains('https'),
            ),
          ),
        );
      }
    });

    test('desarrollo acepta http y https', () {
      expect(
        ApiConfig.resolver(
          Flavor.desarrollo,
          sobrescritura: 'http://192.168.1.10:3000/api/v1/app',
          esAndroid: false,
        ).base.scheme,
        'http',
      );
      expect(
        ApiConfig.resolver(
          Flavor.desarrollo,
          sobrescritura: 'https://x.example.com/api',
          esAndroid: false,
        ).base.scheme,
        'https',
      );
    });
  });
}
