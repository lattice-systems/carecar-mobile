import 'package:carecar_mobile/api/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig.para', () {
    test('acepta una direccion absoluta', () {
      final config = ApiConfig.para('http://localhost:3000/api/v1/app');
      expect(config.base.toString(), 'http://localhost:3000/api/v1/app');
    });

    test(
      'quita la diagonal final para no generar rutas con doble diagonal',
      () {
        final config = ApiConfig.para('http://localhost:3000/api/v1/app/');
        expect(
          config.ruta('/vehiculos').toString(),
          'http://localhost:3000/api/v1/app/vehiculos',
        );
      },
    );

    test('rechaza una direccion vacia explicando como pasarla', () {
      expect(
        () => ApiConfig.para(''),
        throwsA(
          isA<ApiConfigInvalida>().having(
            (e) => e.toString(),
            'mensaje',
            contains('--dart-define=API_URL'),
          ),
        ),
      );
    });

    test('rechaza una direccion sin esquema', () {
      expect(
        () => ApiConfig.para('localhost:3000'),
        throwsA(isA<ApiConfigInvalida>()),
      );
    });

    test('rechaza un esquema que no sea http o https', () {
      expect(
        () => ApiConfig.para('ftp://ejemplo.com'),
        throwsA(isA<ApiConfigInvalida>()),
      );
    });
  });

  group('ApiConfig.ruta', () {
    final config = ApiConfig.para('https://api.ejemplo.com/api/v1/app');

    test('arma una ruta simple', () {
      expect(
        config.ruta('/citas').toString(),
        'https://api.ejemplo.com/api/v1/app/citas',
      );
    });

    test('arma una ruta con parametros de consulta', () {
      final uri = config.ruta(
        '/agenda/disponibilidad',
        consulta: {'desde': '2026-10-20', 'hasta': '2026-10-22'},
      );
      expect(uri.path, '/api/v1/app/agenda/disponibilidad');
      expect(uri.queryParameters, {
        'desde': '2026-10-20',
        'hasta': '2026-10-22',
      });
    });

    test('omite los parametros nulos', () {
      final uri = config.ruta(
        '/citas',
        consulta: {'estado': null, 'desde': '2026-10-20'},
      );
      expect(uri.queryParameters, {'desde': '2026-10-20'});
    });

    test('escapa los valores de los parametros', () {
      final uri = config.ruta('/catalogo', consulta: {'q': 'Versa 2024'});
      expect(uri.query, contains('Versa+2024'));
    });
  });
}
