import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_historial.dart';
import 'pantalla_ticket.dart';

/// Raiz de las rutas del historial.
const rutaHistorial = '/historial';

/// Historial de un vehiculo: `/historial/7`.
String rutaHistorialVehiculo(int vehiculoId) => '$rutaHistorial/$vehiculoId';

/// Ticket de una orden: `/historial/7/ticket/21`.
String rutaTicketServicio(int vehiculoId, int servicioId) =>
    '${rutaHistorialVehiculo(vehiculoId)}/ticket/$servicioId';

int _numero(GoRouterState state, String parametro) =>
    int.tryParse(state.pathParameters[parametro] ?? '') ?? -1;

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `historial` entrega al enrutador.
final rutasHistorial = <RouteBase>[
  GoRoute(
    path: '$rutaHistorial/:vehiculoId',
    name: 'historial-vehiculo',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaHistorial(vehiculoId: _numero(state, 'vehiculoId')),
    ),
    routes: [
      GoRoute(
        path: 'ticket/:servicioId',
        name: 'ticket-servicio',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaTicket(servicioId: _numero(state, 'servicioId')),
        ),
      ),
    ],
  ),
];
