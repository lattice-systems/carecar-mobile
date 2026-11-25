import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_api.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/fallos_bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _json = {'content-type': 'application/json'};

const _gastoJson = {
  'id': 9,
  'vehiculoId': 4,
  'tipo': 'gasolina',
  'monto': 850,
  'litros': 35.4,
  'km': 12500,
  'fecha': '2026-11-20',
  'descripcion': null,
};

http.Response _problema(int status, [String? codigo]) => http.Response(
  jsonEncode({
    'timestamp': 't',
    'status': status,
    'error': 'Error',
    'message': 'mensaje',
    'path': '/p',
    'codigo': ?codigo,
  }),
  status,
  headers: _json,
);

final _carga = BorradorGasto(
  tipo: TipoGasto.gasolina,
  monto: 850,
  litros: 35.4,
  km: 12500,
  fecha: DateTime(2026, 11, 20),
);

({RepositorioBitacoraApi repo, List<http.Request> pedidas}) _api(
  http.Response Function(http.Request) responder,
) {
  final pedidas = <http.Request>[];
  final cliente = ClienteApi(
    config: ApiConfig.para('http://localhost:3000/api/v1/app'),
    http: MockClient((req) async {
      pedidas.add(req);
      return responder(req);
    }),
  );
  return (repo: RepositorioBitacoraApi(cliente), pedidas: pedidas);
}

void main() {
  group('RepositorioBitacoraApi', () {
    test(
      'gastos lee todas las páginas de GET /vehiculos/{id}/gastos',
      () async {
        final api = _api((req) {
          final pagina = int.parse(req.url.queryParameters['pagina']!);
          return http.Response(
            jsonEncode({
              'contenido': [
                {..._gastoJson, 'id': pagina + 1},
              ],
              'pagina': pagina,
              'totalPaginas': 2,
            }),
            200,
            headers: _json,
          );
        });
        final gastos = await api.repo.gastos(4);
        expect(gastos.map((g) => g.id), [1, 2]);
        expect(api.pedidas, hasLength(2));
        expect(api.pedidas.first.url.path, endsWith('/vehiculos/4/gastos'));
        final g = gastos.first;
        expect(g.tipo, TipoGasto.gasolina);
        expect(g.monto, 850);
        expect(g.litros, 35.4);
        expect(g.km, 12500);
        expect(g.fecha, DateTime(2026, 11, 20));
        expect(g.descripcion, isNull);
      },
    );

    test('registrar manda NuevoGasto con la fecha ISO', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_gastoJson), 201, headers: _json),
      );
      final creado = await api.repo.registrar(4, _carga);
      expect(creado.id, 9);
      final req = api.pedidas.single;
      expect(req.method, 'POST');
      expect(req.url.path, endsWith('/vehiculos/4/gastos'));
      expect(jsonDecode(req.body), {
        'tipo': 'gasolina',
        'monto': 850,
        'litros': 35.4,
        'km': 12500,
        'fecha': '2026-11-20',
      });
    });

    test('un gasto que no es gasolina no manda litros ni km', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_gastoJson), 201, headers: _json),
      );
      await api.repo.registrar(
        4,
        BorradorGasto(
          tipo: TipoGasto.otro,
          monto: 90,
          litros: 5,
          km: 100,
          fecha: DateTime(2026, 11, 1),
          descripcion: ' Grúa ',
        ),
      );
      expect(jsonDecode(api.pedidas.single.body), {
        'tipo': 'otro',
        'monto': 90,
        'fecha': '2026-11-01',
        'descripcion': 'Grúa',
      });
    });

    test('editar usa PUT /gastos/{id}', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_gastoJson), 200, headers: _json),
      );
      await api.repo.editar(9, _carga);
      expect(api.pedidas.single.method, 'PUT');
      expect(api.pedidas.single.url.path, endsWith('/gastos/9'));
    });

    test('borrar usa DELETE /gastos/{id}', () async {
      final api = _api((_) => http.Response('', 204));
      await api.repo.borrar(9);
      expect(api.pedidas.single.method, 'DELETE');
      expect(api.pedidas.single.url.path, endsWith('/gastos/9'));
    });

    test('un 422 al guardar es KmInvalido', () async {
      final api = _api((_) => _problema(422, 'KM_INVALIDO'));
      expect(api.repo.registrar(4, _carga), throwsA(isA<KmInvalido>()));
      final api2 = _api((_) => _problema(422, 'KM_INVALIDO'));
      expect(api2.repo.editar(9, _carga), throwsA(isA<KmInvalido>()));
    });

    test('un 422 con otro código no se confunde con KmInvalido', () async {
      final api = _api((_) => _problema(422, 'FUERA_DE_COBERTURA'));
      await expectLater(
        api.repo.registrar(4, _carga),
        throwsA(isA<SolicitudRechazada>()),
      );
    });

    test('los demás errores pasan tal cual', () async {
      expect(
        _api((_) => _problema(404)).repo.borrar(9),
        throwsA(isA<NoEncontrado>()),
      );
      expect(
        _api((_) => _problema(400, 'DATOS_INVALIDOS')).repo
            .registrar(4, _carga),
        throwsA(isA<DatosInvalidos>()),
      );
    });
  });

  group('RepositorioBitacoraFake', () {
    test(
      'registra, edita y borra en memoria, el más reciente primero',
      () async {
        final fake = RepositorioBitacoraFake();
        final a = await fake.registrar(4, _carga);
        final b = await fake.registrar(
          4,
          BorradorGasto(
            tipo: TipoGasto.lavado,
            monto: 80,
            fecha: DateTime(2026, 11, 22),
          ),
        );
        expect((await fake.gastos(4)).map((g) => g.id), [b.id, a.id]);
        final editado = await fake.editar(
          a.id,
          BorradorGasto(
            tipo: TipoGasto.gasolina,
            monto: 900,
            litros: 36,
            km: 12600,
            fecha: DateTime(2026, 11, 20),
          ),
        );
        expect(editado.monto, 900);
        await fake.borrar(b.id);
        expect((await fake.gastos(4)).single.monto, 900);
        expect(await fake.gastos(5), isEmpty);
      },
    );

    test('rechaza un km menor a la última lectura como el servidor', () async {
      final fake = RepositorioBitacoraFake();
      await fake.registrar(4, _carga);
      expect(
        fake.registrar(
          4,
          BorradorGasto(
            tipo: TipoGasto.gasolina,
            monto: 1,
            litros: 1,
            km: 12000,
            fecha: DateTime(2026, 11, 21),
          ),
        ),
        throwsA(isA<KmInvalido>()),
      );
    });

    test('con error lanza lo que se le pida', () {
      final fake = RepositorioBitacoraFake(error: const SinConexion('x'));
      expect(fake.gastos(4), throwsA(isA<SinConexion>()));
    });
  });
}
