import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_detalle_vehiculo.dart';
import 'pantalla_ficha_tecnica.dart';
import 'pantalla_garaje.dart';
import 'pantalla_manual.dart';

/// Camino del garaje del cliente.
const rutaGaraje = '/garaje';

/// Camino del detalle de un vehiculo: `/garaje/7`.
String rutaDetalleVehiculo(int id) => '$rutaGaraje/$id';

/// Camino del manual de un vehiculo: `/garaje/7/manual`.
String rutaManualVehiculo(int id) => '${rutaDetalleVehiculo(id)}/manual';

/// Camino de la ficha tecnica de un vehiculo: `/garaje/7/ficha-tecnica`.
String rutaFichaTecnicaVehiculo(int id) =>
    '${rutaDetalleVehiculo(id)}/ficha-tecnica';

/// Un id que no es numero cae en "no encontramos el vehiculo".
int _idDe(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// modulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `vehiculos` entrega al enrutador.
final rutasVehiculos = <RouteBase>[
  GoRoute(
    path: rutaGaraje,
    name: 'garaje',
    builder: (context, state) => _conTemaPista(context, const PantallaGaraje()),
    routes: [
      GoRoute(
        path: ':id',
        name: 'detalle-vehiculo',
        // Un id que no es numero cae en "no encontramos el vehiculo".
        builder: (context, state) => _conTemaPista(
          context,
          PantallaDetalleVehiculo(vehiculoId: _idDe(state)),
        ),
        routes: [
          GoRoute(
            path: 'manual',
            name: 'manual-vehiculo',
            builder: (context, state) => _conTemaPista(
              context,
              PantallaManual(vehiculoId: _idDe(state)),
            ),
          ),
          GoRoute(
            path: 'ficha-tecnica',
            name: 'ficha-tecnica-vehiculo',
            builder: (context, state) => _conTemaPista(
              context,
              PantallaFichaTecnica(vehiculoId: _idDe(state)),
            ),
          ),
        ],
      ),
    ],
  ),
];
