// Contrato v2 · Live Activity del taller (V2-M25.05) y pases de Wallet que
// siguen a la cita (V2-M25.06).
//
// Lee api/agencia360-api-app-v2.yaml y comprueba que el registro del push
// token de la Live Activity sigue como la app lo usa: rutas, cuerpo,
// respuestas y el 409 ORDEN_CERRADA que termina la actividad en el telefono.

import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';
const _ruta = '/ordenes/{ordenId}/actividad-en-vivo';

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  YamlMap operacion(String metodo) =>
      (contrato['paths'] as YamlMap)[_ruta][metodo] as YamlMap;

  Set<String> respuestas(String metodo) =>
      (operacion(metodo)['responses'] as YamlMap).keys.cast<String>().toSet();

  group('la Live Activity del taller en el contrato v2', () {
    test('declara PUT y DELETE de la actividad de una orden', () {
      final ruta = (contrato['paths'] as YamlMap)[_ruta] as YamlMap?;
      expect(ruta, isNotNull);
      expect(ruta!.keys.toSet(), containsAll(<String>{'put', 'delete'}));
    });

    test('el PUT recibe un ActividadEnVivoToken con el token hexadecimal', () {
      final cuerpo =
          operacion(
                'put',
              )['requestBody']['content']['application/json']['schema']
              as YamlMap;
      expect(cuerpo[r'$ref'], '#/components/schemas/ActividadEnVivoToken');

      final esquema = esquemas['ActividadEnVivoToken'] as YamlMap;
      expect((esquema['properties'] as YamlMap).keys.toSet(), {'pushToken'});
      expect((esquema['required'] as YamlList).cast<String>(), ['pushToken']);
      final token = esquema['properties']['pushToken'] as YamlMap;
      expect(token['type'], 'string');
      expect(token['maxLength'], 300);
      expect(token['pattern'], '^[0-9a-fA-F]+\$');
    });

    test('el PUT contesta 204 y 409 cuando la orden ya se entrego', () {
      expect(
        respuestas('put'),
        containsAll(<String>{'204', '400', '401', '403', '404', '409'}),
      );
      final conflicto = operacion('put')['responses']['409'] as YamlMap;
      expect(conflicto['description'] as String, contains('ORDEN_CERRADA'));
    });

    test('el DELETE lleva el pushToken opcional y es idempotente', () {
      final parametros = (operacion('delete')['parameters'] as YamlList)
          .whereType<YamlMap>()
          .where((p) => p['name'] == 'pushToken')
          .toList();
      expect(parametros, hasLength(1));
      expect(parametros.single['in'], 'query');
      expect(parametros.single['required'], isFalse);
      expect(respuestas('delete'), containsAll(<String>{'204', '404'}));
    });

    test('la app mapea ORDEN_CERRADA', () {
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>();
      expect(codigos, contains('ORDEN_CERRADA'));
      expect(
        CodigoProblema.desde('ORDEN_CERRADA'),
        CodigoProblema.ordenCerrada,
      );
    });
  });

  group('el pase de Wallet sigue a la cita (V2-M25.06)', () {
    test('la descripcion del pase dice que Wallet lo anula o lo cambia', () {
      final descripcion =
          contrato['paths']['/citas/{citaId}/pase']['get']['description']
              as String;
      expect(descripcion, contains('V2-M25.06'));
      expect(descripcion, contains('voided'));
      expect(descripcion, contains('EXPIRED'));
    });
  });
}
