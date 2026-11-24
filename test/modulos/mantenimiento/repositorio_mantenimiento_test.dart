import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_api.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/fallos_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _json = {'content-type': 'application/json'};

const _planJson = {
  'vehiculoId': 5,
  'kmActual': 9000,
  'kmActualizadoEn': '2026-11-20',
  'kmFuente': 'taller',
  'promedioKmDiario': 40,
  'servicios': [
    {
      'id': 1,
      'nombre': 'Servicio de 5,000 km',
      'km': 5000,
      'meses': 6,
      'precioEstimado': 1200,
      'conceptos': ['Aceite y filtro'],
      'estado': 'hecho',
      'hechoEn': '2026-06-10',
    },
    {
      'id': 2,
      'nombre': 'Servicio de 10,000 km',
      'km': 10000,
      'meses': 12,
      'precioEstimado': 1850.5,
      'conceptos': ['Aceite y filtro', 'Frenos'],
      'estado': 'proximo',
      'hechoEn': null,
    },
  ],
  'proximo': {
    'servicioId': 2,
    'nombre': 'Servicio de 10,000 km',
    'kmObjetivo': 10000,
    'fechaEstimada': '2026-12-16',
    'faltanKm': 1000,
    'faltanDias': 25,
    'motivo': 'tiempo',
  },
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

({RepositorioMantenimientoApi repo, List<http.Request> pedidas}) _api(
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
  return (repo: RepositorioMantenimientoApi(cliente), pedidas: pedidas);
}

void main() {
  group('RepositorioMantenimientoApi', () {
    test('plan lee GET /vehiculos/{id}/mantenimiento', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_planJson), 200, headers: _json),
      );

      final plan = await api.repo.plan(5);

      expect(api.pedidas.single.method, 'GET');
      expect(
        api.pedidas.single.url.path,
        endsWith('/vehiculos/5/mantenimiento'),
      );
      expect(plan.kmActual, 9000);
      expect(plan.kmFuente, FuenteKm.taller);
      expect(plan.servicios.first.estado, EstadoServicio.hecho);
      expect(plan.servicios.first.hechoEn, DateTime(2026, 6, 10));
      expect(plan.servicios.last.estado, EstadoServicio.proximo);
      expect(plan.servicios.last.precioEstimado, 1850.5);
      expect(plan.proximo!.motivo, MotivoProximo.tiempo);
      expect(plan.proximo!.faltanKm, 1000);
    });

    test('un modelo sin plan da un plan sin servicios', () async {
      final api = _api(
        (_) => http.Response(
          jsonEncode({'vehiculoId': 5, 'servicios': [], 'proximo': null}),
          200,
          headers: _json,
        ),
      );

      final plan = await api.repo.plan(5);

      expect(plan.sinPlan, isTrue);
      expect(plan.proximo, isNull);
    });

    test('un vehículo ajeno es NoEncontrado y pasa tal cual', () async {
      final api = _api((_) => _problema(404));
      await expectLater(api.repo.plan(9), throwsA(isA<NoEncontrado>()));
    });

    test('registrarKm manda POST con el km y lee la lectura', () async {
      final api = _api(
        (_) => http.Response(
          jsonEncode({
            'id': 7,
            'km': 9500,
            'fuente': 'cliente',
            'registradaEn': '2026-11-23T10:00:00',
          }),
          201,
          headers: _json,
        ),
      );

      final lectura = await api.repo.registrarKm(5, 9500);

      final req = api.pedidas.single;
      expect(req.method, 'POST');
      expect(req.url.path, endsWith('/vehiculos/5/lecturas-km'));
      expect(jsonDecode(req.body), {'km': 9500});
      expect(lectura.id, 7);
      expect(lectura.km, 9500);
    });

    test('un 422 KM_INVALIDO es KmInvalido', () async {
      final api = _api((_) => _problema(422, 'KM_INVALIDO'));
      await expectLater(
        api.repo.registrarKm(5, 100),
        throwsA(isA<KmInvalido>()),
      );
    });

    test('un 422 con otro código no se confunde con KmInvalido', () async {
      final api = _api((_) => _problema(422, 'FUERA_DE_COBERTURA'));
      await expectLater(
        api.repo.registrarKm(5, 100),
        throwsA(isA<SinParametrosDeValuacion>()),
      );
    });

    test('un 400 pasa como DatosInvalidos', () async {
      final api = _api((_) => _problema(400, 'DATOS_INVALIDOS'));
      await expectLater(
        api.repo.registrarKm(5, 0),
        throwsA(isA<DatosInvalidos>()),
      );
    });
  });

  group('RepositorioMantenimientoFake', () {
    test('entrega el plan de ejemplo con un próximo servicio', () async {
      final plan = await RepositorioMantenimientoFake().plan(5);

      expect(plan.sinPlan, isFalse);
      expect(plan.proximo, isNotNull);
      expect(
        plan.servicios.map((s) => s.estado),
        contains(EstadoServicio.hecho),
      );
    });

    test(
      'registrarKm sube el km, queda del cliente y recalcula faltantes',
      () async {
        final repo = RepositorioMantenimientoFake();
        final antes = await repo.plan(5);

        final lectura = await repo.registrarKm(5, antes.kmActual! + 300);
        final despues = await repo.plan(5);

        expect(lectura.km, antes.kmActual! + 300);
        expect(despues.kmActual, antes.kmActual! + 300);
        expect(despues.kmFuente, FuenteKm.cliente);
        expect(despues.proximo!.faltanKm, antes.proximo!.faltanKm - 300);
      },
    );

    test('un km menor al último lanza KmInvalido y no cambia nada', () async {
      final repo = RepositorioMantenimientoFake();
      final antes = await repo.plan(5);

      await expectLater(
        repo.registrarKm(5, antes.kmActual! - 1),
        throwsA(isA<KmInvalido>()),
      );
      expect((await repo.plan(5)).kmActual, antes.kmActual);
    });

    test('con error todo falla a pedido', () async {
      final repo = RepositorioMantenimientoFake(error: const SinConexion());
      await expectLater(repo.plan(5), throwsA(isA<SinConexion>()));
      await expectLater(repo.registrarKm(5, 1), throwsA(isA<SinConexion>()));
    });
  });
}
