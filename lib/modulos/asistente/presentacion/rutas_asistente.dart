import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_asistente.dart';

/// Camino del asistente de un vehiculo: `/asistente/7`.
String rutaAsistente(int vehiculoId) => '/asistente/$vehiculoId';

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
      ),
    ),
  ),
];
