import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_api.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/repositorio_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/solicitud_asistencia.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _solicitud = {
  'id': 9,
  'vehiculoId': 3,
  'tipo': 'llanta',
  'lat': 19.4,
  'lng': -99.1,
  'comentario': 'Junto al puente',
  'estado': 'recibida',
  'creadaEn': '2026-11-23T15:00:00Z',
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json'},
);

http.Response _problema(int status, String? codigo) => _json(status, {
  'timestamp': 't',
  'status': status,
  'error': 'Error',
  'message': 'x',
  'codigo': ?codigo,
  'path': '/asistencia',
});

RepositorioAsistenciaApi _repo(http.Response Function(http.Request) f) =>
    RepositorioAsistenciaApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioAsistenciaApi.pedirAyuda', () {
    test('manda vehiculo, tipo, ubicacion y comentario', () async {
      http.Request? pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(201, _solicitud);
      });
      final s = await repo.pedirAyuda(
        vehiculoId: 3,
        tipo: TipoAsistencia.llanta,
        ubicacion: const Coordenada(19.4, -99.1),
        comentario: 'Junto al puente',
      );
      expect(pedida?.method, 'POST');
      expect(pedida?.url.path, '/api/v1/app/asistencia');
      expect(jsonDecode(pedida!.body), {
        'vehiculoId': 3,
        'tipo': 'llanta',
        'lat': 19.4,
        'lng': -99.1,
        'comentario': 'Junto al puente',
      });
      expect(s.id, 9);
      expect(s.estado, EstadoSolicitud.recibida);
    });

    test('sin ubicacion no manda lat ni lng', () async {
      http.Request? pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(201, {..._solicitud, 'lat': null, 'lng': null});
      });
      await repo.pedirAyuda(vehiculoId: 3, tipo: TipoAsistencia.otro);
      final cuerpo = jsonDecode(pedida!.body) as Map;
      expect(cuerpo.containsKey('lat'), isFalse);
      expect(cuerpo.containsKey('lng'), isFalse);
      expect(cuerpo.containsKey('comentario'), isFalse);
    });

    test('un comentario en blanco no se manda', () async {
      http.Request? pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(201, _solicitud);
      });
      await repo.pedirAyuda(
        vehiculoId: 3,
        tipo: TipoAsistencia.otro,
        comentario: '   ',
      );
      expect(
        (jsonDecode(pedida!.body) as Map).containsKey('comentario'),
        isFalse,
      );
    });

    test('409 SOLICITUD_ABIERTA se traduce', () async {
      final repo = _repo((_) => _problema(409, 'SOLICITUD_ABIERTA'));
      await expectLater(
        repo.pedirAyuda(vehiculoId: 3, tipo: TipoAsistencia.otro),
        throwsA(isA<SolicitudAbierta>()),
      );
    });

    test('otro 409 sigue siendo Conflicto', () async {
      final repo = _repo((_) => _problema(409, null));
      await expectLater(
        repo.pedirAyuda(vehiculoId: 3, tipo: TipoAsistencia.otro),
        throwsA(isA<Conflicto>()),
      );
    });

    test('404 de vehiculo ajeno pasa como NoEncontrado', () async {
      final repo = _repo((_) => _problema(404, null));
      await expectLater(
        repo.pedirAyuda(vehiculoId: 3, tipo: TipoAsistencia.otro),
        throwsA(isA<NoEncontrado>()),
      );
    });
  });

  group('RepositorioAsistenciaApi.activa', () {
    test('pide activa=true y lee la solicitud', () async {
      Uri? url;
      final repo = _repo((req) {
        url = req.url;
        return _json(200, _solicitud);
      });
      final s = await repo.activa();
      expect(url?.path, '/api/v1/app/asistencia');
      expect(url?.queryParameters['activa'], 'true');
      expect(s?.id, 9);
    });

    test('204 es nulo', () async {
      final repo = _repo((_) => http.Response('', 204));
      expect(await repo.activa(), isNull);
    });
  });

  group('RepositorioAsistenciaApi.obtener', () {
    test('pide GET /asistencia/{id} y lee la solicitud', () async {
      Uri? url;
      final repo = _repo((req) {
        url = req.url;
        return _json(200, {..._solicitud, 'estado': 'en_camino'});
      });
      final s = await repo.obtener(9);
      expect(url?.path, '/api/v1/app/asistencia/9');
      expect(s.estado, EstadoSolicitud.enCamino);
    });

    test('una solicitud ajena o inexistente es NoEncontrado', () async {
      final repo = _repo((_) => _problema(404, null));
      await expectLater(repo.obtener(9), throwsA(isA<NoEncontrado>()));
    });
  });

  group('RepositorioAsistenciaFake.obtener', () {
    test('devuelve la solicitud abierta y falla con otra', () async {
      final fake = RepositorioAsistenciaFake();
      final s = await fake.pedirAyuda(vehiculoId: 1, tipo: TipoAsistencia.otro);
      expect((await fake.obtener(s.id)).id, s.id);
      await expectLater(fake.obtener(99), throwsA(isA<NoEncontrado>()));
    });
  });

  group('RepositorioAsistenciaFake', () {
    test('crea, recuerda la abierta y rechaza una segunda', () async {
      final fake = RepositorioAsistenciaFake();
      expect(await fake.activa(), isNull);
      final s = await fake.pedirAyuda(
        vehiculoId: 1,
        tipo: TipoAsistencia.bateria,
        ubicacion: const Coordenada(1, 2),
      );
      expect((await fake.activa())?.id, s.id);
      expect(fake.pedidos.single.ubicacion, const Coordenada(1, 2));
      await expectLater(
        fake.pedirAyuda(vehiculoId: 1, tipo: TipoAsistencia.otro),
        throwsA(isA<SolicitudAbierta>()),
      );
    });

    test('con fallo lanza ese error', () async {
      final fake = RepositorioAsistenciaFake(fallo: const SinConexion());
      await expectLater(
        fake.pedirAyuda(vehiculoId: 1, tipo: TipoAsistencia.otro),
        throwsA(isA<SinConexion>()),
      );
    });
  });
}
