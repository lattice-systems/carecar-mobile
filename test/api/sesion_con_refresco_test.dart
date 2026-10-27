// TEC-6 T4 · La sesion con refresco automatico.
//
// Lo que el contrato v1.1 agrego y la app no usaba (RIC-1, RIC-2, RIC-3, RIC-4):
//
//   `expiresIn` y `refreshToken` en la respuesta del login.
//   `POST /auth/refrescar`, que devuelve un par nuevo y gasta el anterior.
//   `POST /auth/cerrar-sesion`, que revoca el refresh token.
//   401 -> intentar refrescar una vez; 403 -> cerrar sesion.
//
// La regla del 401 tiene una trampa: el login tambien contesta 401 cuando las
// credenciales estan mal. Si la app intentara refrescar ahi, un error de
// contrasena se volveria un cierre de sesion. Por eso solo se refresca cuando
// la peticion original llevaba un token.

import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _base = 'http://local/api/v1/app';

String _cuerpoLogin({
  String acceso = 'acceso-1',
  String refresco = 'refresco-1',
  int expiraEn = 3600,
  bool debeCambiar = false,
}) => jsonEncode({
  'accessToken': acceso,
  'expiresIn': expiraEn,
  'refreshToken': refresco,
  'debeCambiarContrasena': debeCambiar,
});

String _cuerpoError(int status, {String? codigo}) => jsonEncode({
  'timestamp': '2026-10-27T12:00:00Z',
  'status': status,
  'error': 'Error',
  'message': 'mensaje del servidor',
  'codigo': ?codigo,
  'path': '/api/v1/app/vehiculos',
});

void main() {
  group('RespuestaLogin lee los campos que agrego la v1.1', () {
    test('trae expiresIn y refreshToken', () {
      final r = RespuestaLogin.fromJson(
        jsonDecode(_cuerpoLogin()) as Map<String, Object?>,
      );

      expect(r.accessToken, 'acceso-1');
      expect(r.expiresIn, 3600);
      expect(r.refreshToken, 'refresco-1');
      expect(r.debeCambiarContrasena, isFalse);
    });

    test('el contrato los marca obligatorios: sin ellos falla', () {
      // Son `required` en LoginResponse. Si el backend los omite, es mejor un
      // error claro que una sesion a medias que no se puede refrescar.
      expect(
        () => RespuestaLogin.fromJson(const {
          'accessToken': 'a',
          'debeCambiarContrasena': false,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('se convierte en el par que se guarda', () {
      final r = RespuestaLogin.fromJson(
        jsonDecode(_cuerpoLogin(expiraEn: 60)) as Map<String, Object?>,
      );
      final tokens = TokensSesion.deRespuesta(r);

      expect(tokens.accessToken, 'acceso-1');
      expect(tokens.refreshToken, 'refresco-1');
      expect(tokens.vencido, isFalse);
      expect(tokens.porVencer(margen: const Duration(minutes: 2)), isTrue);
    });
  });

  group('las dos operaciones nuevas del contrato', () {
    test('refrescar manda el refreshToken y devuelve un par nuevo', () async {
      late http.Request pedido;
      final api = CarecarApiHttp(
        ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((r) async {
            pedido = r;
            return http.Response(
              _cuerpoLogin(acceso: 'acceso-2', refresco: 'refresco-2'),
              200,
            );
          }),
        ),
      );

      final nueva = await api.refrescar('refresco-1');

      expect(pedido.url.path, endsWith('/auth/refrescar'));
      expect(jsonDecode(pedido.body), const {'refreshToken': 'refresco-1'});
      expect(nueva.accessToken, 'acceso-2');
      // RIC-2: el refresh es de un solo uso, asi que la respuesta trae uno
      // nuevo y hay que guardar siempre el ultimo.
      expect(nueva.refreshToken, 'refresco-2');
    });

    test('refrescar no manda el encabezado Authorization', () async {
      // La ruta es publica a proposito: debe funcionar aunque el access token
      // ya haya expirado.
      late http.Request pedido;
      final api = CarecarApiHttp(
        ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((r) async {
            pedido = r;
            return http.Response(_cuerpoLogin(), 200);
          }),
          obtenerToken: () async => 'acceso-viejo',
        ),
      );

      await api.refrescar('refresco-1');

      expect(pedido.headers.containsKey('authorization'), isFalse);
    });

    test('un refresh token vencido responde 401 y termina la sesion', () async {
      final api = CarecarApiHttp(
        ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((_) async => http.Response(_cuerpoError(401), 401)),
        ),
      );

      await expectLater(
        api.refrescar('ya-no-sirve'),
        throwsA(isA<CredencialesInvalidas>()),
      );
    });

    test('cerrarSesion manda el refreshToken y acepta el 204', () async {
      late http.Request pedido;
      final api = CarecarApiHttp(
        ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((r) async {
            pedido = r;
            return http.Response('', 204);
          }),
        ),
      );

      await api.cerrarSesion('refresco-1');

      expect(pedido.url.path, endsWith('/auth/cerrar-sesion'));
      expect(jsonDecode(pedido.body), const {'refreshToken': 'refresco-1'});
    });
  });

  group('RIC-3 · refresco automatico ante un 401', () {
    test(
      'reintenta una vez con el token nuevo y la peticion sale bien',
      () async {
        var token = 'viejo';
        final tokensUsados = <String?>[];
        var refrescos = 0;

        final cliente = ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((r) async {
            tokensUsados.add(r.headers['authorization']);
            if (r.headers['authorization'] == 'Bearer viejo') {
              return http.Response(_cuerpoError(401), 401);
            }
            return http.Response('[]', 200);
          }),
          obtenerToken: () async => token,
          renovarSesion: () async {
            refrescos++;
            token = 'nuevo';
            return true;
          },
        );

        final lista = await cliente.obtenerLista('/vehiculos', (j) => j);

        expect(lista, isEmpty);
        expect(refrescos, 1, reason: 'se refresca una sola vez');
        expect(tokensUsados, ['Bearer viejo', 'Bearer nuevo']);
      },
    );

    test('si el refresco falla, el 401 sale como estaba', () async {
      var intentos = 0;
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        http: MockClient((_) async {
          intentos++;
          return http.Response(_cuerpoError(401), 401);
        }),
        obtenerToken: () async => 'viejo',
        renovarSesion: () async => false,
      );

      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<CredencialesInvalidas>()),
      );
      expect(intentos, 1, reason: 'si el refresco falla no se reintenta');
    });

    test(
      'no entra en bucle: si el reintento tambien da 401, se rinde',
      () async {
        var intentos = 0;
        var refrescos = 0;
        final cliente = ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient((_) async {
            intentos++;
            return http.Response(_cuerpoError(401), 401);
          }),
          obtenerToken: () async => 'viejo',
          renovarSesion: () async {
            refrescos++;
            return true;
          },
        );

        await expectLater(
          cliente.obtenerLista('/vehiculos', (j) => j),
          throwsA(isA<CredencialesInvalidas>()),
        );
        expect(intentos, 2, reason: 'la original y un solo reintento');
        expect(refrescos, 1);
      },
    );

    test('un 401 SIN token no intenta refrescar: es el login', () async {
      // Es la trampa de esta tarea. El login contesta 401 con credenciales
      // malas, y ahi refrescar no tiene sentido ni nada que refrescar.
      var refrescos = 0;
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        http: MockClient((_) async => http.Response(_cuerpoError(401), 401)),
        obtenerToken: () async => null,
        renovarSesion: () async {
          refrescos++;
          return true;
        },
      );

      await expectLater(
        cliente.enviar('/auth/login', cuerpo: const {}, leer: (j) => j),
        throwsA(isA<CredencialesInvalidas>()),
      );
      expect(refrescos, 0, reason: 'sin token no hay nada que refrescar');
    });

    test(
      'un 403 nunca intenta refrescar: la cuenta esta desactivada',
      () async {
        // RIC-3: en la app un 403 solo significa cuenta desactivada, porque un
        // recurso ajeno responde 404. Refrescar no la va a reactivar.
        var refrescos = 0;
        final cliente = ClienteApi(
          config: ApiConfig.para(_base),
          http: MockClient(
            (_) async => http.Response(
              _cuerpoError(403, codigo: 'CUENTA_DESACTIVADA'),
              403,
            ),
          ),
          obtenerToken: () async => 'vigente',
          renovarSesion: () async {
            refrescos++;
            return true;
          },
        );

        await expectLater(
          cliente.obtenerLista('/vehiculos', (j) => j),
          throwsA(isA<CuentaDesactivada>()),
        );
        expect(refrescos, 0);
      },
    );

    test('sin renovarSesion configurado el 401 sale tal cual', () async {
      // Es el caso de las pruebas viejas y de cualquier cliente armado sin
      // sesion: no debe cambiar de comportamiento.
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        http: MockClient((_) async => http.Response(_cuerpoError(401), 401)),
        obtenerToken: () async => 'viejo',
      );

      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<CredencialesInvalidas>()),
      );
    });
  });
}
