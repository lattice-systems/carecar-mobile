// Contrato v2 · derechos ARCO, acceso (V2-M22.02).
//
// Lee api/agencia360-api-app-v2.yaml y comprueba que lo de esta historia sigue
// como la app lo espera: esquemas, propiedades, operaciones y valores.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'SolicitudArco': {
    'id',
    'tipo',
    'estado',
    'creadaEn',
    'resueltaEn',
    'venceEn',
  },
  'AvisoArco': {'solicitudId', 'tipo', 'estado'},
};

const _obligatorios = <String, Set<String>>{
  'SolicitudArco': {'id', 'tipo', 'estado', 'creadaEn'},
  'AvisoArco': {'solicitudId', 'tipo', 'estado'},
};

const _operaciones = <String>{
  'GET /privacidad/arco',
  'POST /privacidad/arco/acceso',
  'GET /privacidad/arco/{solicitudId}/archivo',
};

Set<String> _valoresDe(YamlMap esquema, String propiedad) =>
    ((esquema['properties'] as YamlMap)[propiedad]['enum'] as YamlList)
        .cast<String>()
        .toSet();

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae el acceso ARCO (M22.02)', () {
    test('la version es 2.14.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(14));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('cada esquema marca como obligatorio lo que se espera', () {
      _obligatorios.forEach((nombre, esperados) {
        final reales = (esquemas[nombre]['required'] as YamlList)
            .cast<String>()
            .toSet();
        expect(reales, esperados, reason: nombre);
      });
    });

    test('declara las tres operaciones', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('los tipos y estados son los que la app interpreta', () {
      final solicitud = esquemas['SolicitudArco'] as YamlMap;
      expect(_valoresDe(solicitud, 'tipo'), {
        'ACCESO',
        'RECTIFICACION',
        'CANCELACION',
        'OPOSICION',
      });
      expect(_valoresDe(solicitud, 'estado'), {
        'PENDIENTE',
        'RESUELTA',
        'FALLIDA',
        'VENCIDA',
      });
      expect(
        _valoresDe(esquemas['AvisoArco'] as YamlMap, 'estado'),
        _valoresDe(solicitud, 'estado'),
      );
    });

    test('pedir el acceso responde 202 y, si ya habia una, 200', () {
      final respuestas =
          contrato['paths']['/privacidad/arco/acceso']['post']['responses']
              as YamlMap;
      expect(respuestas.containsKey('202'), isTrue);
      expect(respuestas.containsKey('200'), isTrue);
    });

    test('«resueltaEn» y «venceEn» pueden ser nulos', () {
      final props = esquemas['SolicitudArco']['properties'] as YamlMap;
      expect(props['resueltaEn']['nullable'], isTrue);
      expect(props['venceEn']['nullable'], isTrue);
    });

    test('el evento arco.estado esta entre los de /eventos', () {
      final descripcion =
          contrato['paths']['/eventos']['get']['description'] as String;
      expect(descripcion, contains('arco.estado'));
    });
  });

  group('el contrato v2 trae la cancelacion ARCO (M22.03)', () {
    late YamlMap operacion;

    setUpAll(() {
      operacion =
          contrato['paths']['/privacidad/arco/cancelacion']['post'] as YamlMap;
    });

    test('la version es 2.15.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(15));
    });

    test('pide solo la contrasena, y como contrasena', () {
      final esquema = esquemas['CancelarCuenta'] as YamlMap;
      expect((esquema['properties'] as YamlMap).keys.toSet(), {'contrasena'});
      expect((esquema['required'] as YamlList).cast<String>(), ['contrasena']);
      expect(esquema['properties']['contrasena']['format'], 'password');
      expect(
        operacion['requestBody']['content']['application/json']['schema']['\$ref'],
        '#/components/schemas/CancelarCuenta',
      );
    });

    test('responde la solicitud, y un 400 o un 429 si la contrasena falla', () {
      final respuestas = operacion['responses'] as YamlMap;
      expect(respuestas.keys.toSet(), {'200', '400', '401', '429'});
      expect(
        respuestas['200']['content']['application/json']['schema']['\$ref'],
        '#/components/schemas/SolicitudArco',
      );
    });
  });
}
