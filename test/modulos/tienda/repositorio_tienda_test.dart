import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_api.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_tienda.dart';

const _producto = {
  'id': 1,
  'codigo': 'ACC-TAP-01',
  'nombre': 'Tapetes de uso rudo',
  'categoria': 'accesorio',
  'precio': 850,
  'existencia': 3,
  'universal': false,
  'compatibilidad': [
    {'modelo': 'March', 'anioDesde': 2017, 'anioHasta': 2022},
  ],
  'compatible': true,
};

const _pedido = {
  'id': 7,
  'estado': 'apartado',
  'entrega': 'cita',
  'total': 1700,
  'creadoEn': '2026-11-26T18:00:00Z',
  'venceEn': '2026-11-29T23:59:59',
  'cita': {'id': 31, 'fecha': '2026-11-28', 'hora': '09:00', 'vehiculoId': 5},
  'renglones': [
    {
      'productoId': 1,
      'nombre': 'Tapetes de uso rudo',
      'cantidad': 2,
      'precio': 850,
      'importe': 1700,
    },
  ],
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, Object> _pagina(Object contenido) => {
  'contenido': [contenido],
  'pagina': 0,
  'tamano': 20,
  'totalElementos': 1,
  'totalPaginas': 1,
};

final _pedidas = <http.Request>[];

RepositorioTiendaApi _repo(http.Response Function(http.Request) responder) {
  _pedidas.clear();
  return RepositorioTiendaApi(
    ClienteApi(
      config: ApiConfig.para('http://local/api/v1/app'),
      obtenerToken: () async => 'token',
      http: MockClient((peticion) async {
        _pedidas.add(peticion);
        return responder(peticion);
      }),
    ),
  );
}

Carrito _carrito() => const Carrito().agregar(tapetes, 2);

void main() {
  group('RepositorioTiendaApi', () {
    test('manda vehiculo, categoria, busqueda y pagina', () async {
      final repo = _repo((_) => _json(200, _pagina(_producto)));

      final pagina = await repo.productos(
        vehiculoId: 5,
        categoria: CategoriaProducto.accesorio,
        texto: ' tapetes ',
      );

      expect(_pedidas.single.url.path, '/api/v1/app/tienda/productos');
      expect(_pedidas.single.url.queryParameters, {
        'vehiculoId': '5',
        'categoria': 'accesorio',
        'q': 'tapetes',
        'pagina': '0',
        'tamano': '20',
      });
      final p = pagina.productos.single;
      expect(p.existencia, 3);
      expect(p.compatible, isTrue);
      expect(p.compatibilidad.single.modelo, 'March');
      expect(pagina.hayMas, isFalse);
    });

    test('sin filtros no manda parametros vacios', () async {
      final repo = _repo((_) => _json(200, _pagina(_producto)));

      await repo.productos(texto: '  ');

      expect(_pedidas.single.url.queryParameters.keys, ['pagina', 'tamano']);
    });

    test('apartar manda la llave de idempotencia y el carrito', () async {
      final repo = _repo((_) => _json(201, _pedido));

      final creado = await repo.apartar(
        _carrito().paraCita(31),
        llave: 'llave-123456',
      );

      final peticion = _pedidas.single;
      expect(peticion.method, 'POST');
      expect(peticion.url.path, '/api/v1/app/tienda/pedidos');
      expect(peticion.headers['Idempotency-Key'], 'llave-123456');
      expect(peticion.headers['authorization'], 'Bearer token');
      expect(jsonDecode(peticion.body), {
        'renglones': [
          {'productoId': 1, 'cantidad': 2},
        ],
        'entrega': 'cita',
        'citaId': 31,
      });
      expect(creado.cita?.id, 31);
      // Sin zona se toma como UTC, como dice el contrato.
      expect(creado.venceEn, DateTime.utc(2026, 11, 29, 23, 59, 59));
    });

    test('recoger en mostrador no manda cita', () async {
      final repo = _repo((_) => _json(200, _pedido));

      await repo.apartar(_carrito(), llave: 'llave-123456');

      expect(jsonDecode(_pedidas.single.body), isNot(contains('citaId')));
    });

    test('mis pedidos y un pedido', () async {
      final repo = _repo(
        (p) => _json(
          200,
          p.url.path.endsWith('/pedidos') ? _pagina(_pedido) : _pedido,
        ),
      );

      expect((await repo.pedidos()).pedidos.single.id, 7);
      expect((await repo.pedido(7)).piezas, 2);
      expect(_pedidas.last.url.path, '/api/v1/app/tienda/pedidos/7');
    });

    test('cancelar y cambiar la instalacion', () async {
      final repo = _repo((_) => _json(200, _pedido));

      await repo.cancelar(7);
      await repo.cambiarInstalacion(7, null);

      expect(_pedidas.first.method, 'POST');
      expect(_pedidas.first.url.path, '/api/v1/app/tienda/pedidos/7/cancelar');
      expect(_pedidas.last.method, 'PUT');
      expect(
        _pedidas.last.url.path,
        '/api/v1/app/tienda/pedidos/7/instalacion',
      );
      expect(jsonDecode(_pedidas.last.body), {'citaId': null});
    });

    const rechazos = {
      'SIN_EXISTENCIA': (409, MotivoRechazoPedido.sinExistencia),
      'CITA_NO_DISPONIBLE': (409, MotivoRechazoPedido.citaNoDisponible),
      'LIMITE_APARTADOS': (409, MotivoRechazoPedido.limiteApartados),
      'PEDIDO_NO_CANCELABLE': (409, MotivoRechazoPedido.noCancelable),
      'PEDIDO_NO_MODIFICABLE': (409, MotivoRechazoPedido.noModificable),
      'PRODUCTO_INCOMPATIBLE': (422, MotivoRechazoPedido.productoIncompatible),
    };
    for (final MapEntry(key: codigo, value: (status, motivo))
        in rechazos.entries) {
      test('$codigo llega como rechazo propio', () async {
        final repo = _repo(
          (_) => _json(status, {
            'timestamp': 't',
            'status': status,
            'error': 'x',
            'message': 'x',
            'codigo': codigo,
            'path': '/tienda/pedidos',
          }),
        );

        await expectLater(
          repo.apartar(_carrito(), llave: 'llave-123456'),
          throwsA(
            isA<PedidoRechazado>().having((r) => r.motivo, 'motivo', motivo),
          ),
        );
      });
    }

    test('un 404 pasa tal cual', () async {
      final repo = _repo(
        (_) => _json(404, {'status': 404, 'message': 'No existe'}),
      );

      await expectLater(repo.pedido(9), throwsA(isA<NoEncontrado>()));
    });

    test('un estado que no existe no se adivina', () async {
      final repo = _repo((_) => _json(200, {..._pedido, 'estado': 'raro'}));

      await expectLater(repo.pedido(7), throwsA(isA<RespuestaInvalida>()));
    });
  });

  group('Carrito', () {
    test('no pasa de la existencia ni agrega agotados', () {
      final carrito = const Carrito()
          .agregar(tapetes, 2)
          .agregar(tapetes, 5)
          .agregar(filtro, 1);

      expect(carrito.renglones.single.cantidad, 3);
      expect(carrito.total, 2550);
    });

    test('admite 10 renglones y 10 piezas por renglon', () {
      var carrito = const Carrito().agregar(shampoo, 15);
      expect(carrito.piezas, 10);

      for (var id = 100; id < 120; id++) {
        carrito = carrito.agregar(
          Producto(
            id: id,
            codigo: 'C$id',
            nombre: 'P$id',
            categoria: CategoriaProducto.cuidado,
            precio: 1,
            existencia: 5,
            universal: true,
          ),
          1,
        );
      }
      expect(carrito.renglones, hasLength(10));
    });

    test('la huella cambia con las piezas y con la entrega', () {
      final base = _carrito();
      expect(base.huella, _carrito().huella);
      expect(base.conCantidad(1, 1).huella, isNot(base.huella));
      expect(base.paraCita(31).huella, isNot(base.huella));
    });
  });
}
