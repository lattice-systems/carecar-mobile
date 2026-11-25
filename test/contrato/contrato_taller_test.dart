import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'OrdenEnCurso': {
    'id',
    'vehiculoId',
    'vehiculo',
    'etapa',
    'estatus',
    'entregaEstimada',
    'asesor',
    'avance',
    'adicionalesPendientes',
    'totalEstimado',
    'horarioEntrega',
  },
  'OrdenEnVivo': {
    'id',
    'vehiculoId',
    'vehiculo',
    'estatus',
    'etapa',
    'entregaEstimada',
    'asesor',
    'avance',
    'etapas',
    'inspeccion',
    'evidencias',
    'adicionales',
    'totalOrden',
    'totalAdicionalesAprobados',
    'totalAdicionalesPendientes',
    'totalEstimado',
    'horarioEntrega',
  },
  'HorarioEntrega': {'fecha', 'desde', 'hasta'},
  'AvisoOrden': {'ordenId', 'vehiculoId', 'estatus', 'etapa', 'motivo'},
  'PasoEtapa': {'etapa', 'inicio', 'fin', 'nota'},
  'PuntoInspeccion': {'id', 'punto', 'resultado', 'comentario', 'evidencias'},
  'Evidencia': {'id', 'tipo', 'url'},
  'TrabajoAdicional': {
    'id',
    'concepto',
    'manoDeObra',
    'refacciones',
    'total',
    'estado',
    'respondidoEn',
  },
  'RespuestaAdicional': {'aprobado', 'firma'},
};

const _operaciones = <String>{
  'GET /ordenes/activas',
  'GET /ordenes/{ordenId}',
  'POST /ordenes/{ordenId}/adicionales/{adicionalId}/respuesta',
  'GET /eventos',
};

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae el taller en vivo (V2-M04)', () {
    test('la version es 2.11.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(11));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('las etapas van en el orden en que pasan', () {
      expect((esquemas['EtapaTaller']['enum'] as YamlList).toList(), [
        'RECIBIDO',
        'DIAGNOSTICO',
        'ESPERANDO_APROBACION',
        'EN_REPARACION',
        'CONTROL_DE_CALIDAD',
        'LAVADO',
        'LISTO_PARA_ENTREGA',
        'ENTREGADO',
      ]);
    });

    test('el aviso en vivo dice que cambio (V2-M04.03)', () {
      expect(
        (esquemas['AvisoOrden']['properties']['motivo']['enum'] as YamlList)
            .toList(),
        [
          'REGISTRO',
          'APERTURA',
          'ETAPA',
          'INSPECCION',
          'ADICIONAL',
          'RESPUESTA',
          'RENGLON',
        ],
      );
      expect((esquemas['HorarioEntrega']['required'] as YamlList).toList(), [
        'fecha',
        'desde',
        'hasta',
      ]);
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

    test('responder un adicional puede dar 409 y la app mapea sus codigos', () {
      final respuestas =
          contrato['paths']['/ordenes/{ordenId}/adicionales/{adicionalId}/respuesta']['post']['responses']
              as YamlMap;
      expect(respuestas.containsKey('409'), isTrue);
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      expect(
        codigos.containsAll({'ORDEN_CERRADA', 'ADICIONAL_YA_RESPONDIDO'}),
        isTrue,
      );
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        containsAll(['ORDEN_CERRADA', 'ADICIONAL_YA_RESPONDIDO']),
      );
    });
  });
}
