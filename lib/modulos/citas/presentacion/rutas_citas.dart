import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_disponibilidad.dart';

/// Camino del calendario de disponibilidad del taller.
const rutaDisponibilidad = '/citas/disponibilidad';

/// Rutas que el modulo `citas` entrega al enrutador.
final rutasCitas = <RouteBase>[
  GoRoute(
    path: rutaDisponibilidad,
    name: 'citas-disponibilidad',
    // Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
    // modulo v2 se envuelve con el tema Pista.
    builder: (context, state) => Theme(
      data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      child: const PantallaDisponibilidad(),
    ),
  ),
];
