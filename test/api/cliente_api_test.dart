import 'dart:convert';
import 'dart:io';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _config = ApiConfig.para('http://localhost:3000/api/v1/app');

ClienteApi _clienteQueResponde(
  http.Response Function(http.Request) responder, {
  Future<String?> Function()? token,
}) {
  return ClienteApi(
    config: _config,
    http: MockClient((req) async => responder(req)),
    obtenerToken: token,
  );
}

http.Response _problema(int status, String mensaje) => http.Response(
  jsonEncode({
    'timestamp': '2026-10-13T19:51:05.258Z',
    'status': status,
    'error': 'Error',
    'message': mensaje,
    'path': '/api/v1/app/prueba',
  }),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test(
    'el tiempo limite por omision cubre el arranque en frio del servidor',
    () {
      // Azure Container Apps tarda ~35 s en despertar (V2-M01.12).
      final cliente = ClienteApi(config: _config);
      expect(cliente.tiempoLimite, const Duration(seconds: 60));
      expect(cliente.tiempoLimite, greaterThan(const Duration(seconds: 35)));
      cliente.cerrar();
    },
  );

  group('armado de la peticion', () {
    test(
      'lee un flujo SSE en eventos con su nombre y datos (V2-M24.09)',
      () async {
        final cliente = ClienteApi(
          config: _config,
          obtenerToken: () async => 't',
          http: MockClient.streaming((req, _) async {
            expect(
              req.headers['accept'],
              'text/event-stream, application/json',
            );
            expect(req.headers['authorization'], 'Bearer t');
            return http.StreamedResponse(
              Stream.fromIterable([
                utf8.encode('event:texto\ndata:{"texto":"Ho"}\n\n'),
                utf8.encode('event:texto\ndata:{"texto":"la"}\n\nevent:fin\n'),
                utf8.encode('data:{"ok":true}\n\n'),
              ]),
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }),
        );

        final eventos = await cliente
            .enviarFlujo('/asistente/preguntas/flujo', cuerpo: {'a': 1})
            .toList();

        expect(eventos.map((e) => e.evento), ['texto', 'texto', 'fin']);
        expect(eventos.first.datos, {'texto': 'Ho'});
        expect(eventos.last.datos, {'ok': true});
      },
    );

    test('un error antes del flujo llega como su excepcion', () async {
      final cliente = ClienteApi(
        config: _config,
        http: MockClient.streaming(
          (_, _) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                '{"timestamp":"x","status":409,"error":"x","message":"Sin manual",'
                '"path":"/x","codigo":"ASISTENTE_SIN_MANUAL"}',
              ),
            ),
            409,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      expect(
        cliente.enviarFlujo('/x', cuerpo: const {}).toList(),
        throwsA(isA<Conflicto>()),
      );
    });

    test(
      'manda un archivo como multipart con sus campos (V2-M24.05)',
      () async {
        http.Request? pedida;
        final cliente = _clienteQueResponde((req) {
          pedida = req;
          return http.Response(
            '{"ok":true}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }, token: () async => 't');

        final r = await cliente.enviarArchivo(
          '/asistente/testigos',
          campos: {'vehiculoId': '7'},
          nombreArchivo: 'imagen',
          bytes: [1, 2, 3],
          tipo: 'image/jpeg',
          leer: (j) => j['ok'],
        );

        expect(r, true);
        expect(pedida!.method, 'POST');
        expect(
          pedida!.headers['content-type'],
          startsWith('multipart/form-data'),
        );
        expect(pedida!.headers['authorization'], 'Bearer t');
        final cuerpo = latin1.decode(pedida!.bodyBytes);
        expect(cuerpo, contains('name="vehiculoId"'));
        expect(cuerpo, contains('name="imagen"'));
        expect(cuerpo, contains('content-type: image/jpeg'));
      },
    );

    test('pega la ruta a la direccion configurada', () async {
      Uri? pedida;
      final cliente = _clienteQueResponde((req) {
        pedida = req.url;
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await cliente.obtenerLista('/vehiculos', (j) => j);

      expect(pedida.toString(), 'http://localhost:3000/api/v1/app/vehiculos');
    });

    test('de una respuesta paginada toma su contenido', () async {
      final cliente = _clienteQueResponde(
        (_) => http.Response(
          '{"contenido":[{"id":1},{"id":2}],"pagina":0,"tamano":20,'
          '"totalElementos":2,"totalPaginas":1}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      final lista = await cliente.obtenerLista('/citas', (j) => j['id']);

      expect(lista, [1, 2]);
    });

    test('manda el token como Bearer cuando hay sesion', () async {
      String? autorizacion;
      final cliente = _clienteQueResponde((req) {
        autorizacion = req.headers['authorization'];
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
        );
      }, token: () async => 'abc.def.ghi');

      await cliente.obtenerLista('/vehiculos', (j) => j);

      expect(autorizacion, 'Bearer abc.def.ghi');
    });

    test('no manda el encabezado cuando no hay sesion', () async {
      String? autorizacion;
      final cliente = _clienteQueResponde((req) {
        autorizacion = req.headers['authorization'];
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await cliente.enviar(
        '/auth/login',
        cuerpo: {'correo': 'a'},
        leer: (j) => j,
      );

      expect(autorizacion, isNull);
    });

    test('manda el cuerpo como JSON', () async {
      String? cuerpo;
      String? tipo;
      final cliente = _clienteQueResponde((req) {
        cuerpo = req.body;
        tipo = req.headers['content-type'];
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await cliente.enviar(
        '/auth/login',
        cuerpo: {'correo': 'cliente1@example.com', 'contrasena': 'x'},
        leer: (j) => j,
      );

      expect(jsonDecode(cuerpo!), {
        'correo': 'cliente1@example.com',
        'contrasena': 'x',
      });
      expect(tipo, contains('application/json'));
    });
  });

  group('mapeo de errores del contrato', () {
    test('401 se convierte en credenciales invalidas', () async {
      final cliente = _clienteQueResponde(
        (_) => _problema(401, 'Usuario o contrasena incorrectos'),
      );
      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<CredencialesInvalidas>()),
      );
    });

    test('403 se convierte en cuenta desactivada', () async {
      final cliente = _clienteQueResponde(
        (_) => _problema(403, 'La cuenta esta desactivada'),
      );
      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<CuentaDesactivada>()),
      );
    });

    test('404 se convierte en no encontrado', () async {
      final cliente = _clienteQueResponde(
        (_) => _problema(404, 'No existe o no pertenece'),
      );
      await expectLater(
        cliente.obtenerLista('/vehiculos/9/servicios', (j) => j),
        throwsA(isA<NoEncontrado>()),
      );
    });

    test(
      '409 se convierte en conflicto y conserva el mensaje del backend',
      () async {
        final cliente = _clienteQueResponde(
          (_) => _problema(409, 'La franja ya no tiene cupo'),
        );
        await expectLater(
          cliente.enviar('/citas', cuerpo: const {}, leer: (j) => j),
          throwsA(
            isA<Conflicto>().having(
              (e) => e.mensaje,
              'mensaje',
              'La franja ya no tiene cupo',
            ),
          ),
        );
      },
    );

    test('400 se convierte en datos invalidos', () async {
      final cliente = _clienteQueResponde(
        (_) => _problema(400, 'Falta el correo'),
      );
      await expectLater(
        cliente.enviar(
          '/auth/recuperar-contrasena',
          cuerpo: const {},
          leer: (j) => j,
        ),
        throwsA(isA<DatosInvalidos>()),
      );
    });

    test('500 se convierte en error del servidor', () async {
      final cliente = _clienteQueResponde((_) => _problema(500, 'Boom'));
      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<ErrorDelServidor>()),
      );
    });

    test('un 409 sin cuerpo JSON no tumba el mapeo', () async {
      final cliente = _clienteQueResponde(
        (_) => http.Response('<html>502</html>', 409),
      );
      await expectLater(
        cliente.enviar('/citas', cuerpo: const {}, leer: (j) => j),
        throwsA(isA<Conflicto>()),
      );
    });
  });

  group('fallos de red', () {
    test(
      'un socket caido se convierte en sin conexion, no en error del servidor',
      () async {
        final cliente = ClienteApi(
          config: _config,
          http: MockClient(
            (_) async => throw const SocketException('sin ruta al host'),
          ),
        );
        await expectLater(
          cliente.obtenerLista('/vehiculos', (j) => j),
          throwsA(isA<SinConexion>()),
        );
      },
    );

    test('un error del cliente http se convierte en sin conexion', () async {
      final cliente = ClienteApi(
        config: _config,
        http: MockClient(
          (_) async => throw http.ClientException('conexion cerrada'),
        ),
      );
      await expectLater(
        cliente.obtenerLista('/vehiculos', (j) => j),
        throwsA(isA<SinConexion>()),
      );
    });

    test(
      'el mensaje de sin conexion dice que hacer, no culpa al usuario',
      () async {
        final cliente = ClienteApi(
          config: _config,
          http: MockClient((_) async => throw const SocketException('x')),
        );
        try {
          await cliente.obtenerLista('/vehiculos', (j) => j);
          fail('debio lanzar');
        } on SinConexion catch (e) {
          expect(
            e.mensaje,
            'No se pudo conectar con el servidor. Intenta de nuevo.',
          );
        }
      },
    );
  });

  group('lectura de respuestas', () {
    test('204 sin cuerpo no truena al leer', () async {
      final cliente = _clienteQueResponde((_) => http.Response('', 204));
      await expectLater(
        cliente.enviarSinRespuesta(
          '/auth/cambiar-contrasena',
          cuerpo: const {},
        ),
        completes,
      );
    });

    test('202 sin cuerpo no truena al leer', () async {
      final cliente = _clienteQueResponde((_) => http.Response('', 202));
      await expectLater(
        cliente.enviarSinRespuesta(
          '/auth/recuperar-contrasena',
          cuerpo: const {},
        ),
        completes,
      );
    });

    test('convierte una lista JSON con el lector que se le pasa', () async {
      final cliente = _clienteQueResponde(
        (_) => http.Response(
          jsonEncode([
            {'id': 1},
            {'id': 2},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      final ids = await cliente.obtenerLista(
        '/vehiculos',
        (j) => j['id'] as int,
      );

      expect(ids, [1, 2]);
    });

    test(
      'un JSON mal formado se reporta como respuesta invalida, no como exito',
      () async {
        final cliente = _clienteQueResponde(
          (_) => http.Response(
            '{ roto',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );
        await expectLater(
          cliente.obtenerLista('/vehiculos', (j) => j),
          throwsA(isA<RespuestaInvalida>()),
        );
      },
    );
  });

  group('descarga de archivos', () {
    test('devuelve los bytes del PDF del ticket', () async {
      final cliente = _clienteQueResponde(
        (_) => http.Response.bytes(
          [0x25, 0x50, 0x44, 0x46],
          200,
          headers: {'content-type': 'application/pdf'},
        ),
      );

      final bytes = await cliente.descargar('/servicios/1/ticket');

      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test('un 404 al descargar tambien se mapea', () async {
      final cliente = _clienteQueResponde((_) => _problema(404, 'No existe'));
      await expectLater(
        cliente.descargar('/servicios/9/ticket'),
        throwsA(isA<NoEncontrado>()),
      );
    });
  });
  group('actualizar y eliminar (V2-M17.01)', () {
    test(
      'actualizar manda PUT con el cuerpo en JSON y lee el objeto',
      () async {
        String? metodo;
        String? cuerpo;
        final cliente = _clienteQueResponde((req) {
          metodo = req.method;
          cuerpo = req.body;
          return http.Response(
            jsonEncode({'id': 4}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final id = await cliente.actualizar<int>(
          '/direcciones/4',
          cuerpo: {'alias': 'Casa'},
          leer: (j) => j['id']! as int,
        );

        expect(id, 4);
        expect(metodo, 'PUT');
        expect(jsonDecode(cuerpo!), {'alias': 'Casa'});
      },
    );

    test('un 422 sin codigo es una SolicitudRechazada desconocida', () async {
      final cliente = _clienteQueResponde((_) => _problema(422, 'Fuera'));
      await expectLater(
        cliente.actualizar<int>(
          '/direcciones/4',
          cuerpo: const {},
          leer: (j) => 0,
        ),
        throwsA(
          isA<SolicitudRechazada>()
              .having(
                (e) => e is SinParametrosDeValuacion,
                'sin parametros',
                false,
              )
              .having((e) => e.codigo, 'codigo', CodigoProblema.desconocido),
        ),
      );
    });

    test('un 422 se distingue por su codigo', () async {
      Future<Object?> pedir(String codigo) async {
        final cliente = _clienteQueResponde(
          (_) => http.Response(
            jsonEncode({
              'timestamp': 't',
              'status': 422,
              'error': 'Error',
              'message': 'm',
              'path': '/p',
              'codigo': codigo,
            }),
            422,
            headers: {'content-type': 'application/json'},
          ),
        );
        try {
          await cliente.actualizar<int>('/x', cuerpo: const {}, leer: (j) => 0);
        } on Object catch (e) {
          return e;
        }
        return null;
      }

      final cobertura = await pedir('FUERA_DE_COBERTURA');
      expect(cobertura, isA<SolicitudRechazada>());
      expect(cobertura, isNot(isA<SinParametrosDeValuacion>()));
      expect(
        (cobertura! as SolicitudRechazada).codigo,
        CodigoProblema.fueraDeCobertura,
      );
      expect(
        await pedir('SIN_PARAMETROS_DE_VALUACION'),
        isA<SinParametrosDeValuacion>(),
      );
    });

    test('eliminar manda DELETE y acepta un 204 sin cuerpo', () async {
      String? metodo;
      final cliente = _clienteQueResponde((req) {
        metodo = req.method;
        return http.Response('', 204);
      });

      await cliente.eliminar('/direcciones/4');

      expect(metodo, 'DELETE');
    });

    test('eliminar mapea un 409 a Conflicto', () async {
      final cliente = _clienteQueResponde((_) => _problema(409, 'En uso'));
      await expectLater(
        cliente.eliminar('/direcciones/4'),
        throwsA(isA<Conflicto>()),
      );
    });
  });
}
