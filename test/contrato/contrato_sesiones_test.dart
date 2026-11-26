import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

void main() {
  late YamlMap contrato;
  late YamlMap rutas;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    rutas = contrato['paths'] as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae las sesiones activas (V2-M01.09)', () {
    test('la version es 2.20.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(20));
    });

    test('las tres operaciones existen', () {
      expect(
        (rutas['/sesiones'] as YamlMap).keys,
        containsAll(['get', 'delete']),
      );
      expect((rutas['/sesiones/{id}'] as YamlMap).keys, contains('delete'));
    });

    test('SesionActiva trae lo que la pantalla necesita', () {
      final propiedades = (esquemas['SesionActiva']['properties'] as YamlMap)
          .keys
          .toSet();
      expect(propiedades, {
        'id',
        'dispositivo',
        'ultimoUso',
        'iniciadaEn',
        'expiraEn',
      });
    });

    test('solo id, iniciadaEn y expiraEn son obligatorios', () {
      // `dispositivo` y `ultimoUso` llegan nulos en las sesiones anteriores a
      // esta historia y en las de un cliente que no manda el nombre.
      final obligatorios = (esquemas['SesionActiva']['required'] as YamlList)
          .cast<String>()
          .toSet();
      expect(obligatorios, {'id', 'iniciadaEn', 'expiraEn'});
    });

    test('nunca se expone nada derivado del refresh token', () {
      // Si el contrato filtrara el hash, cualquier lectura de la lista seria
      // una fuga: con el hash y la tabla se puede revocar la sesion de otro.
      final propiedades = (esquemas['SesionActiva']['properties'] as YamlMap)
          .keys
          .cast<String>();
      for (final p in propiedades) {
        expect(p.toLowerCase(), isNot(contains('token')));
        expect(p.toLowerCase(), isNot(contains('hash')));
      }
    });

    test('cerrar una sesion ajena responde 404, no 403', () {
      // Es la regla del contrato para un recurso ajeno: no se revela que
      // exista. Un 403 diria «existe pero no es tuya».
      final respuestas =
          rutas['/sesiones/{id}']['delete']['responses'] as YamlMap;
      expect(respuestas.keys, containsAll(['204', '404']));
    });

    test('el login acepta el nombre del dispositivo, opcional', () {
      final login = esquemas['LoginRequest'] as YamlMap;
      expect((login['properties'] as YamlMap).keys, contains('dispositivo'));
      // Si fuera obligatorio, un cliente viejo dejaria de poder entrar.
      expect(
        (login['required'] as YamlList).cast<String>(),
        isNot(contains('dispositivo')),
      );
    });
  });
}
