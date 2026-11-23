import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_agendar_cita.dart';
import 'pantalla_disponibilidad.dart';
import 'pantalla_mis_citas.dart';
import 'pantalla_reprogramar_cita.dart';

/// Camino del calendario de disponibilidad del taller.
const rutaDisponibilidad = '/citas/disponibilidad';

/// Camino del flujo para agendar una cita.
const rutaAgendarCita = '/citas/agendar';

/// Camino de la lista de citas del cliente.
const rutaMisCitas = '/citas';

/// Camino para reprogramar una cita: `/citas/7/reprogramar`.
String rutaReprogramarCita(int id) => '$rutaMisCitas/$id/reprogramar';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas que el modulo `citas` entrega al enrutador.
///
/// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
/// modulo v2 se envuelve con el tema Pista.
final rutasCitas = <RouteBase>[
  GoRoute(
    path: rutaMisCitas,
    name: 'citas-mis-citas',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisCitas()),
  ),
  GoRoute(
    path: '$rutaMisCitas/:id/reprogramar',
    name: 'citas-reprogramar',
    // Un id que no es numero cae en "no encontramos esta cita".
    builder: (context, state) => _conTemaPista(
      context,
      PantallaReprogramarCita(
        citaId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
  ),
  GoRoute(
    path: rutaDisponibilidad,
    name: 'citas-disponibilidad',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaDisponibilidad()),
  ),
  GoRoute(
    path: rutaAgendarCita,
    name: 'citas-agendar',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaAgendarCita()),
  ),
];
