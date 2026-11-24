import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'pantalla_guia.dart';
import 'pantalla_guias.dart';
import 'pantalla_pedir_ayuda.dart';

/// Camino de la lista de guias de emergencia.
const rutaAsistenciaGuias = '/asistencia/guias';

/// Camino de «Pedir ayuda» (V2-M11.01). Cuelga de las guias: regresar lleva a
/// la lista de emergencias.
const rutaPedirAyuda = '$rutaAsistenciaGuias/pedir';

/// Pantalla a la que lleva el acceso rapido SOS del icono (V2-M25.04): pedir
/// ayuda. Las guias de emergencia quedan a un toque desde ahi.
const rutaSos = rutaPedirAyuda;

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
      // Va antes de ':tipo' para que 'pedir' no se lea como una guia.
      GoRoute(
        path: 'pedir',
        name: 'asistencia-pedir',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaPedirAyuda()),
      ),
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
