import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/widgets/datos/repositorio_actividad_en_vivo_api.dart';
import 'package:carecar_mobile/modulos/widgets/datos/repositorio_actividad_en_vivo_fake.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/actividad_en_vivo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _problema(int status, String codigo) => http.Response(
  jsonEncode({
    'timestamp': '2026-11-27T10:00:00Z',
    'status': status,
    'error': 'Error',
    'message': 'La orden ya se entregó',
    'path': '/api/v1/app/ordenes/41/actividad-en-vivo',
    'codigo': codigo,
  }),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

({RepositorioActividadEnVivoApi repo, List<http.Request> peticiones}) _repo(
  http.Response Function(http.Request) responder,
) {
  final peticiones = <http.Request>[];
  final cliente = ClienteApi(
    config: ApiConfig.para('http://localhost:3000/api/v1/app'),
    http: MockClient((req) async {
      peticiones.add(req);
      return responder(req);
    }),
    obtenerToken: () async => 'token-de-sesion',
  );
  return (repo: RepositorioActividadEnVivoApi(cliente), peticiones: peticiones);
}

void main() {
  group('RepositorioActividadEnVivoApi', () {
    test('registra el token con PUT y su cuerpo del contrato', () async {
      final r = _repo((_) => http.Response('', 204));

      await r.repo.registrar(ordenId: 41, pushToken: 'aabbcc');

      final peticion = r.peticiones.single;
      expect(peticion.method, 'PUT');
      expect(peticion.url.path, '/api/v1/app/ordenes/41/actividad-en-vivo');
      expect(jsonDecode(peticion.body), {'pushToken': 'aabbcc'});
    });

    test('un 409 ORDEN_CERRADA es OrdenYaEntregada', () async {
      final r = _repo((_) => _problema(409, 'ORDEN_CERRADA'));

      await expectLater(
        r.repo.registrar(ordenId: 41, pushToken: 'aabbcc'),
        throwsA(isA<OrdenYaEntregada>()),
      );
    });

    test('otro 409 y los fallos de red suben tal cual', () async {
      final conflicto = _repo((_) => _problema(409, 'OTRO'));
      await expectLater(
        conflicto.repo.registrar(ordenId: 41, pushToken: 'aabbcc'),
        throwsA(isA<Conflicto>()),
      );

      final sinRed = _repo((_) => throw http.ClientException('sin red'));
      await expectLater(
        sinRed.repo.registrar(ordenId: 41, pushToken: 'aabbcc'),
        throwsA(isA<SinConexion>()),
      );
    });

    test('da de baja una actividad con su token en la consulta', () async {
      final r = _repo((_) => http.Response('', 204));

      await r.repo.darDeBaja(ordenId: 41, pushToken: 'aabbcc');

      final peticion = r.peticiones.single;
      expect(peticion.method, 'DELETE');
      expect(peticion.url.path, '/api/v1/app/ordenes/41/actividad-en-vivo');
      expect(peticion.url.queryParameters, {'pushToken': 'aabbcc'});
    });

    test('sin token da de baja todas las de la orden', () async {
      final r = _repo((_) => http.Response('', 204));

      await r.repo.darDeBaja(ordenId: 41);

      expect(r.peticiones.single.url.hasQuery, isFalse);
    });
  });

  group('RepositorioActividadEnVivoFake', () {
    test('guarda lo registrado y lo dado de baja', () async {
      final fake = RepositorioActividadEnVivoFake();

      await fake.registrar(ordenId: 41, pushToken: 'aa');
      await fake.darDeBaja(ordenId: 41, pushToken: 'aa');
      await fake.darDeBaja(ordenId: 7);

      expect(fake.registrados, [(41, 'aa')]);
      expect(fake.bajas, [(41, 'aa'), (7, null)]);
    });

    test('puede contestar que la orden ya se entrego o fallar', () async {
      final entregada = RepositorioActividadEnVivoFake(entregadas: {41});
      await expectLater(
        entregada.registrar(ordenId: 41, pushToken: 'aa'),
        throwsA(isA<OrdenYaEntregada>()),
      );

      final sinRed = RepositorioActividadEnVivoFake(
        falla: const SinConexion('sin red'),
      );
      await expectLater(
        sinRed.registrar(ordenId: 41, pushToken: 'aa'),
        throwsA(isA<SinConexion>()),
      );
      await expectLater(
        sinRed.darDeBaja(ordenId: 41),
        throwsA(isA<SinConexion>()),
      );
    });
  });
}
