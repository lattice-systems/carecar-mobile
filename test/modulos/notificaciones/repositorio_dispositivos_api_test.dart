import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_dispositivos_api.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/push.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

({RepositorioDispositivosApi repo, List<http.Request> peticiones}) _repo(
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
  return (repo: RepositorioDispositivosApi(cliente), peticiones: peticiones);
}

/// V2-M06.02 · `PUT` y `DELETE /dispositivos/{instalacionId}` tal como los
/// define el contrato v2 (backend#117).
void main() {
  const instalacion = '3f0c9a7e-1b2d-4c5e-8f9a-0b1c2d3e4f5a';

  test(
    'registra el token con PUT, la sesión y el cuerpo del contrato',
    () async {
      final r = _repo((_) => http.Response('', 204));

      await r.repo.registrar(
        instalacionId: instalacion,
        tokenFcm: 'token-fcm',
        plataforma: PlataformaPush.android,
        idioma: 'es',
      );

      final peticion = r.peticiones.single;
      expect(peticion.method, 'PUT');
      expect(peticion.url.path, '/api/v1/app/dispositivos/$instalacion');
      expect(peticion.headers['Authorization'], 'Bearer token-de-sesion');
      expect(jsonDecode(peticion.body), {
        'tokenFcm': 'token-fcm',
        'plataforma': 'android',
        'idioma': 'es',
      });
    },
  );

  test('sin idioma no lo manda: el servidor asume «es»', () async {
    final r = _repo((_) => http.Response('', 204));

    await r.repo.registrar(
      instalacionId: instalacion,
      tokenFcm: 'token-fcm',
      plataforma: PlataformaPush.ios,
    );

    expect(jsonDecode(r.peticiones.single.body), {
      'tokenFcm': 'token-fcm',
      'plataforma': 'ios',
    });
  });

  test('da de baja con DELETE a la misma instalación', () async {
    final r = _repo((_) => http.Response('', 204));

    await r.repo.darDeBaja(instalacion);

    final peticion = r.peticiones.single;
    expect(peticion.method, 'DELETE');
    expect(peticion.url.path, '/api/v1/app/dispositivos/$instalacion');
    expect(peticion.url.query, isEmpty);
  });

  test('los fallos de red suben tal cual: decide quien llama', () async {
    final r = _repo((_) => throw http.ClientException('sin red'));

    await expectLater(
      r.repo.darDeBaja(instalacion),
      throwsA(isA<SinConexion>()),
    );
  });
}
