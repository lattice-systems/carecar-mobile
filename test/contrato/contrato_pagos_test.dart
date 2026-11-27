import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
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

const _propiedadesPagos = <String, Set<String>>{
  'Pago': {
    'id',
    'ordenId',
    'vehiculoId',
    'monto',
    'moneda',
    'medio',
    'marca',
    'ultimos4',
    'tipoTarjeta',
    'estado',
    'motivoFallo',
    'requiereAutenticacion',
    'referencia',
    'simulado',
    'metodoPagoId',
    'perfilFiscalId',
    'pagadoEn',
    'creadoEn',
  },
  'PaginaPagos': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'NuevoPago': {'tarjeta', 'metodoPagoId', 'guardarTarjeta', 'perfilFiscalId'},
  'AutenticacionPago': {'confirmada'},
  'MetodoPago': {
    'id',
    'marca',
    'ultimos4',
    'tipo',
    'mesVence',
    'anioVence',
    'vencida',
    'predeterminado',
    'creadoEn',
  },
  'AvisoPagoConfirmado': {'pagoId', 'ordenId', 'estado'},
};

const _operacionesPagos = <String>{
  'POST /ordenes/{ordenId}/pagos',
  'POST /pagos/{pagoId}/autenticacion',
  'GET /pagos',
  'GET /pagos/{pagoId}',
  'GET /metodos-pago',
  'PUT /metodos-pago/{metodoPagoId}/predeterminado',
  'DELETE /metodos-pago/{metodoPagoId}',
};

Set<String> _operacionesDe(YamlMap contrato) {
  final enElContrato = <String>{};
  (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
    (operaciones as YamlMap).forEach((metodo, _) {
      if (metodo == 'parameters') return;
      enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
    });
  });
  return enElContrato;
}

List<String> _enum(YamlMap esquema, String propiedad) =>
    ((esquema['properties'] as YamlMap)[propiedad]['enum'] as YamlList)
        .cast<String>();

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
      expect(_operacionesDe(contrato).containsAll(_operaciones), isTrue);
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

  group('el contrato v2 trae pagos y tarjetas guardadas (V2-M08.02, '
      'V2-M08.04 y V2-M08.07)', () {
    test('la version es 2.24.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(24));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedadesPagos.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('ninguna respuesta lleva el numero de la tarjeta ni su token', () {
      for (final nombre in ['Pago', 'MetodoPago']) {
        final propiedades = (esquemas[nombre]['properties'] as YamlMap).keys;
        expect(propiedades, isNot(contains('numero')), reason: nombre);
        expect(propiedades, isNot(contains('token')), reason: nombre);
        expect(propiedades, isNot(contains('cvv')), reason: nombre);
      }
    });

    test('los estados, medios y motivos coinciden con la app', () {
      final pago = esquemas['Pago'] as YamlMap;
      expect(_enum(pago, 'estado'), EstadoPago.values.map((e) => e.enLaApi));
      expect(_enum(pago, 'medio'), MedioPago.values.map((m) => m.enLaApi));
      expect(
        _enum(pago, 'motivoFallo'),
        MotivoFalloPago.values
            .where((m) => m != MotivoFalloPago.otro)
            .map((m) => m.enLaApi),
      );
    });

    test('declara sus operaciones', () {
      expect(_operacionesDe(contrato).containsAll(_operacionesPagos), isTrue);
    });

    test('pagar pide la llave de idempotencia y responde 201 o 200', () {
      final pagar =
          (contrato['paths'] as YamlMap)['/ordenes/{ordenId}/pagos']['post']
              as YamlMap;
      final llave = (pagar['parameters'] as YamlList)
          .cast<YamlMap>()
          .firstWhere((p) => p['name'] == 'Idempotency-Key');
      expect(llave['in'], 'header');
      expect(llave['required'], isTrue);
      expect(
        (pagar['responses'] as YamlMap).keys,
        containsAll(['200', '201', '409']),
      );
    });

    test('el ticket dice si se pago y si se puede pagar', () {
      final ticket = esquemas['ServicioDetalle']['properties'] as YamlMap;
      expect(ticket.keys, containsAll(['pago', 'pagable']));
    });

    test('los codigos de pagos estan en el contrato y la app los mapea', () {
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>();
      for (final codigo in [
        'ORDEN_NO_PAGABLE',
        'PAGO_EN_CURSO',
        'PAGO_NO_PENDIENTE',
      ]) {
        expect(codigos, contains(codigo));
        expect(
          CodigoProblema.values.map((c) => c.enElContrato),
          contains(codigo),
        );
      }
    });
  });
}
