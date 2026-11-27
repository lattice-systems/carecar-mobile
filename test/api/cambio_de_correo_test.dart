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

/// V2-M01.07 · pedir el cambio de correo y confirmarlo.
///
/// Son dos viajes a propósito: el primero **no cambia nada** y manda un código
/// al correo nuevo, y el segundo aplica el cambio. Guardar el correo antes de
/// confirmarlo dejaría al cliente con uno que no ha probado que es suyo y, como
/// el usuario de la cuenta lo sigue, **sin poder entrar**.

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

http.Response _problema(int status, String codigo) => _json({
  'type': 'about:blank',
  'title': 'Error',
  'status': status,
  'codigo': codigo,
  'detail': 'detalle de prueba',
}, status);

void main() {
  late _Espia espia;
  setUp(() => espia = _Espia());

  group('pedir el cambio', () {
    test('manda PATCH /perfil con el correo y la contrasena', () async {
      final api = _api(
        espia,
        () => _json({'id': 12, 'expira': '2026-11-26T21:40:00Z'}, 202),
      );

      final pendiente = await api.pedirCambioDeCorreo(
        correo: '  Maria.Nueva@Example.com ',
        contrasenaActual: 'CareCar2026',
      );

      expect(espia.metodo, 'PATCH');
      expect(espia.url!.path, '/api/v1/app/perfil');
      final cuerpo = jsonDecode(espia.cuerpo!) as Map<String, Object?>;
      // El correo se recorta, como en el login: el teclado del celular mete
      // espacios con facilidad. La contrasena no se toca.
      expect(cuerpo['correo'], 'Maria.Nueva@Example.com');
      expect(cuerpo['contrasenaActual'], 'CareCar2026');
      expect(pendiente.id, 12);
      expect(pendiente.expira, DateTime.utc(2026, 11, 26, 21, 40));
    });

    test('la contrasena equivocada llega como DatosInvalidos con su codigo', () async {
      // 400 y no 401 a proposito: un 401 se leeria como sesion vencida. Lo que
      // la separa de un correo mal escrito es el codigo, no el status.
      final api = _api(espia, () => _problema(400, 'CREDENCIALES_INVALIDAS'));

      await expectLater(
        api.pedirCambioDeCorreo(
          correo: 'nuevo@example.com',
          contrasenaActual: 'mala',
        ),
        throwsA(
          isA<DatosInvalidos>().having(
            (e) => e.problema?.codigo,
            'codigo',
            CodigoProblema.credencialesInvalidas,
          ),
        ),
      );
    });

    test('un correo de otro cliente llega como Conflicto', () async {
      final api = _api(espia, () => _problema(409, 'DATOS_INVALIDOS'));

      await expectLater(
        api.pedirCambioDeCorreo(
          correo: 'cliente2@example.com',
          contrasenaActual: 'CareCar2026',
        ),
        throwsA(isA<Conflicto>()),
      );
    });
  });

  group('confirmar', () {
    test('manda el codigo y devuelve el perfil ya actualizado', () async {
      final api = _api(
        espia,
        () => _json({
          'id': 1,
          'nombre': 'María Elena Robles',
          'correo': 'maria.nueva@example.com',
          'telefono': '477 123 4567',
          'clienteDesde': '2022-05-18',
        }),
      );

      final perfil = await api.confirmarVerificacion(
        id: 12,
        codigo: ' 123456 ',
      );

      expect(espia.metodo, 'POST');
      expect(espia.url!.path, '/api/v1/app/perfil/verificaciones/12/confirmar');
      expect(jsonDecode(espia.cuerpo!), {'codigo': '123456'});
      // La respuesta es el perfil nuevo, asi que la pantalla no tiene que
      // volver a pedirlo ni adivinar que quedo guardado.
      expect(perfil.correo, 'maria.nueva@example.com');
      expect(perfil.telefono, '477 123 4567');
    });

    test('un codigo invalido llega con CODIGO_INVALIDO', () async {
      final api = _api(espia, () => _problema(400, 'CODIGO_INVALIDO'));

      await expectLater(
        api.confirmarVerificacion(id: 12, codigo: '000000'),
        throwsA(
          isA<DatosInvalidos>().having(
            (e) => e.problema?.codigo,
            'codigo',
            CodigoProblema.codigoInvalido,
          ),
        ),
      );
    });

    test(
      'una verificacion ajena o inexistente llega como NoEncontrado',
      () async {
        final api = _api(espia, () => _problema(404, 'NO_ENCONTRADO'));

        await expectLater(
          api.confirmarVerificacion(id: 999, codigo: '123456'),
          throwsA(isA<NoEncontrado>()),
        );
      },
    );
  });

  group('el modelo de la verificacion', () {
    test('lee el id y cuando vence', () {
      final v = VerificacionPendiente.fromJson({
        'id': 7,
        'expira': '2026-11-26T21:40:00Z',
      });

      expect(v.id, 7);
      expect(v.expira, DateTime.utc(2026, 11, 26, 21, 40));
      expect(v.expira.isUtc, isTrue);
    });

    test('sin expira falla: el contrato lo exige', () {
      expect(
        () => VerificacionPendiente.fromJson({'id': 7}),
        throwsFormatException,
      );
    });
  });
}
