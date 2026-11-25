import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Guarda lo que se pidio, para comprobar metodo, ruta y cuerpo sin servidor.
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

void main() {
  late _Espia espia;
  setUp(() => espia = _Espia());

  test('avisoDePrivacidad llama GET /privacidad/aviso', () async {
    final api = _api(
      espia,
      () => _json({
        'id': 3,
        'version': 2,
        'texto': 'Texto del aviso.',
        'vigenteDesde': '2026-11-25T18:30:00Z',
        'aceptado': false,
      }),
    );

    final aviso = await api.avisoDePrivacidad();

    expect(espia.metodo, 'GET');
    expect(espia.url!.path, '/api/v1/app/privacidad/aviso');
    expect(aviso.id, 3);
    expect(aviso.version, 2);
    expect(aviso.aceptado, isFalse);
  });

  test('aceptarAvisoDePrivacidad llama POST /privacidad/aceptaciones con '
      'el id del aviso', () async {
    final api = _api(
      espia,
      () => _json({
        'avisoId': 3,
        'version': 2,
        'aceptadoEn': '2026-11-26T09:00:00Z',
      }),
    );

    final aceptacion = await api.aceptarAvisoDePrivacidad(3);

    expect(espia.metodo, 'POST');
    expect(espia.url!.path, '/api/v1/app/privacidad/aceptaciones');
    expect(jsonDecode(espia.cuerpo!), {'avisoId': 3});
    expect(aceptacion.avisoId, 3);
    expect(aceptacion.aceptadoEn, DateTime.utc(2026, 11, 26, 9));
  });
}
