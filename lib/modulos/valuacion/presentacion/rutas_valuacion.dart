import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_mis_valuaciones.dart';
import 'pantalla_valuacion.dart';

/// Mis valuaciones: `/valuaciones`.
const rutaValuaciones = '/valuaciones';

/// Detalle de una valuacion: `/valuaciones/4`.
String rutaValuacion(int valuacionId) => '$rutaValuaciones/$valuacionId';

/// Fotos guiadas: `/valuaciones/4/fotos`.
String rutaFotosValuacion(int valuacionId) =>
    '${rutaValuacion(valuacionId)}/fotos';

/// Agendar la inspeccion: `/valuaciones/4/cita`.
String rutaCitaValuacion(int valuacionId) =>
    '${rutaValuacion(valuacionId)}/cita';

/// Valor de mi auto: `/valuaciones/valor/5`.
String rutaValorVehiculo(int vehiculoId) =>
    '$rutaValuaciones/valor/$vehiculoId';

// Los dos destinos de `catalogo` a los que llevan los estados vacios. Se
// escriben aqui porque `catalogo` importa `valuacion.dart` y al reves habria
// un ciclo. La prueba de rutas comprueba que coincidan con las de `catalogo`.

/// «Mis estimaciones», de `catalogo`.
const rutaDeMisEstimaciones = '/catalogo/estimaciones';

/// La calculadora de toma a cuenta, de `catalogo`.
const rutaDeLaCalculadora = '/catalogo/calculadora';

int _entero(GoRouterState state, String nombre) =>
    int.tryParse(state.pathParameters[nombre] ?? '') ?? -1;

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `valuacion` entrega al enrutador.
final rutasValuacion = <RouteBase>[
  GoRoute(
    path: rutaValuaciones,
    name: 'valuaciones',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisValuaciones()),
    routes: [
      GoRoute(
        path: ':valuacionId',
        name: 'valuacion',
        // Un id que no es numero cae en "no encontramos la valuacion".
        builder: (context, state) => _conTemaPista(
          context,
          PantallaValuacion(valuacionId: _entero(state, 'valuacionId')),
        ),
      ),
    ],
  ),
];
