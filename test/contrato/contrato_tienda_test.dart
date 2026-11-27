import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/tienda/datos/lectura_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'AvisoPedido': {'pedidoId', 'estado'},
  'Producto': {
    'id',
    'codigo',
    'nombre',
    'descripcion',
    'categoria',
    'precio',
    'fotoUrl',
    'existencia',
    'universal',
    'compatibilidad',
    'compatible',
  },
  'CompatibilidadProducto': {'modelo', 'anioDesde', 'anioHasta'},
  'NuevoPedido': {'renglones', 'entrega', 'citaId'},
  'InstalacionPedido': {'citaId'},
  'Pedido': {
    'id',
    'estado',
    'entrega',
    'total',
    'creadoEn',
    'venceEn',
    'listoEn',
    'entregadoEn',
    'canceladoEn',
    'motivoCancelacion',
    'cita',
    'renglones',
    'pagable',
    'pago',
    'pagadoEn',
  },
  'CitaDePedido': {'id', 'fecha', 'hora', 'vehiculoId'},
  'RenglonPedido': {'productoId', 'nombre', 'cantidad', 'precio', 'importe'},
};

const _operaciones = <String>{
  'GET /tienda/productos',
  'GET /tienda/productos/{productoId}',
  'GET /tienda/pedidos',
  'POST /tienda/pedidos',
  'GET /tienda/pedidos/{pedidoId}',
  'POST /tienda/pedidos/{pedidoId}/cancelar',
  'PUT /tienda/pedidos/{pedidoId}/instalacion',
};

const _codigos = <String>{
  'SIN_EXISTENCIA',
  'CITA_NO_DISPONIBLE',
  'LIMITE_APARTADOS',
  'PEDIDO_NO_CANCELABLE',
  'PEDIDO_NO_MODIFICABLE',
  'PRODUCTO_INCOMPATIBLE',
  'PEDIDO_PAGADO',
};

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  List<String> enumeracion(String nombre) =>
      (esquemas[nombre]['enum'] as YamlList).cast<String>().toList();

  group('el contrato v2 trae la tienda (V2-M14)', () {
    test('la version es 2.21.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(21));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('categorias, entregas, estados y motivos son los que la app lee', () {
      expect(
        enumeracion('CategoriaProducto'),
        CategoriaProducto.values.map((v) => v.name),
      );
      expect(
        enumeracion('EntregaPedido'),
        EntregaPedido.values.map((v) => v.name),
      );
      expect(
        enumeracion('EstadoPedido'),
        EstadoPedido.values.map((v) => v.name),
      );
      final motivo = esquemas['Pedido']['properties']['motivoCancelacion'];
      expect(motivo['enum'], MotivoCancelacion.values.map((v) => v.name));
    });

    test('declara sus operaciones y la llave obligatoria al apartar', () {
      final paths = contrato['paths'] as YamlMap;
      final enElContrato = <String>{};
      paths.forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);

      final llave =
          (paths['/tienda/pedidos']['post']['parameters'] as YamlList).single;
      expect(llave['name'], 'Idempotency-Key');
      expect(llave['required'], isTrue);
    });

    test('los codigos de la tienda estan en Problema y la app los mapea', () {
      final declarados =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      expect(declarados.containsAll(_codigos), isTrue);
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        containsAll(_codigos),
      );
    });

    test('un pedido minimo del contrato se lee', () {
      final requeridos = (esquemas['Pedido']['required'] as YamlList).toSet();
      final minimo = <String, Object?>{
        'id': 1,
        'estado': 'apartado',
        'entrega': 'mostrador',
        'total': 10,
        'creadoEn': '2026-11-26T18:00:00Z',
        'renglones': <Object?>[],
      };
      expect(minimo.keys.toSet(), requeridos);
      expect(const LecturaTienda().pedido(minimo).abierto, isTrue);
    });

    test('el canal en vivo anuncia pedido.estado', () {
      final descripcion =
          contrato['paths']['/eventos']['get']['description'] as String;
      expect(descripcion, contains('pedido.estado'));
    });
  });
}
