import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_catalogo.dart';

/// Camino del catalogo de modelos.
const rutaCatalogo = '/catalogo';

/// Rutas que el modulo `catalogo` entrega al enrutador.
final rutasCatalogo = <RouteBase>[
  GoRoute(
    path: rutaCatalogo,
    name: 'catalogo',
    // Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
    // modulo v2 se envuelve con el tema Pista.
    builder: (context, state) => Theme(
      data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      child: const PantallaCatalogo(),
    ),
  ),
];
