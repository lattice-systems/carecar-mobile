import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_carrito.dart';
import 'pantalla_mis_pedidos.dart';
import 'pantalla_pedido.dart';
import 'pantalla_producto.dart';
import 'pantalla_tienda.dart';

export '../../citas/citas.dart' show rutaAgendarCita;

/// La tienda: `/tienda`.
const rutaTienda = '/tienda';

/// La tienda filtrada por un vehículo: `/tienda?vehiculo=5`.
String rutaTiendaDe(int vehiculoId) => '$rutaTienda?vehiculo=$vehiculoId';

/// Un producto: `/tienda/productos/3`.
String rutaProducto(int productoId) => '$rutaTienda/productos/$productoId';

/// El carrito: `/tienda/carrito`.
const rutaCarrito = '$rutaTienda/carrito';

/// Mis pedidos: `/tienda/pedidos`.
const rutaMisPedidos = '$rutaTienda/pedidos';

/// Un pedido: `/tienda/pedidos/5`.
String rutaPedido(int pedidoId) => '$rutaMisPedidos/$pedidoId';

/// Un pedido que abre su pago al llegar: `/tienda/pedidos/5?pagar=1`
/// (V2-M14.04). Al volver del pago se queda en el pedido.
String rutaPedidoPagando(int pedidoId) => '${rutaPedido(pedidoId)}?pagar=1';

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

// Un id que no es número cae en «no encontrado».
int _id(GoRouterState state, String nombre) =>
    int.tryParse(state.pathParameters[nombre] ?? '') ?? -1;

/// Rutas que el módulo `tienda` entrega al enrutador.
final rutasTienda = <RouteBase>[
  GoRoute(
    path: rutaTienda,
    name: 'tienda',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaTienda(
        vehiculoId: int.tryParse(state.uri.queryParameters['vehiculo'] ?? ''),
      ),
    ),
    routes: [
      GoRoute(
        path: 'productos/:productoId',
        name: 'tienda-producto',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaProducto(productoId: _id(state, 'productoId')),
        ),
      ),
      GoRoute(
        path: 'carrito',
        name: 'tienda-carrito',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaCarrito()),
      ),
      GoRoute(
        path: 'pedidos',
        name: 'tienda-pedidos',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaMisPedidos()),
        routes: [
          GoRoute(
            path: ':pedidoId',
            name: 'tienda-pedido',
            builder: (context, state) => _conTemaPista(
              context,
              PantallaPedido(
                pedidoId: _id(state, 'pedidoId'),
                pagarAlAbrir: state.uri.queryParameters['pagar'] == '1',
              ),
            ),
          ),
        ],
      ),
    ],
  ),
];
