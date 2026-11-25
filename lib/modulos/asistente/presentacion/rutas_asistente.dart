import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_asistente.dart';

/// Camino del asistente de un vehiculo: `/asistente/7`; con [pregunta] la
/// envia al abrir (V2-M24.10): `/asistente/7?pregunta=...`.
String rutaAsistente(int vehiculoId, {String? pregunta}) => Uri(
  path: '/asistente/$vehiculoId',
  queryParameters: pregunta == null ? null : {'pregunta': pregunta},
).toString();

/// Rutas que el modulo `asistente` entrega al enrutador. No pasan por el
/// interruptor v1/v2: el asistente no existe en la v1.
final rutasAsistente = <RouteBase>[
  GoRoute(
    path: '/asistente/:id',
    name: 'asistente',
    builder: (context, state) => Theme(
      // Mientras la app no tenga el tema v2 global, se envuelve con Pista.
      data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      child: PantallaAsistente(
        // Un id que no es numero no encuentra vehiculo: el backend da 404.
        vehiculoId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        preguntaInicial: state.uri.queryParameters['pregunta'],
      ),
    ),
  ),
];
