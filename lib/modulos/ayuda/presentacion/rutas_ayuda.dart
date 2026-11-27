import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_contacto.dart';
import 'pantalla_sucursales.dart';

/// Camino de las sucursales con mapa y horarios.
const rutaSucursales = '/sucursales';

/// Camino de la pantalla para contactar a la agencia (V2-M27.03).
const rutaContacto = '/contacto';

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// modulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `ayuda` entrega al enrutador.
final rutasAyuda = <RouteBase>[
  GoRoute(
    path: rutaContacto,
    name: 'contacto',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaContacto()),
  ),
  GoRoute(
    path: rutaSucursales,
    name: 'sucursales',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaSucursales()),
  ),
];
