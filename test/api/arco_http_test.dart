import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Guarda lo que se pidio, para comprobar metodo y ruta sin servidor.
class _Espia {
  String? metodo;
  Uri? url;
  String? cuerpo;
}

CarecarApi _api(_Espia espia, http.Response Function() responder) {
  return CarecarApiHttp(
    ClienteApi(
      config: ApiConfig.para('http://localhost:3000/api/v1/app'),
      http: MockClient((req) async {
        espia
          ..metodo = req.method
          ..url = req.url
          ..cuerpo = req.body;
        return responder();
      }),
    ),
  );
}

http.Response _json(Object datos, [int status = 200]) => http.Response(
  jsonEncode(datos),
  status,
  headers: {'content-type': 'application/json'},
);

const _solicitud = <String, Object?>{
  'id': 4,
  'tipo': 'ACCESO',
  'estado': 'RESUELTA',
  'creadaEn': '2026-11-25T18:30:00Z',
  'resueltaEn': '2026-11-25T18:30:02Z',
  'venceEn': '2026-12-02T18:30:02Z',
};

void main() {
  late _Espia espia;
  setUp(() => espia = _Espia());

  test('misSolicitudesArco llama GET /privacidad/arco', () async {
    final api = _api(espia, () => _json([_solicitud]));

    final lista = await api.misSolicitudesArco();

    expect(espia.metodo, 'GET');
    expect(espia.url!.path, '/api/v1/app/privacidad/arco');
    expect(lista.single.id, 4);
    expect(lista.single.estado, 'RESUELTA');
  });

  test(
    'pedirAccesoArco llama POST /privacidad/arco/acceso, con 202 o 200',
    () async {
      for (final status in [202, 200]) {
        final api = _api(
          espia,
          () => _json({..._solicitud, 'estado': 'PENDIENTE'}, status),
        );

        final s = await api.pedirAccesoArco();

        expect(espia.metodo, 'POST', reason: '$status');
        expect(espia.url!.path, '/api/v1/app/privacidad/arco/acceso');
        expect(s.estado, 'PENDIENTE');
      }
    },
  );

  test('descargarArchivoArco pide el archivo de esa solicitud', () async {
    final api = _api(
      espia,
      () => http.Response(
        '{"cliente":{}}',
        200,
        headers: {'content-type': 'application/json'},
      ),
    );

    final bytes = await api.descargarArchivoArco(4);

    expect(espia.metodo, 'GET');
    expect(espia.url!.path, '/api/v1/app/privacidad/arco/4/archivo');
    expect(utf8.decode(bytes), '{"cliente":{}}');
  });
}
