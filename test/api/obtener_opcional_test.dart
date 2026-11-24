// `ClienteApi.obtenerOpcional`: un GET cuyo 204 significa "no hay nada" y no un
// cuerpo mal formado (V2-M11.01, `GET /asistencia?activa=true`).

import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ClienteApi _cliente(http.Response Function(http.Request) responder) =>
    ClienteApi(
      config: ApiConfig.para('http://local/api/v1/app'),
      http: MockClient((req) async => responder(req)),
    );

void main() {
  test('un 204 devuelve nulo', () async {
    final cliente = _cliente((_) => http.Response('', 204));
    expect(await cliente.obtenerOpcional('/asistencia', (j) => j), isNull);
  });

  test('un 200 lee el objeto y manda la consulta', () async {
    Uri? pedida;
    final cliente = _cliente((req) {
      pedida = req.url;
      return http.Response(
        jsonEncode({'id': 4}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final id = await cliente.obtenerOpcional<Object?>(
      '/asistencia',
      (j) => j['id'],
      consulta: {'activa': 'true'},
    );
    expect(id, 4);
    expect(pedida?.queryParameters['activa'], 'true');
  });

  test('un 404 sigue siendo error', () async {
    final cliente = _cliente(
      (_) => http.Response(
        jsonEncode({
          'timestamp': 't',
          'status': 404,
          'error': 'Not Found',
          'message': 'No existe',
          'path': '/p',
        }),
        404,
        headers: {'content-type': 'application/json'},
      ),
    );
    await expectLater(
      cliente.obtenerOpcional('/asistencia', (j) => j),
      throwsA(isA<NoEncontrado>()),
    );
  });
}
