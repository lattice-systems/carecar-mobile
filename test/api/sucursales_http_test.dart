import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// V2-M27.02: GET /sucursales contra un servidor simulado.
void main() {
  test('sucursales llama GET /sucursales y lee la lista', () async {
    Uri? pedida;
    String? metodo;
    final api = CarecarApiHttp(
      ClienteApi(
        config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        http: MockClient((req) async {
          pedida = req.url;
          metodo = req.method;
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'nombre': 'CareCar León',
                'direccion': 'Blvd. Ejemplo 100',
                'latitud': 21.125,
                'longitud': -101.686,
                'telefono': null,
                'correo': null,
                'abiertaAhora': false,
                'horarios': <Object>[],
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

    final sucursales = await api.sucursales();

    expect(metodo, 'GET');
    expect(pedida!.path, '/api/v1/app/sucursales');
    expect(sucursales.single.nombre, 'CareCar León');
    expect(sucursales.single.telefono, isNull);
  });
}
