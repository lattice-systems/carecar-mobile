import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_plan_mantenimiento.dart';
import 'pantalla_registrar_km.dart';
import 'pantalla_servicio_mantenimiento.dart';

/// Raíz de las rutas de mantenimiento.
const rutaMantenimiento = '/mantenimiento';

/// Plan de mantenimiento de un vehículo: `/mantenimiento/7`.
String rutaMantenimientoVehiculo(int vehiculoId) =>
    '$rutaMantenimiento/$vehiculoId';

/// Detalle de un servicio del plan: `/mantenimiento/7/servicio/3`.
String rutaServicioMantenimiento(int vehiculoId, int servicioId) =>
    '${rutaMantenimientoVehiculo(vehiculoId)}/servicio/$servicioId';

/// Registro del kilometraje: `/mantenimiento/7/kilometraje`.
String rutaKilometraje(int vehiculoId) =>
    '${rutaMantenimientoVehiculo(vehiculoId)}/kilometraje';

/// Un id que no es número cae en «no hay plan»: el backend da 404.
int _numero(GoRouterState state, String parametro) =>
    int.tryParse(state.pathParameters[parametro] ?? '') ?? -1;

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// módulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el módulo `mantenimiento` entrega al enrutador. No pasan por el
/// interruptor v1/v2: el mantenimiento no existe en la v1.
final rutasMantenimiento = <RouteBase>[
  GoRoute(
    path: '$rutaMantenimiento/:vehiculoId',
    name: 'mantenimiento-vehiculo',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaPlanMantenimiento(vehiculoId: _numero(state, 'vehiculoId')),
    ),
    routes: [
      GoRoute(
        path: 'servicio/:servicioId',
        name: 'mantenimiento-servicio',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaServicioMantenimiento(
            vehiculoId: _numero(state, 'vehiculoId'),
            servicioId: _numero(state, 'servicioId'),
          ),
        ),
      ),
      GoRoute(
        path: 'kilometraje',
        name: 'mantenimiento-kilometraje',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaRegistrarKm(vehiculoId: _numero(state, 'vehiculoId')),
        ),
      ),
    ],
  ),
];
