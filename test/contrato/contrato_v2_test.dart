// Contrato v2 · asistencia en camino (V2-M11.01) y recoleccion a domicilio
// (V2-M17.01 y V2-M17.02).
//
// Lee api/agencia360-api-app-v2.yaml, que crece de forma aditiva sobre el v1
// congelado en 1.4.0, y comprueba que lo de estas historias sigue como la app
// lo espera: esquemas, propiedades, operaciones y codigos de error.

import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _esquemasNuevos = <String>{
  'TipoAsistencia',
  'EstadoAsistencia',
  'NuevaSolicitudAsistencia',
  'SolicitudAsistencia',
  'NuevaDireccion',
  'Direccion',
  'FranjaRecoleccion',
  'CotizacionRecoleccion',
  'EstadoTraslado',
  'Traslado',
  'RecoleccionCita',
  'NuevaRecoleccion',
};

const _propiedades = <String, Set<String>>{
  'NuevaSolicitudAsistencia': {
    'vehiculoId',
    'tipo',
    'lat',
    'lng',
    'comentario',
  },
  'SolicitudAsistencia': {
    'id',
    'vehiculoId',
    'tipo',
    'lat',
    'lng',
    'comentario',
    'estado',
    'creadaEn',
  },
  'NuevaDireccion': {'alias', 'calle', 'colonia', 'cp', 'ciudad', 'lat', 'lng'},
  'FranjaRecoleccion': {'inicio', 'fin'},
  'CotizacionRecoleccion': {
    'direccionId',
    'fecha',
    'costoPorTraslado',
    'costoTotal',
    'recoleccion',
    'entrega',
  },
  'Traslado': {
    'id',
    'tipo',
    'estado',
    'costo',
    'fecha',
    'ventanaInicio',
    'ventanaFin',
  },
  'RecoleccionCita': {'direccionId', 'costoTotal', 'traslados'},
  'NuevaRecoleccion': {'direccionId'},
};

const _obligatorios = <String, Set<String>>{
  'NuevaDireccion': {'alias', 'calle', 'colonia', 'cp', 'ciudad', 'lat', 'lng'},
  'FranjaRecoleccion': {'inicio', 'fin'},
  'CotizacionRecoleccion': {
    'direccionId',
    'fecha',
    'costoPorTraslado',
    'costoTotal',
    'recoleccion',
    'entrega',
  },
  'Traslado': {
    'id',
    'tipo',
    'estado',
    'costo',
    'fecha',
    'ventanaInicio',
    'ventanaFin',
  },
  'RecoleccionCita': {'direccionId', 'costoTotal', 'traslados'},
  'NuevaRecoleccion': {'direccionId'},
};

const _operaciones = <String>{
  'POST /asistencia',
  'GET /asistencia',
  'GET /direcciones',
  'POST /direcciones',
  'PUT /direcciones/{direccionId}',
  'DELETE /direcciones/{direccionId}',
  'GET /recoleccion/cotizacion',
};

const _codigosNuevos = <String>{
  'SOLICITUD_ABIERTA',
  'FUERA_DE_COBERTURA',
  'DIRECCION_EN_USO',
};

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae asistencia y recoleccion', () {
    test('la version es 2.6.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(6));
    });

    test('declara los esquemas nuevos', () {
      expect(esquemas.keys.toSet().containsAll(_esquemasNuevos), isTrue);
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

    test('NuevaCita y Cita llevan la recoleccion opcional', () {
      for (final nombre in ['NuevaCita', 'Cita']) {
        expect(
          (esquemas[nombre]['properties'] as YamlMap).containsKey(
            'recoleccion',
          ),
          isTrue,
          reason: nombre,
        );
        final obligatorios =
            (esquemas[nombre]['required'] as YamlList?)?.cast<String>() ??
            const <String>[];
        expect(obligatorios, isNot(contains('recoleccion')), reason: nombre);
      }
    });

    test('declara las siete operaciones nuevas', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('POST /citas puede responder 422 por cobertura', () {
      final respuestas =
          contrato['paths']['/citas']['post']['responses'] as YamlMap;
      expect(respuestas.containsKey('422'), isTrue);
    });

    test('Problema.codigo incluye los codigos nuevos y la app los mapea', () {
      final enElContrato =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      final queLaAppMapea = CodigoProblema.values
          .where((c) => c != CodigoProblema.desconocido)
          .map((c) => c.enElContrato)
          .toSet();

      expect(enElContrato.containsAll(_codigosNuevos), isTrue);
      expect(queLaAppMapea, enElContrato);
    });
  });
}
