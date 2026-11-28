import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

const _metodos = {
  'get',
  'post',
  'put',
  'patch',
  'delete',
  'head',
  'options',
  'trace',
};
const _login = {'correo': 'cliente1@example.com', 'contrasena': 'CareCar2026'};
const _limite = Duration(seconds: 10);

void main() {
  final contrato = loadYaml(
    File('api/agencia360-api-app-v2.yaml').readAsStringSync(),
  ) as YamlMap;
  final operaciones = <String, YamlMap>{
    for (final ruta in (contrato['paths'] as YamlMap).entries)
      for (final op in (ruta.value as YamlMap).entries)
        if (_metodos.contains(op.key))
          '${(op.key as String).toUpperCase()} ${ruta.key}':
              op.value as YamlMap,
  };

  Process? proceso;
  late http.Client cliente;
  late String base;
  late List<String> rutasDelMock;

  Future<http.Response> pedir(
    String metodo,
    String ruta, {
    Map<String, Object>? cuerpo,
    String? token,
  }) async {
    final peticion = http.Request(metodo, Uri.parse('$base$ruta'));
    if (token != null) peticion.headers['Authorization'] = 'Bearer $token';
    if (cuerpo != null) {
      peticion.headers['Content-Type'] = 'application/json';
      peticion.body = jsonEncode(cuerpo);
    }
    return cliente
        .send(peticion)
        .then(http.Response.fromStream)
        .timeout(_limite);
  }

  Object? verificarRespuesta(
    String operacion,
    http.Response respuesta,
    int estado,
    String tipo,
  ) {
    expect(respuesta.statusCode, estado, reason: operacion);
    final respuestas = operaciones[operacion]!['responses'] as YamlMap;
    final declarada = _resolver(contrato, respuestas['$estado'] as YamlMap);
    final contenido = declarada['content'] as YamlMap;
    expect(contenido, contains(tipo), reason: '$operacion $estado en OpenAPI');
    expect(
      respuesta.headers['content-type']?.split(';').first,
      tipo,
      reason: operacion,
    );
    if (tipo != 'application/json') return null;
    final datos = jsonDecode(respuesta.body);
    _verificarEsquema(
      contrato,
      contenido[tipo]['schema'] as YamlMap,
      datos,
      operacion,
    );
    return datos;
  }

  group(
    'V2-T03.06: mock_api respeta OpenAPI v2',
    () {
      setUpAll(() async {
        cliente = http.Client();
        final servidor = await Process.start('node', [
          'mock_api/pruebas/servidor_contrato.js',
        ]);
        proceso = servidor;
        final errores = servidor.stderr.transform(utf8.decoder).join();
        final inicio = servidor.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .first;
        final mensaje = await Future.any([
          inicio,
          servidor.exitCode.then(
            (codigo) async => throw StateError(
              'mock_api salió con $codigo: ${await errores}',
            ),
          ),
        ]).timeout(_limite);
        final datos = jsonDecode(mensaje) as Map<String, dynamic>;
        base = datos['base'] as String;
        rutasDelMock = (datos['operaciones'] as List).cast<String>();
      });

      tearDownAll(() async {
        cliente.close();
        final servidor = proceso;
        if (servidor != null) {
          servidor.kill();
          await servidor.exitCode;
        }
      });

      test(
        'catálogo simulado filtra, adjunta cupón y registra la conversión',
        () async {
          final login = await pedir('POST', '/auth/login', cuerpo: _login);
          final token =
              (jsonDecode(login.body) as Map<String, dynamic>)['accessToken']
                  as String;
          final sinMarch = await pedir(
            'POST',
            '/auth/login',
            cuerpo: {
              'correo': 'cliente2@example.com',
              'contrasena': 'Temporal123',
            },
          );
          final otroToken =
              (jsonDecode(sinMarch.body) as Map<String, dynamic>)['accessToken']
                  as String;

          final publicaciones = await pedir('GET', '/novedades', token: token);
          expect(publicaciones.statusCode, 200);
          final novedades = (jsonDecode(publicaciones.body) as List)
              .cast<Map<String, dynamic>>();
          expect(novedades.single['cuerpo'], contains('ficticia'));

          final respuesta = await pedir('GET', '/promociones', token: token);
          expect(respuesta.statusCode, 200);
          final ofertas = (jsonDecode(respuesta.body) as List)
              .cast<Map<String, dynamic>>();
          expect(ofertas.single['id'], 1);
          expect(ofertas.single['vehiculosIds'], [5]);

          final otras = await pedir('GET', '/promociones', token: otroToken);
          expect(otras.statusCode, 200);
          expect(jsonDecode(otras.body), isEmpty);
          expect(
            (await pedir(
              'POST',
              '/promociones/1/vista',
              token: otroToken,
            )).statusCode,
            404,
          );
          for (var i = 0; i < 2; i++) {
            expect(
              (await pedir(
                'POST',
                '/promociones/1/vista',
                token: token,
              )).statusCode,
              204,
            );
          }

          final cita = {
            'vehiculoId': 5,
            'franjaId': 1,
            'fecha': '2026-10-20',
            'motivo': 'MANTENIMIENTO',
            'promocionId': 1,
          };
          expect(
            (await pedir(
              'POST',
              '/citas',
              token: token,
              cuerpo: {...cita, 'vehiculoId': 6},
            )).statusCode,
            400,
          );
          final confirmada = await pedir(
            'POST',
            '/citas',
            token: token,
            cuerpo: cita,
          );
          expect(confirmada.statusCode, 201, reason: confirmada.body);
          expect(
            (jsonDecode(confirmada.body) as Map<String, dynamic>)['cupon'],
            'DEMO-CARECAR',
          );

          final guardadas = await pedir('GET', '/citas', token: token);
          final datos =
              ((jsonDecode(guardadas.body) as Map<String, dynamic>)['contenido']
                      as List)
                  .cast<Map<String, dynamic>>();
          expect(
            datos.where((cita) => cita['cupon'] == 'DEMO-CARECAR'),
            hasLength(1),
          );

          final metricas = await cliente.get(
            Uri.parse(base).replace(path: '/promocionesVistas'),
          );
          expect(metricas.statusCode, 200);
          final vistas = (jsonDecode(metricas.body) as List)
              .cast<Map<String, dynamic>>();
          expect(vistas.single['promocionId'], 1);
          expect(vistas.single['vistaEn'], isA<String>());
          expect(vistas.single['usadaEn'], isA<String>());
        },
      );

      test('la factura publicada se descarga como PDF autenticado', () async {
        final sesion = await pedir('POST', '/auth/login', cuerpo: _login);
        final token =
            (jsonDecode(sesion.body) as Map<String, dynamic>)['accessToken']
                as String;
        final respuesta = await pedir(
          'GET',
          '/documentos/4/archivo',
          token: token,
        );
        verificarRespuesta(
          'GET /documentos/{documentoId}/archivo',
          respuesta,
          200,
          'application/pdf',
        );
        expect(
          respuesta.bodyBytes.take(5),
          orderedEquals([37, 80, 68, 70, 45]),
        );
      });

      test('registra cada método y ruta del contrato una sola vez', () {
        expect(
          Uri.parse(base).path,
          (contrato['servers'] as YamlList).first['url'],
        );
        expect(
          rutasDelMock,
          unorderedEquals([
            ...operaciones.keys,
            'GET /novedades',
            'GET /promociones',
            'POST /promociones/{promocionId}/vista',
          ]),
        );
      });

      test(
        'analítica acepta el catálogo y rechaza campos libres y citas ajenas',
        () async {
          final sesion = await pedir('POST', '/auth/login', cuerpo: _login);
          final token =
              (jsonDecode(sesion.body) as Map<String, dynamic>)['accessToken']
                  as String;
          const ruta = '/analitica/eventos';
          const intento = '12345678-1234-4123-8123-123456789012';
          final aceptada = await pedir(
            'POST',
            ruta,
            token: token,
            cuerpo: {'tipo': 'CONFIRMADA', 'intento': intento, 'citaId': 1},
          );
          expect(operaciones['POST $ruta']!['responses'], contains('204'));
          expect(aceptada.statusCode, 204);
          expect(
            (await pedir(
              'POST',
              ruta,
              token: token,
              cuerpo: {'tipo': 'CRASH_ANDROID'},
            )).statusCode,
            204,
          );
          expect(
            (await pedir(
              'POST',
              ruta,
              token: token,
              cuerpo: {'tipo': 'CRASH_ANDROID', 'traza': 'dato no permitido'},
            )).statusCode,
            400,
          );
          expect(
            (await pedir(
              'POST',
              ruta,
              token: token,
              cuerpo: {'tipo': 'ERROR_FLUTTER', 'mensaje': 'dato no permitido'},
            )).statusCode,
            400,
          );
          expect(
            (await pedir(
              'POST',
              ruta,
              token: token,
              cuerpo: {
                'tipo': 'CONFIRMADA',
                'intento': intento,
                'citaId': 9999,
              },
            )).statusCode,
            404,
          );
        },
      );

      test(
        'las operaciones protegidas devuelven Problema sin sesión',
        () async {
          for (final entrada in operaciones.entries) {
            final seguridad =
                (entrada.value['security'] ?? contrato['security']) as YamlList;
            if (seguridad.isEmpty) continue;
            final [metodo, plantilla] = entrada.key.split(' ');
            final ruta = plantilla.replaceAll(RegExp(r'\{[^}]+\}'), '1');
            final respuesta = await pedir(metodo, ruta);
            final problema = verificarRespuesta(
              entrada.key,
              respuesta,
              401,
              'application/json',
            ) as Map<String, dynamic>;
            expect(problema['status'], 401, reason: entrada.key);
            expect(
              problema['path'],
              '${Uri.parse(base).path}$ruta',
              reason: entrada.key,
            );
          }
        },
      );

      test(
        'valida el aplazamiento y la respuesta única de una encuesta',
        () async {
          final sesion = verificarRespuesta(
            'POST /auth/login',
            await pedir('POST', '/auth/login', cuerpo: _login),
            200,
            'application/json',
          ) as Map<String, dynamic>;
          final token = sesion['accessToken'] as String;

          Future<List<dynamic>> obtenerLista(String ruta) async =>
              verificarRespuesta(
                'GET $ruta',
                await pedir('GET', ruta, token: token),
                200,
                'application/json',
              ) as List<dynamic>;

          Future<void> comprobar204(
            String plantilla,
            String ruta, {
            Map<String, Object>? cuerpo,
          }) async {
            final operacion = operaciones['POST $plantilla']!;
            final respuesta = await pedir(
              'POST',
              ruta,
              token: token,
              cuerpo: cuerpo,
            );
            expect(operacion['responses'], contains('204'), reason: plantilla);
            expect(respuesta.statusCode, 204, reason: ruta);
            expect(respuesta.bodyBytes, isEmpty, reason: ruta);
          }

          const pendientes = '/encuestas/pendientes';
          final encuestas = await obtenerLista(pendientes);
          expect(encuestas, isNotEmpty);
          final ordenId = (encuestas.first as Map<String, dynamic>)['ordenId'];
          await comprobar204(
            '/encuestas/{ordenId}/posponer',
            '/encuestas/$ordenId/posponer',
          );
          expect(
            (await obtenerLista(
              pendientes,
            )).where((e) => (e as Map<String, dynamic>)['ordenId'] == ordenId),
            isEmpty,
          );
          const respuesta = {
            'nps': 6,
            'tiempo': 2,
            'trato': 3,
            'limpieza': 4,
            'asesor': 3,
          };
          final responder = '/encuestas/$ordenId/responder';
          await comprobar204(
            '/encuestas/{ordenId}/responder',
            responder,
            cuerpo: respuesta,
          );
          verificarRespuesta(
            'POST /encuestas/{ordenId}/responder',
            await pedir('POST', responder, token: token, cuerpo: respuesta),
            409,
            'application/json',
          );
          await comprobar204(
            '/encuestas/{ordenId}/contacto',
            '/encuestas/$ordenId/contacto',
          );

          final preferencias = await pedir(
            'PUT',
            '/notificaciones/preferencias',
            token: token,
            cuerpo: {
              'categorias': [
                {'categoria': 'MENSAJES', 'push': false},
              ],
            },
          );
          expect(preferencias.statusCode, 200);

          final rutaRespuesta = Uri.parse(base)
              .replace(path: '/simulacion/encuestas/$ordenId/respuesta');
          const textoAsesor = 'Gracias por compartir cómo te fue en el taller.';
          for (final texto in [textoAsesor, 'Reintento con otro texto']) {
            final respuestaAsesor = await cliente.post(
              rutaRespuesta,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'respuesta': texto}),
            );
            expect(respuestaAsesor.statusCode, 204);
          }

          Future<List<Map<String, dynamic>>> avisos(String token) async {
            final bandeja = await pedir('GET', '/notificaciones', token: token);
            expect(bandeja.statusCode, 200);
            final datos = jsonDecode(bandeja.body) as Map<String, dynamic>;
            return (datos['contenido'] as List).cast<Map<String, dynamic>>();
          }

          const titulo = 'La agencia respondió a tu encuesta';
          final aviso = (await avisos(token))
              .singleWhere((aviso) => aviso['titulo'] == titulo);
          expect(aviso['cuerpo'], textoAsesor);
          expect(aviso['destino'], '/encuestas');
          expect(aviso['leidaEn'], isNull);

          final otraSesion = await pedir(
            'POST',
            '/auth/login',
            cuerpo: {
              'correo': 'cliente2@example.com',
              'contrasena': 'Temporal123',
            },
          );
          final otroToken =
              (jsonDecode(otraSesion.body)
                      as Map<String, dynamic>)['accessToken']
                  as String;
          expect(
            (await avisos(otroToken)).where((n) => n['titulo'] == titulo),
            isEmpty,
          );
          final lectura = '/notificaciones/${aviso['id']}/leida';
          expect(
            (await pedir('POST', lectura, token: otroToken)).statusCode,
            404,
          );
          expect((await pedir('POST', lectura, token: token)).statusCode, 204);
          expect(
            (await avisos(token))
                .singleWhere((n) => n['id'] == aviso['id'])['leidaEn'],
            isA<String>(),
          );
        },
      );

      test(
        'valida respuestas JSON, PDF y SSE con una sesión real del mock',
        () async {
          final sesion = verificarRespuesta(
            'POST /auth/login',
            await pedir('POST', '/auth/login', cuerpo: _login),
            200,
            'application/json',
          ) as Map<String, dynamic>;
          final token = sesion['accessToken'] as String;

          final ordenes = verificarRespuesta(
            'GET /ordenes/activas',
            await pedir('GET', '/ordenes/activas', token: token),
            200,
            'application/json',
          );
          expect(ordenes, isNotEmpty);
          verificarRespuesta(
            'GET /ordenes/{ordenId}',
            await pedir('GET', '/ordenes/9999', token: token),
            404,
            'application/json',
          );
          final pdf = await pedir('GET', '/servicios/1/ticket', token: token);
          verificarRespuesta(
            'GET /servicios/{servicioId}/ticket',
            pdf,
            200,
            'application/pdf',
          );
          expect(ascii.decode(pdf.bodyBytes.take(5).toList()), '%PDF-');

          final peticion = http.Request('GET', Uri.parse('$base/eventos'))
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Accept'] = 'text/event-stream';
          final flujo = await cliente.send(peticion).timeout(_limite);
          final inicio = await flujo.stream
              .transform(utf8.decoder)
              .first
              .timeout(_limite);
          verificarRespuesta(
            'GET /eventos',
            http.Response('', flujo.statusCode, headers: flujo.headers),
            200,
            'text/event-stream',
          );
          expect(inicio, startsWith(': conectado'));
        },
      );
    },
    skip: const bool.fromEnvironment('PROBAR_MOCK_API') ? false : 'Requiere npm ci --prefix mock_api y --dart-define=PROBAR_MOCK_API=true',
  );
}

YamlMap _resolver(YamlMap contrato, YamlMap nodo) {
  final referencia = nodo[r'$ref'] as String?;
  if (referencia == null) return nodo;
  return referencia
      .substring(2)
      .split('/')
      .fold<YamlMap>(contrato, (mapa, clave) => mapa[clave] as YamlMap);
}

void _verificarEsquema(
  YamlMap contrato,
  YamlMap nodo,
  Object? valor,
  String campo,
) {
  final esquema = _resolver(contrato, nodo);
  if (valor == null && esquema['nullable'] == true) return;
  final tipo = esquema['type'];
  switch (tipo) {
    case 'object':
      expect(valor, isA<Map<String, dynamic>>(), reason: campo);
      final objeto = valor as Map<String, dynamic>;
      expect(
        objeto.keys,
        containsAll(esquema['required'] as YamlList? ?? []),
        reason: campo,
      );
      final propiedades = esquema['properties'] as YamlMap;
      for (final clave in objeto.keys.where(propiedades.containsKey)) {
        _verificarEsquema(
          contrato,
          propiedades[clave] as YamlMap,
          objeto[clave],
          '$campo.$clave',
        );
      }
    case 'array':
      expect(valor, isA<List<dynamic>>(), reason: campo);
      for (final (indice, elemento) in (valor as List).indexed) {
        _verificarEsquema(
          contrato,
          esquema['items'] as YamlMap,
          elemento,
          '$campo[$indice]',
        );
      }
    case 'string':
      expect(valor, isA<String>(), reason: campo);
    case 'integer':
      expect(valor, isA<int>(), reason: campo);
    case 'number':
      expect(valor, isA<num>(), reason: campo);
    case 'boolean':
      expect(valor, isA<bool>(), reason: campo);
  }
  if (esquema['enum'] case final YamlList valores) {
    expect(valores, contains(valor), reason: campo);
  }
}
