import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
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

const _trasladoJson = {
  'id': 5,
  'citaId': 9,
  'tipo': 'recoger',
  'estado': 'en_camino',
  'costo': 150,
  'fecha': '2026-12-01',
  'ventanaInicio': '07:00',
  'ventanaFin': '09:00',
  'ubicacionChofer': {
    'lat': 19.43,
    'lng': -99.13,
    'actualizadaEn': '2026-12-01T13:00:00Z',
  },
};

const _checklistJson = {
  'trasladoId': 5,
  'km': 45200,
  'gasolina': 'medio',
  'fotos': ['https://x/f1.jpg?firma=a'],
  'registradoEn': '2026-12-01T13:10:00Z',
};

void main() {
  group('RepositorioRecoleccionApi seguimiento', () {
    test('traslado lee GET /traslados/{id}', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_trasladoJson), 200, headers: _json),
      );

      final t = await api.repo.traslado(5);

      expect(api.pedidas.single.url.path, endsWith('/traslados/5'));
      expect(t.estado, EstadoTraslado.enCamino);
      expect(t.ubicacionChofer?.lat, 19.43);
    });

    test('un traslado ajeno es NoEncontrado', () async {
      final api = _api((_) => _problema(404));

      await expectLater(api.repo.traslado(5), throwsA(isA<NoEncontrado>()));
    });

    test('checklist lee GET /traslados/{id}/checklist', () async {
      final api = _api(
        (_) => http.Response(jsonEncode(_checklistJson), 200, headers: _json),
      );

      final c = await api.repo.checklist(5);

      expect(api.pedidas.single.url.path, endsWith('/traslados/5/checklist'));
      expect(c?.km, 45200);
      expect(c?.fotos, hasLength(1));
    });

    test('un 404 del checklist significa que aun no hay', () async {
      final api = _api((_) => _problema(404));

      expect(await api.repo.checklist(5), isNull);
    });

    test('otros errores del checklist pasan tal cual', () async {
      final api = _api((_) => _problema(500));

      await expectLater(
        api.repo.checklist(5),
        throwsA(isA<ErrorDelServidor>()),
      );
    });

    test(
      'no reutiliza las URLs firmadas: cada llamada pide de nuevo',
      () async {
        final api = _api(
          (_) => http.Response(jsonEncode(_checklistJson), 200, headers: _json),
        );

        await api.repo.checklist(5);
        await api.repo.checklist(5);

        expect(api.pedidas, hasLength(2));
      },
    );
  });

  group('RepositorioRecoleccionFake seguimiento', () {
    test('devuelve traslados y checklists configurados', () async {
      final repo = RepositorioRecoleccionFake(
        traslados: [TrasladoDetalle.fromJson(_trasladoJson)],
        checklists: {5: ChecklistTraslado.fromJson(_checklistJson)},
      );

      expect((await repo.traslado(5)).id, 5);
      expect((await repo.checklist(5))?.km, 45200);
      expect(await repo.checklist(6), isNull);
    });

    test('un traslado que no existe es NoEncontrado', () async {
      final repo = RepositorioRecoleccionFake();

      await expectLater(repo.traslado(1), throwsA(isA<NoEncontrado>()));
    });
  });

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
      final api = _api((_) => _problema(422, 'FUERA_DE_COBERTURA'));
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
      final api = _api((_) => _problema(422, 'FUERA_DE_COBERTURA'));
      await expectLater(
        api.repo.cotizar(direccionId: 3, fecha: DateTime(2026, 11, 26)),
        throwsA(isA<FueraDeCobertura>()),
      );
    });

    test('un 422 con otro codigo no se confunde con la cobertura', () async {
      final api = _api((_) => _problema(422, 'KM_INVALIDO'));
      await expectLater(
        api.repo.guardar(_borrador),
        throwsA(isA<SolicitudRechazada>()),
      );
      await expectLater(
        api.repo.cotizar(direccionId: 3, fecha: DateTime(2026, 11, 26)),
        throwsA(isA<SolicitudRechazada>()),
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
