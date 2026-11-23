import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_catalogo.dart';
import 'pantalla_detalle_modelo.dart';

/// Camino del catalogo de modelos.
const rutaCatalogo = '/catalogo';

/// Camino del detalle de un modelo: `/catalogo/7`.
String rutaDetalleModelo(int id) => '$rutaCatalogo/$id';

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// modulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `catalogo` entrega al enrutador.
final rutasCatalogo = <RouteBase>[
  GoRoute(
    path: rutaCatalogo,
    name: 'catalogo',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaCatalogo()),
    routes: [
      GoRoute(
        path: ':id',
        name: 'detalle-modelo',
        // Un id que no es numero cae en "no encontramos el modelo".
        builder: (context, state) => _conTemaPista(
          context,
          PantallaDetalleModelo(
            modeloId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          ),
        ),
      ),
    ],
  ),
];
