import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_cotizacion_estreno.dart';
import 'pantalla_mis_solicitudes.dart';
import 'pantalla_prueba_manejo.dart';

/// Lista de solicitudes de estreno.
const rutaMisSolicitudesEstreno = '/estreno/solicitudes';

/// Pedir prueba de manejo de un modelo del catalogo: `/estreno/7/prueba`.
String rutaPruebaManejo(int modeloId) => '/estreno/$modeloId/prueba';

/// Cotizar un modelo del catalogo: `/estreno/7/cotizar`.
String rutaCotizarEstreno(int modeloId) => '/estreno/$modeloId/cotizar';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

int _modelo(GoRouterState state) =>
    int.tryParse(state.pathParameters['modeloId'] ?? '') ?? -1;

/// Rutas del modulo `estreno` (M16).
final rutasEstreno = <RouteBase>[
  GoRoute(
    path: rutaMisSolicitudesEstreno,
    name: 'estreno-solicitudes',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisSolicitudes()),
  ),
  GoRoute(
    path: '/estreno/:modeloId/prueba',
    name: 'estreno-prueba',
    builder: (context, state) =>
        _conTemaPista(context, PantallaPruebaManejo(modeloId: _modelo(state))),
  ),
  GoRoute(
    path: '/estreno/:modeloId/cotizar',
    name: 'estreno-cotizar',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaCotizacionEstreno(modeloId: _modelo(state)),
    ),
  ),
];
