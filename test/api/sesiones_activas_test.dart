import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// V2-M01.09 · el modelo y las tres operaciones de `/sesiones`.
///
/// La pantalla se construye encima de esto, asi que lo que se prueba aqui es
/// justo lo que la pantalla no puede adivinar: que los tres campos opcionales
/// del contrato pueden faltar, que los instantes se leen en UTC, y que las
/// tres rutas se piden con el verbo correcto.

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

  group('SesionActiva se lee del contrato', () {
    test('con todos los campos', () {
      final sesion = SesionActiva.fromJson({
        'id': 12,
        'dispositivo': 'Pixel 7 de Jael',
        'ultimoUso': '2026-11-24T18:30:00Z',
        'iniciadaEn': '2026-11-01T09:00:00Z',
        'expiraEn': '2026-12-24T18:30:00Z',
      });

      expect(sesion.id, 12);
      expect(sesion.dispositivo, 'Pixel 7 de Jael');
      expect(sesion.ultimoUso, DateTime.utc(2026, 11, 24, 18, 30));
      expect(sesion.iniciadaEn, DateTime.utc(2026, 11, 1, 9));
      expect(sesion.expiraEn, DateTime.utc(2026, 12, 24, 18, 30));
    });

    test('las sesiones viejas llegan sin dispositivo, uso ni inicio', () {
      // No es un caso raro: toda sesion abierta antes de esta historia tiene
      // esas tres columnas en nulo y **sigue vigente**. Si el modelo las
      // exigiera, la lista reventaria justo para quien ya estaba dentro.
      final sesion = SesionActiva.fromJson({
        'id': 3,
        'dispositivo': null,
        'ultimoUso': null,
        'iniciadaEn': null,
        'expiraEn': '2026-12-01T00:00:00Z',
      });

      expect(sesion.dispositivo, isNull);
      expect(sesion.ultimoUso, isNull);
      expect(sesion.iniciadaEn, isNull);
      expect(sesion.expiraEn, DateTime.utc(2026, 12, 1));
    });

    test('tambien si los campos opcionales no vienen', () {
      final sesion = SesionActiva.fromJson({
        'id': 3,
        'expiraEn': '2026-12-01T00:00:00Z',
      });

      expect(sesion.dispositivo, isNull);
      expect(sesion.ultimoUso, isNull);
      expect(sesion.iniciadaEn, isNull);
    });

    test('sin id o sin expiraEn falla: el contrato los exige', () {
      expect(
        () => SesionActiva.fromJson({'expiraEn': '2026-12-01T00:00:00Z'}),
        throwsFormatException,
      );
      expect(() => SesionActiva.fromJson({'id': 3}), throwsFormatException);
    });

    test('un instante sin zona se toma como UTC, no como hora local', () {
      // El contrato los declara `date-time`. Tomarlos como locales correria
      // la hora segun el celular y «hace 5 minutos» saldria mal por horas.
      final sesion = SesionActiva.fromJson({
        'id': 1,
        'ultimoUso': '2026-11-24T18:30:00',
        'expiraEn': '2026-12-24T18:30:00',
      });

      expect(sesion.ultimoUso!.isUtc, isTrue);
      expect(sesion.ultimoUso, DateTime.utc(2026, 11, 24, 18, 30));
      expect(sesion.expiraEn.isUtc, isTrue);
    });
  });

  group('las tres operaciones de /sesiones', () {
    test('misSesiones llama GET /sesiones y respeta el orden', () async {
      // El contrato ordena por `ultimoUso` descendente y deja al final las que
      // nunca se refrescaron. La app **no reordena**: si lo hiciera, tendria
      // que decidir que hacer con los nulos y acabaria discrepando del server.
      final api = _api(
        espia,
        () => _json([
          {
            'id': 9,
            'dispositivo': 'Pixel 7',
            'ultimoUso': '2026-11-24T18:30:00Z',
            'iniciadaEn': '2026-11-01T09:00:00Z',
            'expiraEn': '2026-12-24T18:30:00Z',
          },
          {'id': 4, 'expiraEn': '2026-12-02T00:00:00Z'},
        ]),
      );

      final sesiones = await api.misSesiones();

      expect(espia.metodo, 'GET');
      expect(espia.url!.path, '/api/v1/app/sesiones');
      expect(sesiones.map((s) => s.id), [9, 4]);
      expect(sesiones.last.ultimoUso, isNull);
    });

    test('una lista vacia no es un error', () async {
      final api = _api(espia, () => _json(const []));
      expect(await api.misSesiones(), isEmpty);
    });

    test('cerrarSesionActiva llama DELETE /sesiones/{id}', () async {
      final api = _api(espia, () => http.Response('', 204));

      await api.cerrarSesionActiva(12);

      expect(espia.metodo, 'DELETE');
      expect(espia.url!.path, '/api/v1/app/sesiones/12');
    });

    test('cerrarTodasLasSesiones llama DELETE /sesiones, sin id', () async {
      // Es la operacion mas destructiva del modulo: cierra tambien la de quien
      // llama. Que la ruta no lleve id es justo lo que la distingue.
      final api = _api(espia, () => http.Response('', 204));

      await api.cerrarTodasLasSesiones();

      expect(espia.metodo, 'DELETE');
      expect(espia.url!.path, '/api/v1/app/sesiones');
    });

    test('cerrar una sesion ajena llega como NoEncontrado', () async {
      final api = _api(
        espia,
        () => _json({
          'type': 'about:blank',
          'title': 'No encontrado',
          'status': 404,
          'codigo': 'NO_ENCONTRADO',
          'detail': 'No existe o no es de este cliente',
        }, 404),
      );

      await expectLater(
        api.cerrarSesionActiva(999),
        throwsA(isA<NoEncontrado>()),
      );
    });
  });

  group('el login manda el nombre del dispositivo', () {
    test('cuando se le da, para que la lista diga algo util', () {
      final json = const PeticionLogin(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
        dispositivo: 'Pixel 7 de Jael',
      ).toJson();

      expect(json['dispositivo'], 'Pixel 7 de Jael');
    });

    test('y no manda la llave si no hay nombre', () {
      // `dispositivo` es opcional en el contrato. Mandarlo en nulo seria ruido
      // en el cuerpo y obligaria al backend a distinguir «no vino» de «vino
      // vacio» sin razon.
      final json = const PeticionLogin(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      ).toJson();

      expect(json.containsKey('dispositivo'), isFalse);
    });

    test('recorta el nombre y lo corta en 80, como el contrato', () {
      // El contrato declara `maxLength: 80`. Si la app manda mas, el backend
      // responde 400 y el cliente se queda fuera por el nombre de su celular.
      final nombreLargo = List.filled(100, 'a').join();
      final json = PeticionLogin(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
        dispositivo: '  $nombreLargo  ',
      ).toJson();

      expect((json['dispositivo']! as String).length, 80);
    });
  });
}
