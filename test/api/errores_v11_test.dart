// Lo que la v1.1 agrega al manejo de errores (TEC-6 T5).
//
// Cubre las tres reglas nuevas:
//   RIC-15 · `Problema.codigo` y decidir por el antes que por el `status`.
//   RIC-14 · el `message` del servidor NO se muestra en 400 ni en 5xx.
//   RIC-5  · el 429 con `Retry-After`.
//
// La tercera prueba de este archivo es la que mas importa para APP-2.3: el
// codigo de recuperacion invalido y una contrasena que no cumple son los dos
// un 400, y solo el `codigo` los distingue.

import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ClienteApi _clienteQueResponde(http.Response respuesta) => ClienteApi(
  config: ApiConfig.para('http://local/api/v1/app'),
  http: MockClient((_) async => respuesta),
);

String _cuerpoDeError({
  required int status,
  required String message,
  String? codigo,
}) => jsonEncode({
  'timestamp': '2026-10-20T12:00:00Z',
  'status': status,
  'error': 'Error',
  'message': message,
  ?'codigo': codigo,
  'path': '/api/v1/app/auth/login',
});

void main() {
  group('Problema lee el codigo de la v1.1', () {
    test('lo mapea cuando viene', () {
      final p = Problema.fromJson(const {
        'timestamp': 't',
        'status': 400,
        'error': 'Bad Request',
        'message': 'x',
        'codigo': 'CODIGO_INVALIDO',
        'path': '/p',
      });

      expect(p.codigo, CodigoProblema.codigoInvalido);
    });

    test('sin codigo queda en desconocido, no falla', () {
      final p = Problema.fromJson(const {
        'timestamp': 't',
        'status': 400,
        'error': 'Bad Request',
        'message': 'x',
        'path': '/p',
      });

      expect(p.codigo, CodigoProblema.desconocido);
    });

    test('un codigo que el contrato no declara tampoco rompe la app', () {
      final p = Problema.fromJson(const {
        'timestamp': 't',
        'status': 400,
        'error': 'Bad Request',
        'message': 'x',
        'codigo': 'ALGO_QUE_NO_EXISTE_TODAVIA',
        'path': '/p',
      });

      expect(p.codigo, CodigoProblema.desconocido);
    });

    test('los ocho valores del contrato estan mapeados', () {
      const enElContrato = {
        'CREDENCIALES_INVALIDAS',
        'CUENTA_DESACTIVADA',
        'DEMASIADOS_INTENTOS',
        'CODIGO_INVALIDO',
        'DATOS_INVALIDOS',
        'FRANJA_SIN_CUPO',
        'FUERA_DE_PLAZO',
        'CITA_NO_CANCELABLE',
      };

      final queLaAppMapea = CodigoProblema.values
          .where((c) => c != CodigoProblema.desconocido)
          .map((c) => c.enElContrato)
          .toSet();

      expect(queLaAppMapea, enElContrato);
    });
  });

  group('RIC-14 · cuando se muestra el message del servidor', () {
    test('en 401 se muestra tal cual', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 401,
            message: 'Correo o contrasena incorrectos',
          ),
          401,
        ),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(
          isA<CredencialesInvalidas>().having(
            (e) => e.mensaje,
            'mensaje',
            'Correo o contrasena incorrectos',
          ),
        ),
      );
    });

    test('en 400 NO se muestra: trae nombres de campos', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 400,
            message:
                'contrasenaNueva: must match "^(?=.*[A-Za-z])(?=.*\\d).+\$"',
          ),
          400,
        ),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(
          isA<DatosInvalidos>().having(
            (e) => e.mensaje,
            'mensaje',
            isNot(contains('contrasenaNueva')),
          ),
        ),
      );
    });

    test('en 500 NO se muestra: trae el detalle tecnico', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 500,
            message: 'java.lang.NullPointerException at CuentaService.java:142',
          ),
          500,
        ),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(
          isA<ErrorDelServidor>().having(
            (e) => e.mensaje,
            'mensaje',
            isNot(contains('NullPointerException')),
          ),
        ),
      );
    });
  });

  group('RIC-15 · el codigo distingue dos errores con el mismo 400', () {
    // Es el caso que APP-2.3 necesita: en la pantalla de restablecer, el
    // codigo vencido y la contrasena que no cumple llegan los dos como 400.

    test('CODIGO_INVALIDO habla del codigo', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 400,
            message: 'detalle tecnico que no se muestra',
            codigo: 'CODIGO_INVALIDO',
          ),
          400,
        ),
      );

      await expectLater(
        cliente.enviar(
          '/auth/restablecer-contrasena',
          cuerpo: const {},
          leer: (_) => null,
        ),
        throwsA(
          isA<DatosInvalidos>().having(
            (e) => e.mensaje.toLowerCase(),
            'mensaje',
            contains('código'),
          ),
        ),
      );
    });

    test('DATOS_INVALIDOS habla de los datos, no del codigo', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 400,
            message: 'detalle tecnico que no se muestra',
            codigo: 'DATOS_INVALIDOS',
          ),
          400,
        ),
      );

      await expectLater(
        cliente.enviar(
          '/auth/restablecer-contrasena',
          cuerpo: const {},
          leer: (_) => null,
        ),
        throwsA(
          isA<DatosInvalidos>().having(
            (e) => e.mensaje.toLowerCase(),
            'mensaje',
            isNot(contains('código')),
          ),
        ),
      );
    });
  });

  group('RIC-5 · el 429 por demasiados intentos', () {
    test('se reporta aparte, no como error del servidor', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(
            status: 429,
            message: 'Demasiados intentos. Intenta de nuevo mas tarde.',
            codigo: 'DEMASIADOS_INTENTOS',
          ),
          429,
        ),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(isA<DemasiadosIntentos>()),
      );
    });

    test('lee Retry-After y lo vuelve texto', () async {
      final cliente = _clienteQueResponde(
        http.Response(
          _cuerpoDeError(status: 429, message: 'bloqueado'),
          429,
          headers: const {'retry-after': '900'},
        ),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(
          isA<DemasiadosIntentos>()
              .having((e) => e.esperaSegundos, 'segundos', 900)
              .having((e) => e.esperaLegible, 'legible', '15 minutos'),
        ),
      );
    });

    test('sin Retry-After no inventa un tiempo', () async {
      final cliente = _clienteQueResponde(
        http.Response(_cuerpoDeError(status: 429, message: 'bloqueado'), 429),
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (_) => null),
        throwsA(
          isA<DemasiadosIntentos>()
              .having((e) => e.esperaSegundos, 'segundos', isNull)
              .having((e) => e.esperaLegible, 'legible', isNull),
        ),
      );
    });

    test('redondea los segundos hacia arriba', () {
      expect(
        const DemasiadosIntentos('x', esperaSegundos: 45).esperaLegible,
        '45 segundos',
      );
      expect(
        const DemasiadosIntentos('x', esperaSegundos: 61).esperaLegible,
        '2 minutos',
      );
      expect(
        const DemasiadosIntentos('x', esperaSegundos: 60).esperaLegible,
        '1 minuto',
      );
    });
  });

  group('RIC-9 · reglas de la contrasena', () {
    test('acepta una que cumple', () {
      expect(ReglasContrasena.revisar('CareCar2026'), isNull);
    });

    test('rechaza menos de 8 caracteres', () {
      expect(ReglasContrasena.revisar('Corta1'), contains('8'));
    });

    test('rechaza mas de 72', () {
      expect(ReglasContrasena.revisar('a1${'x' * 80}'), contains('72'));
    });

    test('exige al menos una letra', () {
      expect(ReglasContrasena.revisar('12345678'), contains('letra'));
    });

    test('exige al menos un numero', () {
      expect(ReglasContrasena.revisar('solamenteletras'), contains('número'));
    });

    test('la nueva no puede ser igual a la actual', () {
      expect(
        ReglasContrasena.revisar('CareCar2026', actual: 'CareCar2026'),
        contains('distinta'),
      );
    });
  });

  group('PeticionLogin y PeticionRestablecer usan las claves de la v1.1', () {
    test('el login manda correo, no usuario', () {
      const p = PeticionLogin(correo: 'a@b.com', contrasena: 'x');
      expect(p.toJson(), const {'correo': 'a@b.com', 'contrasena': 'x'});
      expect(p.toJson().containsKey('usuario'), isFalse);
    });

    test('recorta los espacios del correo', () {
      const p = PeticionLogin(correo: '  a@b.com  ', contrasena: 'x');
      expect(p.toJson()['correo'], 'a@b.com');
    });

    test('restablecer manda correo, codigo y contrasenaNueva', () {
      const p = PeticionRestablecer(
        correo: 'a@b.com',
        codigo: '123456',
        contrasenaNueva: 'Nueva1234',
      );

      expect(p.toJson(), const {
        'correo': 'a@b.com',
        'codigo': '123456',
        'contrasenaNueva': 'Nueva1234',
      });
      expect(p.toJson().containsKey('token'), isFalse);
    });
  });
}
