import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_aceptar_aviso.dart';
import 'pantalla_aviso_privacidad.dart';

/// Leer el aviso de privacidad vigente (se abre desde el perfil).
const rutaAvisoPrivacidad = '/privacidad/aviso';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas del módulo `privacidad` (M22.01). La puerta usa la ruta del núcleo
/// ([Rutas.aceptarAviso]) porque a ella apunta la guardia de sesión.
final rutasPrivacidad = <RouteBase>[
  GoRoute(
    path: rutaAvisoPrivacidad,
    name: 'privacidad-aviso',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaAvisoPrivacidad()),
  ),
  GoRoute(
    path: Rutas.aceptarAviso,
    name: NombresRuta.aceptarAviso,
    builder: (context, state) =>
        _conTemaPista(context, const PantallaAceptarAviso()),
  ),
];
