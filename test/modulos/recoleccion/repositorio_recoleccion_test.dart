import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_api.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/direccion_guardada.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/fallos_recoleccion.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _json = {'content-type': 'application/json'};

const _direccionJson = {
  'id': 3,
  'alias': 'Casa',
  'calle': 'Av. Reforma 100',
  'colonia': 'Juárez',
  'cp': '06600',
  'ciudad': 'Ciudad de México',
  'lat': 19.4326,
  'lng': -99.1332,
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

const _borrador = BorradorDireccion(
  alias: 'Casa',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  cp: '06600',
  ciudad: 'Ciudad de México',
  ubicacion: Coordenada(19.4326, -99.1332),
);

({RepositorioRecoleccionApi repo, List<http.Request> pedidas}) _api(
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
  return (repo: RepositorioRecoleccionApi(cliente), pedidas: pedidas);
}

void main() {
  group('RepositorioRecoleccionApi', () {
    test('direcciones lee el arreglo de GET /direcciones', () async {
      final api = _api(
        (_) => http.Response(jsonEncode([_direccionJson]), 200, headers: _json),
      );

      final lista = await api.repo.direcciones();

      expect(api.pedidas.single.url.path, endsWith('/direcciones'));
      expect(lista.single.alias, 'Casa');
      expect(lista.single.cp, '06600');
      expect(lista.single.ubicacion, const Coordenada(19.4326, -99.1332));
    });

    test(
      'guardar manda POST con lat y lng y lee la dirección creada',
      () async {
        final api = _api(
          (_) => http.Response(jsonEncode(_direccionJson), 201, headers: _json),
        );

        final d = await api.repo.guardar(_borrador);

        final req = api.pedidas.single;
        expect(req.method, 'POST');
        final cuerpo = jsonDecode(req.body) as Map<String, Object?>;
        expect(cuerpo['lat'], 19.4326);
        expect(cuerpo['lng'], -99.1332);
        expect(cuerpo['cp'], '06600');
        expect(cuerpo.containsKey('id'), isFalse);
        expect(d.id, 3);
      },
    );

    test('un 422 al guardar es FueraDeCobertura', () async {
      final api = _api((_) => _problema(422, 'FUERA_DE_COBERTURA'));
      await expectLater(
        api.repo.guardar(_borrador),
        throwsA(isA<FueraDeCobertura>()),
      );
    });

    test('editar manda PUT a /direcciones/{id}', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_direccionJson), 200, headers: _json),
      );

      await api.repo.editar(3, _borrador);

      expect(api.pedidas.single.method, 'PUT');
      expect(api.pedidas.single.url.path, endsWith('/direcciones/3'));
    });

    test('un 422 al editar es FueraDeCobertura', () async {
      final api = _api((_) => _problema(422));
      await expectLater(
        api.repo.editar(3, _borrador),
        throwsA(isA<FueraDeCobertura>()),
      );
    });

    test('borrar manda DELETE y acepta 204', () async {
      final api = _api((_) => http.Response('', 204));
      await api.repo.borrar(3);
      expect(api.pedidas.single.method, 'DELETE');
      expect(api.pedidas.single.url.path, endsWith('/direcciones/3'));
    });

    test('un 409 al borrar es DireccionEnUso', () async {
      final api = _api((_) => _problema(409, 'DIRECCION_EN_USO'));
      await expectLater(api.repo.borrar(3), throwsA(isA<DireccionEnUso>()));
    });

    test('un 404 al borrar pasa como NoEncontrado', () async {
      final api = _api((_) => _problema(404));
      await expectLater(api.repo.borrar(3), throwsA(isA<NoEncontrado>()));
    });

    test('cotizar pide direccionId y fecha y lee costos y ventanas', () async {
      final api = _api(
        (_) => http.Response(
          jsonEncode({
            'direccionId': 3,
            'fecha': '2026-11-26',
            'costoPorTraslado': 150,
            'costoTotal': 300.0,
            'recoleccion': {'inicio': '07:00', 'fin': '09:00'},
            'entrega': {'inicio': '17:00', 'fin': '19:00'},
          }),
          200,
          headers: _json,
        ),
      );

      final c = await api.repo.cotizar(
        direccionId: 3,
        fecha: DateTime(2026, 11, 26),
      );

      final url = api.pedidas.single.url;
      expect(url.path, endsWith('/recoleccion/cotizacion'));
      expect(url.queryParameters, {'direccionId': '3', 'fecha': '2026-11-26'});
      expect(c.costoPorTraslado, 150);
      expect(c.costoTotal, 300);
      expect(c.entrega.inicio, '17:00');
    });

    test('un 422 al cotizar es FueraDeCobertura', () async {
      final api = _api((_) => _problema(422));
      await expectLater(
        api.repo.cotizar(direccionId: 3, fecha: DateTime(2026, 11, 26)),
        throwsA(isA<FueraDeCobertura>()),
      );
    });

    test('un error de red pasa como SinConexion', () async {
      final cliente = ClienteApi(
        config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        http: MockClient((_) async => throw http.ClientException('sin red')),
      );
      await expectLater(
        RepositorioRecoleccionApi(cliente).direcciones(),
        throwsA(isA<SinConexion>()),
      );
    });
  });

  group('RepositorioRecoleccionFake', () {
    test('guarda, lista, edita y borra en memoria', () async {
      final repo = RepositorioRecoleccionFake();
      final creada = await repo.guardar(_borrador);
      expect((await repo.direcciones()).map((d) => d.id), [creada.id]);

      final editada = await repo.editar(
        creada.id,
        const BorradorDireccion(
          alias: 'Oficina',
          calle: 'Insurgentes 1',
          colonia: 'Roma',
          cp: '06700',
          ciudad: 'CDMX',
          ubicacion: Coordenada(19.42, -99.16),
        ),
      );
      expect(editada.alias, 'Oficina');
      expect((await repo.direcciones()).single.alias, 'Oficina');

      await repo.borrar(creada.id);
      expect(await repo.direcciones(), isEmpty);
    });

    test(
      'un pin fuera de la zona lanza FueraDeCobertura y no guarda',
      () async {
        final repo = RepositorioRecoleccionFake();
        await expectLater(
          repo.guardar(
            const BorradorDireccion(
              alias: 'Lejos',
              calle: 'x',
              colonia: 'x',
              cp: '12345',
              ciudad: 'x',
              ubicacion: Coordenada(25.67, -100.31),
            ),
          ),
          throwsA(isA<FueraDeCobertura>()),
        );
        expect(await repo.direcciones(), isEmpty);
      },
    );

    test('borrar una dirección en uso lanza DireccionEnUso', () async {
      final repo = RepositorioRecoleccionFake(idsEnUso: const {1});
      final d = await repo.guardar(_borrador);
      expect(d.id, 1);
      await expectLater(repo.borrar(1), throwsA(isA<DireccionEnUso>()));
      expect(await repo.direcciones(), hasLength(1));
    });

    test('cotizar devuelve el costo configurado por dos traslados', () async {
      final repo = RepositorioRecoleccionFake(costoPorTraslado: 120);
      final d = await repo.guardar(_borrador);
      final c = await repo.cotizar(
        direccionId: d.id,
        fecha: DateTime(2026, 11, 26),
      );
      expect(c.costoPorTraslado, 120);
      expect(c.costoTotal, 240);
    });

    test('con error configurado falla como la red', () async {
      final repo = RepositorioRecoleccionFake(error: const SinConexion());
      await expectLater(repo.direcciones(), throwsA(isA<SinConexion>()));
    });
  });
}
