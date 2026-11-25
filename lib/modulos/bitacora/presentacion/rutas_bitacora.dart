import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'caminos_bitacora.dart';
import 'pantalla_bitacora.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_exportar.dart';

/// Un id que no es número cae en el estado de error en vez de romper.
int _idDe(GoRouterState state) =>
    int.tryParse(state.pathParameters['vehiculoId'] ?? '') ?? -1;

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// módulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el módulo `bitacora` entrega al enrutador. El alta y la edición
/// de gastos no tienen ruta propia: se abren encima de la bitácora.
final rutasBitacora = <RouteBase>[
  GoRoute(
    path: '$rutaBitacora/:vehiculoId',
    name: 'bitacora-vehiculo',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaBitacora(
        vehiculoId: _idDe(state),
        nombre: state.uri.queryParameters['nombre'],
      ),
    ),
    routes: [
      GoRoute(
        path: 'estadisticas',
        name: 'bitacora-estadisticas',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaEstadisticas(vehiculoId: _idDe(state)),
        ),
      ),
      GoRoute(
        path: 'exportar',
        name: 'bitacora-exportar',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaExportar(
            vehiculoId: _idDe(state),
            nombre: state.uri.queryParameters['nombre'],
          ),
        ),
      ),
    ],
  ),
];
