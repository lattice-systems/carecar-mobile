import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'RegimenFiscal': {'clave', 'descripcion', 'fisica', 'moral'},
  'UsoCfdi': {'clave', 'descripcion', 'fisica', 'moral', 'regimenes'},
  'CatalogoFiscal': {'regimenes', 'usosCfdi'},
  'PerfilFiscal': {
    'id',
    'rfc',
    'tipoPersona',
    'razonSocial',
    'regimenFiscal',
    'codigoPostal',
    'usoCfdi',
    'correo',
    'predeterminado',
    'creadoEn',
  },
  'EntradaPerfilFiscal': {
    'rfc',
    'razonSocial',
    'regimenFiscal',
    'codigoPostal',
    'usoCfdi',
    'correo',
    'predeterminado',
  },
};

const _operaciones = <String>{
  'GET /catalogos-fiscales',
  'GET /perfiles-fiscales',
  'POST /perfiles-fiscales',
  'GET /perfiles-fiscales/{perfilId}',
  'PUT /perfiles-fiscales/{perfilId}',
  'DELETE /perfiles-fiscales/{perfilId}',
};

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae los datos fiscales (V2-M08.05)', () {
    test('la version es 2.23.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(23));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
      expect((esquemas['TipoPersona']['enum'] as YamlList).cast<String>(), [
        'FISICA',
        'MORAL',
      ]);
    });

    test('declara sus operaciones', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          if (metodo == 'parameters') return;
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('alta y edicion explican el 400 por campo', () {
      final paths = contrato['paths'] as YamlMap;
      for (final (ruta, metodo) in [
        ('/perfiles-fiscales', 'post'),
        ('/perfiles-fiscales/{perfilId}', 'put'),
      ]) {
        final respuestas = paths[ruta][metodo]['responses'] as YamlMap;
        expect(
          respuestas['400']['\$ref'],
          '#/components/responses/DatosFiscalesInvalidos',
          reason: '$metodo $ruta',
        );
      }
      final problema = esquemas['Problema']['properties'] as YamlMap;
      expect(problema['campos']['additionalProperties']['type'], 'string');
    });

    test('DATOS_FISCALES_INVALIDOS esta en el contrato y la app lo mapea', () {
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>();
      expect(codigos, contains('DATOS_FISCALES_INVALIDOS'));
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        contains('DATOS_FISCALES_INVALIDOS'),
      );
    });
  });
}
