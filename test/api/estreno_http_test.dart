import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
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

const _cotizacion = <String, Object?>{
  'precio': 300000,
  'enganche': 60000,
  'montoFinanciado': 240000,
  'tasaAnual': 0.1499,
  'plazoMeses': 48,
  'mensualidad': 6678.16,
  'leyenda': 'Estimación no vinculante.',
};

const _solicitud = <String, Object?>{
  'id': 5,
  'tipo': 'COTIZACION',
  'modeloCatalogoId': 7,
  'modelo': 'Nissan Kicks 2026 Advance',
  'estado': 'RECIBIDA',
  'cotizacion': _cotizacion,
  'creadaEn': '2026-11-24T18:30:00Z',
};

void main() {
  late _Espia espia;
  setUp(() => espia = _Espia());

  test(
    'calcularMensualidad llama POST /estreno/cotizaciones/calculo',
    () async {
      final api = _api(espia, () => _json(_cotizacion));

      final c = await api.calcularMensualidad(
        modeloCatalogoId: 7,
        enganche: 60000,
        plazoMeses: 48,
      );

      expect(espia.metodo, 'POST');
      expect(espia.url!.path, '/api/v1/app/estreno/cotizaciones/calculo');
      expect(jsonDecode(espia.cuerpo!), {
        'modeloCatalogoId': 7,
        'enganche': 60000,
        'plazoMeses': 48,
      });
      expect(c.mensualidad, 6678.16);
    },
  );

  test('crearSolicitudEstreno llama POST /estreno/solicitudes', () async {
    final api = _api(espia, () => _json(_solicitud, 201));

    final s = await api.crearSolicitudEstreno(
      const NuevaSolicitudEstreno(
        tipo: 'COTIZACION',
        modeloCatalogoId: 7,
        enganche: 60000,
        plazoMeses: 48,
      ),
    );

    expect(espia.metodo, 'POST');
    expect(espia.url!.path, '/api/v1/app/estreno/solicitudes');
    expect(jsonDecode(espia.cuerpo!), {
      'tipo': 'COTIZACION',
      'modeloCatalogoId': 7,
      'enganche': 60000,
      'plazoMeses': 48,
    });
    expect(s.id, 5);
    expect(s.cotizacion!.plazoMeses, 48);
  });

  test(
    'paginaDeSolicitudesEstreno manda pagina y tamano y lee la pagina',
    () async {
      final api = _api(
        espia,
        () => _json({
          'contenido': [_solicitud],
          'pagina': 1,
          'tamano': 5,
          'totalElementos': 7,
          'totalPaginas': 3,
        }),
      );

      final p = await api.paginaDeSolicitudesEstreno(pagina: 1, tamano: 5);

      expect(espia.metodo, 'GET');
      expect(espia.url!.path, '/api/v1/app/estreno/solicitudes');
      expect(espia.url!.queryParameters, {'pagina': '1', 'tamano': '5'});
      expect(p.contenido.single.modelo, 'Nissan Kicks 2026 Advance');
      expect(p.pagina, 1);
      expect(p.totalPaginas, 3);
    },
  );
}
