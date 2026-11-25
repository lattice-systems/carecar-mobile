// Contrato v2 · estreno: prueba de manejo y cotizacion de auto nuevo
// (V2-M16.01 a V2-M16.04).
//
// Lee api/agencia360-api-app-v2.yaml y comprueba que lo de estas historias
// sigue como la app lo espera: esquemas, propiedades, operaciones, valores de
// los enums y codigos de error.

import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'CalculoEstreno': {'modeloCatalogoId', 'enganche', 'plazoMeses'},
  'CotizacionEstreno': {
    'precio',
    'enganche',
    'montoFinanciado',
    'tasaAnual',
    'plazoMeses',
    'mensualidad',
    'leyenda',
  },
  'NuevaSolicitudEstreno': {
    'tipo',
    'modeloCatalogoId',
    'preferenciaFecha',
    'preferenciaFranja',
    'enganche',
    'plazoMeses',
    'estimacionTomaCuentaId',
  },
  'SolicitudEstreno': {
    'id',
    'tipo',
    'modeloCatalogoId',
    'modelo',
    'estado',
    'vendedor',
    'preferenciaFecha',
    'preferenciaFranja',
    'cotizacion',
    'estimacionTomaCuentaId',
    'creadaEn',
  },
};

const _obligatorios = <String, Set<String>>{
  'CalculoEstreno': {'modeloCatalogoId', 'enganche', 'plazoMeses'},
  'CotizacionEstreno': {
    'precio',
    'enganche',
    'montoFinanciado',
    'tasaAnual',
    'plazoMeses',
    'mensualidad',
    'leyenda',
  },
  'NuevaSolicitudEstreno': {'tipo', 'modeloCatalogoId'},
  'SolicitudEstreno': {
    'id',
    'tipo',
    'modeloCatalogoId',
    'modelo',
    'estado',
    'creadaEn',
  },
};

const _operaciones = <String>{
  'POST /estreno/cotizaciones/calculo',
  'POST /estreno/solicitudes',
  'GET /estreno/solicitudes',
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

  group('el contrato v2 trae estreno (M16)', () {
    test('la version es 2.10.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(10));
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

    test('los valores de tipo, franja y estado son los que la app manda', () {
      final nueva = esquemas['NuevaSolicitudEstreno'] as YamlMap;
      final solicitud = esquemas['SolicitudEstreno'] as YamlMap;
      expect(_valoresDe(nueva, 'tipo'), {'PRUEBA_MANEJO', 'COTIZACION'});
      expect(_valoresDe(nueva, 'preferenciaFranja'), {'MANANA', 'TARDE'});
      expect(_valoresDe(solicitud, 'estado'), {
        'RECIBIDA',
        'EN_ATENCION',
        'CERRADA',
      });
    });

    test('pedir una solicitud y calcular pueden responder 409', () {
      final solicitudes = contrato['paths']['/estreno/solicitudes']['post'];
      final calculo =
          contrato['paths']['/estreno/cotizaciones/calculo']['post'];
      expect((solicitudes['responses'] as YamlMap).containsKey('409'), isTrue);
      expect((calculo['responses'] as YamlMap).containsKey('409'), isTrue);
    });

    test('Problema.codigo trae los codigos de estreno y la app los mapea', () {
      final enElContrato =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      final queLaAppMapea = CodigoProblema.values
          .where((c) => c != CodigoProblema.desconocido)
          .map((c) => c.enElContrato)
          .toSet();

      expect(
        enElContrato.containsAll({'ESTRENO_SIN_PRECIO', 'ESTRENO_DUPLICADA'}),
        isTrue,
      );
      expect(queLaAppMapea, enElContrato);
    });
  });
}
