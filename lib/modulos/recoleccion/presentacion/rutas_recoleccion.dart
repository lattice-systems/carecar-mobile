import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_mis_direcciones.dart';

/// Camino de la lista de direcciones guardadas (V2-M17.01).
const rutaMisDirecciones = '/recoleccion/direcciones';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas que el modulo `recoleccion` entrega al enrutador.
///
/// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
/// modulo v2 se envuelve con el tema Pista. El alta y la edicion no tienen
/// ruta propia: se abren encima de la lista.
final rutasRecoleccion = <RouteBase>[
  GoRoute(
    path: rutaMisDirecciones,
    name: 'recoleccion-direcciones',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisDirecciones()),
  ),
];
