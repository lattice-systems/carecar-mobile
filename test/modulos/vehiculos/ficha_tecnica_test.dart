import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/ficha_tecnica_local.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_ficha_tecnica_api.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/ficha_tecnica_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _versa = VehiculoGaraje(
  id: 1,
  modelo: 'Versa',
  anio: 2024,
  marca: 'Nissan',
  version: 'Sense',
);
const _desconocido = VehiculoGaraje(id: 9, modelo: 'Cybertruck', anio: 2025);

const _json = {
  'vehiculoId': 1,
  'modelo': 'Versa',
  'anio': 2024,
  'secciones': [
    {
      'titulo': 'Motor',
      'especificaciones': [
        {'clave': 'Cilindrada', 'valor': '1.6 L'},
      ],
    },
  ],
};

RepositorioFichaTecnicaApi _repo(http.Client cliente) =>
    RepositorioFichaTecnicaApi(
      ClienteApi(
        config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        http: cliente,
      ),
    );

void main() {
  group('FichaTecnicaVehiculo', () {
    test('lee las secciones del JSON de la API', () {
      final ficha = FichaTecnicaVehiculo.fromJson(_json);
      expect(ficha.secciones.single.titulo, 'Motor');
      expect(ficha.secciones.single.especificaciones.single.valor, '1.6 L');
      expect(ficha.delRespaldo, isFalse);
    });

    test('rechaza un cuerpo sin secciones como respuesta inválida', () {
      expect(
        () => FichaTecnicaVehiculo.fromJson(const {'modelo': 'Versa'}),
        throwsFormatException,
      );
    });
  });

  group('FichaTecnicaLocal', () {
    test('arma secciones con lo que la app trae de ese modelo y año', () {
      final ficha = FichaTecnicaLocal.de(_versa)!;
      expect(ficha.delRespaldo, isTrue);
      final motor = ficha.secciones.firstWhere((s) => s.titulo == 'Motor');
      expect(
        motor.especificaciones.map((e) => e.valor),
        contains('118 hp a 6,300 rpm'),
      );
    });

    test('devuelve null si el modelo no está en la app', () {
      expect(FichaTecnicaLocal.de(_desconocido), isNull);
    });
  });

  group('RepositorioFichaTecnicaApi', () {
    test(
      'pide GET /vehiculos/{id}/ficha-tecnica y traduce la respuesta',
      () async {
        late Uri pedido;
        final repo = _repo(
          MockClient((r) async {
            pedido = r.url;
            return http.Response(
              jsonEncode(_json),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        final ficha = await repo.ficha(_versa);
        expect(pedido.path, '/api/v1/app/vehiculos/1/ficha-tecnica');
        expect(ficha!.delRespaldo, isFalse);
        expect(ficha.secciones.single.titulo, 'Motor');
      },
    );

    test(
      'con 404 usa el respaldo local mientras el backend no la tiene',
      () async {
        final repo = _repo(MockClient((_) async => http.Response('{}', 404)));
        final ficha = await repo.ficha(_versa);
        expect(ficha!.delRespaldo, isTrue);
      },
    );

    test('sin conexión usa el respaldo local', () async {
      final repo = _repo(
        MockClient((_) async => throw http.ClientException('sin red')),
      );
      expect((await repo.ficha(_versa))!.delRespaldo, isTrue);
    });

    test('con 404 y sin respaldo no hay ficha (null)', () async {
      final repo = _repo(MockClient((_) async => http.Response('{}', 404)));
      expect(await repo.ficha(_desconocido), isNull);
    });

    test('sin conexión y sin respaldo deja pasar el error', () {
      final repo = _repo(
        MockClient((_) async => throw http.ClientException('sin red')),
      );
      expect(repo.ficha(_desconocido), throwsA(isA<SinConexion>()));
    });
  });
}
