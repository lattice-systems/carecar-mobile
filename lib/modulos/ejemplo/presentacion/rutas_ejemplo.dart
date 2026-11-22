import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_avisos.dart';

/// Camino de la pantalla de avisos del modulo de ejemplo.
const rutaAvisosEjemplo = '/ejemplo/avisos';

/// Rutas que el modulo `ejemplo` entrega al enrutador. Modelo para copiar:
/// el nucleo solo junta esta lista (`registro_de_rutas.dart`).
final rutasEjemplo = <RouteBase>[
  GoRoute(
    path: rutaAvisosEjemplo,
    name: 'ejemplo-avisos',
    // Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
    // modulo v2 se envuelve con el tema Pista para que sus componentes lo
    // encuentren.
    builder: (context, state) => Theme(
      data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      child: const PantallaAvisos(),
    ),
  ),
];
