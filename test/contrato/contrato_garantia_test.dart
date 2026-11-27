import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'GarantiaVehiculo': {'vehiculoId', 'kmActual', 'coberturas'},
  'CoberturaGarantia': {
    'id',
    'componente',
    'descripcion',
    'iniciaEn',
    'venceEn',
    'kmLimite',
    'diasRestantes',
    'kmRestantes',
    'consumo',
    'estado',
    'limite',
  },
  'CampanaSeguridad': {
    'id',
    'codigo',
    'titulo',
    'descripcion',
    'queHacer',
    'gravedad',
    'estado',
    'citaId',
    'publicadaEn',
  },
  'AgendarCampana': {'franjaId', 'fecha'},
  'AvisoCampanaNueva': {
    'vehiculoId',
    'campanaId',
    'codigo',
    'titulo',
    'gravedad',
    'critica',
  },
  'AvisoGarantiaPorVencer': {
    'vehiculoId',
    'garantiaId',
    'componente',
    'venceEn',
    'diasRestantes',
    'kmRestantes',
    'motivo',
  },
};

const _operaciones = <String>{
  'GET /vehiculos/{vehiculoId}/garantia',
  'GET /vehiculos/{vehiculoId}/campanas',
  'POST /vehiculos/{vehiculoId}/campanas/{campanaId}/cita',
};

List<String> _enumeracion(YamlMap esquema) =>
    (esquema['enum'] as YamlList).cast<String>().toList();

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae la garantia y las campanas (V2-M10)', () {
    test('la version es 2.18.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(18));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('estados, limites y gravedades son los que la app lee', () {
      final cobertura = esquemas['CoberturaGarantia']['properties'] as YamlMap;
      expect(_enumeracion(cobertura['estado'] as YamlMap), [
        'VIGENTE',
        'POR_VENCER',
        'VENCIDA',
      ]);
      expect(_enumeracion(cobertura['limite'] as YamlMap), ['fecha', 'km']);
      final campana = esquemas['CampanaSeguridad']['properties'] as YamlMap;
      expect(_enumeracion(campana['gravedad'] as YamlMap), [
        'BAJA',
        'MEDIA',
        'ALTA',
        'CRITICA',
      ]);
      expect(_enumeracion(campana['estado'] as YamlMap), [
        'ABIERTA',
        'AGENDADA',
        'ATENDIDA',
      ]);
    });

    test('la cita de una campana lleva su motivo (V2-M10.03)', () {
      expect(
        _enumeracion(esquemas['MotivoCita'] as YamlMap),
        contains('campana'),
      );
    });

    test('el aviso de garantia dice que umbral se cruzo (V2-M10.05)', () {
      final motivo =
          esquemas['AvisoGarantiaPorVencer']['properties']['motivo'] as YamlMap;
      expect(_enumeracion(motivo), ['dias_60', 'dias_15', 'km_1000']);
    });

    test('declara sus operaciones', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('agendar puede dar 409 y la app mapea sus codigos', () {
      final respuestas =
          contrato['paths']['/vehiculos/{vehiculoId}/campanas/{campanaId}/cita']['post']['responses']
              as YamlMap;
      expect(respuestas.containsKey('201'), isTrue);
      expect(respuestas.containsKey('409'), isTrue);
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      const esperados = {
        'CAMPANA_NO_AGENDABLE',
        'FRANJA_SIN_CUPO',
        'CITA_DUPLICADA',
      };
      expect(codigos.containsAll(esperados), isTrue);
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        containsAll(esperados),
      );
    });

    test('el canal en vivo anuncia los dos avisos nuevos', () {
      final descripcion =
          contrato['paths']['/eventos']['get']['description'] as String;
      expect(descripcion, contains('campana.nueva'));
      expect(descripcion, contains('garantia.por_vencer'));
    });
  });
}
