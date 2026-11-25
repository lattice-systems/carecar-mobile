// Contrato v2 · aviso de privacidad (V2-M22.01).
//
// Lee api/agencia360-api-app-v2.yaml y comprueba que lo de esta historia sigue
// como la app lo espera: esquemas, propiedades, operaciones y codigo de error.

import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'AvisoPrivacidad': {
    'id',
    'version',
    'texto',
    'vigenteDesde',
    'aceptado',
    'aceptadoEn',
  },
  'AceptarAviso': {'avisoId'},
  'AceptacionAviso': {'avisoId', 'version', 'aceptadoEn'},
};

const _obligatorios = <String, Set<String>>{
  'AvisoPrivacidad': {'id', 'version', 'texto', 'vigenteDesde', 'aceptado'},
  'AceptarAviso': {'avisoId'},
  'AceptacionAviso': {'avisoId', 'version', 'aceptadoEn'},
};

const _operaciones = <String>{
  'GET /privacidad/aviso',
  'POST /privacidad/aceptaciones',
};

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae el aviso de privacidad (M22.01)', () {
    test('la version es 2.13.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(13));
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

    test('declara las dos operaciones', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('aceptar puede responder 404 y 409', () {
      final aceptar = contrato['paths']['/privacidad/aceptaciones']['post'];
      final respuestas = aceptar['responses'] as YamlMap;
      expect(respuestas.containsKey('404'), isTrue);
      expect(respuestas.containsKey('409'), isTrue);
    });

    test('«aceptadoEn» del aviso puede ser nulo', () {
      final aviso = esquemas['AvisoPrivacidad']['properties']['aceptadoEn'];
      expect(aviso['nullable'], isTrue);
    });

    test('Problema.codigo trae AVISO_NO_VIGENTE y la app lo mapea', () {
      final enElContrato =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      final queLaAppMapea = CodigoProblema.values
          .where((c) => c != CodigoProblema.desconocido)
          .map((c) => c.enElContrato)
          .toSet();

      expect(enElContrato, contains('AVISO_NO_VIGENTE'));
      expect(queLaAppMapea, enElContrato);
    });
  });
}
