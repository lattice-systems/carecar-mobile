import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import 'pantalla_agendar_campana.dart';
import 'pantalla_campana.dart';
import 'pantalla_campanas.dart';
import 'pantalla_garantia.dart';

/// Raiz de las rutas de garantia y campanas.
const rutaGarantia = '/garantia';

/// Garantia del vehiculo: `/garantia/5`.
String rutaGarantiaVehiculo(int vehiculoId) => '$rutaGarantia/$vehiculoId';

/// Campanas de seguridad del vehiculo: `/garantia/5/campanas`.
String rutaCampanasVehiculo(int vehiculoId) =>
    '${rutaGarantiaVehiculo(vehiculoId)}/campanas';

/// Detalle de una campana: `/garantia/5/campanas/7`.
String rutaCampanaVehiculo(int vehiculoId, int campanaId) =>
    '${rutaCampanasVehiculo(vehiculoId)}/$campanaId';

/// Agendar una campana: `/garantia/5/campanas/7/agendar`.
String rutaAgendarCampana(int vehiculoId, int campanaId) =>
    '${rutaCampanaVehiculo(vehiculoId, campanaId)}/agendar';

int _entero(GoRouterState state, String nombre) =>
    int.tryParse(state.pathParameters[nombre] ?? '') ?? -1;

Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Rutas que el modulo `garantia` entrega al enrutador.
final rutasGarantia = <RouteBase>[
  GoRoute(
    path: '$rutaGarantia/:vehiculoId',
    name: 'garantia-vehiculo',
    builder: (context, state) => _conTemaPista(
      context,
      PantallaGarantia(vehiculoId: _entero(state, 'vehiculoId')),
    ),
    routes: [
      GoRoute(
        path: 'campanas',
        name: 'garantia-campanas',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaCampanas(vehiculoId: _entero(state, 'vehiculoId')),
        ),
        routes: [
          GoRoute(
            path: ':campanaId',
            name: 'garantia-campana',
            builder: (context, state) => _conTemaPista(
              context,
              PantallaCampana(
                vehiculoId: _entero(state, 'vehiculoId'),
                campanaId: _entero(state, 'campanaId'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'agendar',
                name: 'garantia-agendar-campana',
                builder: (context, state) => _conTemaPista(
                  context,
                  PantallaAgendarCampana(
                    vehiculoId: _entero(state, 'vehiculoId'),
                    campanaId: _entero(state, 'campanaId'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
