import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_aceptar_aviso.dart';
import 'pantalla_aviso_privacidad.dart';
import 'pantalla_mis_datos.dart';
import 'pantalla_privacidad.dart';

/// Privacidad y mis datos: el aviso y los derechos sobre los datos (se abre
/// desde el perfil).
const rutaPrivacidad = '/privacidad';

/// Leer el aviso de privacidad vigente (se abre desde el perfil).
const rutaAvisoPrivacidad = '/privacidad/aviso';

/// Pedir y descargar la copia de mis datos (acceso ARCO, V2-M22.02).
const rutaMisDatos = '/privacidad/mis-datos';

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
    path: rutaPrivacidad,
    name: 'privacidad',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaPrivacidad()),
  ),
  GoRoute(
    path: rutaMisDatos,
    name: 'privacidad-mis-datos',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisDatos()),
  ),
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
