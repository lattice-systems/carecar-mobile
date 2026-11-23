import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'pantalla_guia.dart';
import 'pantalla_guias.dart';

/// Camino de la lista de guias de emergencia.
const rutaAsistenciaGuias = '/asistencia/guias';

/// Pantalla a la que lleva el acceso rapido SOS del icono (V2-M25.04).
///
/// Hasta que exista la pantalla SOS de V2-M11.01 apunta a las guias de
/// emergencia, que no necesitan red. Cuando M11.01 exista, solo cambia esta
/// constante.
const rutaSos = rutaAsistenciaGuias;

/// Camino de una guia: `/asistencia/guias/llanta`.
String rutaGuiaDeEmergencia(TipoGuia tipo) => '$rutaAsistenciaGuias/${tipo.id}';

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// modulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `asistencia` entrega al enrutador.
final rutasAsistencia = <RouteBase>[
  GoRoute(
    path: rutaAsistenciaGuias,
    name: 'asistencia-guias',
    builder: (context, state) => _conTemaPista(context, const PantallaGuias()),
    routes: [
      GoRoute(
        path: ':tipo',
        name: 'asistencia-guia',
        // Una guia que no existe vuelve a la lista en vez de quedar en blanco.
        redirect: (context, state) =>
            TipoGuia.desdeId(state.pathParameters['tipo']) == null
            ? rutaAsistenciaGuias
            : null,
        builder: (context, state) {
          final tipo = TipoGuia.desdeId(state.pathParameters['tipo'])!;
          final guia = guiasDeEmergencia.firstWhere((g) => g.tipo == tipo);
          return _conTemaPista(context, PantallaGuia(guia: guia));
        },
      ),
    ],
  ),
];
