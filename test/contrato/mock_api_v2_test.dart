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

      test('registra cada método y ruta del contrato una sola vez', () {
        expect(
          Uri.parse(base).path,
          (contrato['servers'] as YamlList).first['url'],
        );
        expect(rutasDelMock, unorderedEquals(operaciones.keys));
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
