import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_canje.dart';
import 'pantalla_canjes.dart';
import 'pantalla_lealtad.dart';
import 'pantalla_movimientos.dart';
import 'pantalla_recompensas.dart';
import 'pantalla_referir.dart';

/// Mis puntos: `/lealtad`.
const rutaLealtad = '/lealtad';

/// Catalogo de recompensas: `/lealtad/recompensas`.
const rutaRecompensas = '$rutaLealtad/recompensas';

/// Mis canjes: `/lealtad/canjes`.
const rutaCanjes = '$rutaLealtad/canjes';

/// Un canje con su QR: `/lealtad/canjes/3`.
String rutaCanje(int canjeId) => '$rutaCanjes/$canjeId';

/// Movimientos de puntos: `/lealtad/movimientos`.
const rutaMovimientos = '$rutaLealtad/movimientos';

/// Referir a un amigo: `/lealtad/referir`.
const rutaReferir = '$rutaLealtad/referir';

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `lealtad` entrega al enrutador.
final rutasLealtad = <RouteBase>[
  GoRoute(
    path: rutaLealtad,
    name: 'lealtad',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaLealtad()),
    routes: [
      GoRoute(
        path: 'recompensas',
        name: 'lealtad-recompensas',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaRecompensas()),
      ),
      GoRoute(
        path: 'canjes',
        name: 'lealtad-canjes',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaCanjes()),
        routes: [
          GoRoute(
            path: ':canjeId',
            name: 'lealtad-canje',
            builder: (context, state) => _conTemaPista(
              context,
              PantallaCanje(
                canjeId:
                    int.tryParse(state.pathParameters['canjeId'] ?? '') ?? -1,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'movimientos',
        name: 'lealtad-movimientos',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaMovimientos()),
      ),
      GoRoute(
        path: 'referir',
        name: 'lealtad-referir',
        builder: (context, state) =>
            _conTemaPista(context, const PantallaReferir()),
      ),
    ],
  ),
];
