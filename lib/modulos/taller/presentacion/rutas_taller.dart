import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_adicionales.dart';
import 'pantalla_inspeccion.dart';
import 'pantalla_orden.dart';

/// Raiz de las rutas del taller.
const rutaTaller = '/taller';

/// Orden en el taller: `/taller/41`.
String rutaOrdenTaller(int ordenId) => '$rutaTaller/$ordenId';

/// Inspeccion multipunto de la orden: `/taller/41/inspeccion`.
String rutaInspeccionTaller(int ordenId) =>
    '${rutaOrdenTaller(ordenId)}/inspeccion';

/// Trabajos adicionales de la orden: `/taller/41/adicionales`.
String rutaAdicionalesTaller(int ordenId) =>
    '${rutaOrdenTaller(ordenId)}/adicionales';

int _orden(GoRouterState state) =>
    int.tryParse(state.pathParameters['ordenId'] ?? '') ?? -1;

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `taller` entrega al enrutador.
final rutasTaller = <RouteBase>[
  GoRoute(
    path: '$rutaTaller/:ordenId',
    name: 'taller-orden',
    builder: (context, state) =>
        _conTemaPista(context, PantallaOrden(ordenId: _orden(state))),
    routes: [
      GoRoute(
        path: 'inspeccion',
        name: 'taller-inspeccion',
        builder: (context, state) =>
            _conTemaPista(context, PantallaInspeccion(ordenId: _orden(state))),
      ),
      GoRoute(
        path: 'adicionales',
        name: 'taller-adicionales',
        builder: (context, state) =>
            _conTemaPista(context, PantallaAdicionales(ordenId: _orden(state))),
      ),
    ],
  ),
];
