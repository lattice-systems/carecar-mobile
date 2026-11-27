import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_bandeja.dart';
import 'pantalla_permiso_avisos.dart';

/// Pantalla previa que explica para que sirven los avisos (V2-M06.01).
///
/// Se abre desde Ajustes. No es una compuerta: la app nunca obliga a pasar por
/// aqui, porque negar los avisos no debe estorbar nada.
const rutaPermisoAvisos = Rutas.permisoAvisos;

/// La bandeja de avisos (V2-M06.04). Se abre desde el perfil.
const rutaBandeja = '/avisos';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas del módulo `notificaciones` (M06).
final rutasNotificaciones = <RouteBase>[
  GoRoute(
    path: rutaBandeja,
    name: 'bandejaAvisos',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaBandeja()),
  ),
  GoRoute(
    path: rutaPermisoAvisos,
    name: 'permisoAvisos',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaPermisoAvisos()),
  ),
];
