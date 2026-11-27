import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/privacidad/pantalla_segura.dart';
import 'pantalla_datos_fiscales.dart';
import 'pantalla_metodos_pago.dart';
import 'pantalla_mis_pagos.dart';
import 'pantalla_pagar_orden.dart';
import 'pantalla_pago.dart';
import 'pantalla_perfil_fiscal.dart';

/// Mis datos fiscales: `/datos-fiscales`.
const rutaDatosFiscales = '/datos-fiscales';

/// Alta de datos fiscales: `/datos-fiscales/nuevo`.
const rutaPerfilFiscalNuevo = '$rutaDatosFiscales/nuevo';

/// Edicion de un perfil fiscal: `/datos-fiscales/3`.
String rutaPerfilFiscal(int perfilId) => '$rutaDatosFiscales/$perfilId';

/// Mis pagos: `/pagos`.
const rutaMisPagos = '/pagos';

/// Un pago: `/pagos/12`.
String rutaPago(int pagoId) => '$rutaMisPagos/$pagoId';

/// Mis tarjetas guardadas: `/metodos-pago`.
const rutaMetodosPago = '/metodos-pago';

/// Pagar una orden de servicio: `/pagar-orden/41`.
String rutaPagarOrden(int ordenId) => '/pagar-orden/$ordenId';

/// Pagar un pedido de la tienda: `/pagar-pedido/7` (V2-M14.04).
String rutaPagarPedido(int pedidoId) => '/pagar-pedido/$pedidoId';

int _numero(GoRouterState state, String parametro) =>
    int.tryParse(state.pathParameters[parametro] ?? '') ?? -1;

/// Las pantallas de pagos y facturas muestran datos fiscales y de pago del
/// cliente: van con tema Pista y sin capturas de pantalla (`PantallaSegura`,
/// V2-M22.06).
Widget _segura(BuildContext context, Widget hijo) => PantallaSegura(
  child: Theme(
    data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro(),
    child: hijo,
  ),
);

/// Rutas que el modulo `pagos` entrega al enrutador.
final rutasPagos = <RouteBase>[
  GoRoute(
    path: rutaDatosFiscales,
    name: 'datos-fiscales',
    builder: (context, state) =>
        _segura(context, const PantallaDatosFiscales()),
    routes: [
      GoRoute(
        path: 'nuevo',
        name: 'datos-fiscales-nuevo',
        builder: (context, state) =>
            _segura(context, const PantallaPerfilFiscal()),
      ),
      GoRoute(
        path: ':perfilId',
        name: 'datos-fiscales-editar',
        builder: (context, state) => _segura(
          context,
          PantallaPerfilFiscal(
            perfilId:
                int.tryParse(state.pathParameters['perfilId'] ?? '') ?? -1,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: rutaMisPagos,
    name: 'mis-pagos',
    builder: (context, state) => _segura(context, const PantallaMisPagos()),
    routes: [
      GoRoute(
        path: ':pagoId',
        name: 'pago',
        builder: (context, state) =>
            _segura(context, PantallaPago(pagoId: _numero(state, 'pagoId'))),
      ),
    ],
  ),
  GoRoute(
    path: rutaMetodosPago,
    name: 'metodos-pago',
    builder: (context, state) => _segura(context, const PantallaMetodosPago()),
  ),
  GoRoute(
    path: '/pagar-orden/:ordenId',
    name: 'pagar-orden',
    builder: (context, state) => _segura(
      context,
      PantallaPagarOrden(ordenId: _numero(state, 'ordenId')),
    ),
  ),
  GoRoute(
    path: '/pagar-pedido/:pedidoId',
    name: 'pagar-pedido',
    builder: (context, state) => _segura(
      context,
      PantallaPagarPedido(pedidoId: _numero(state, 'pedidoId')),
    ),
  ),
];
