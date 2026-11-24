import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../dominio/motivo_cita.dart';
import 'pantalla_agendar_cita.dart';
import 'pantalla_comprobante_cita.dart';
import 'pantalla_disponibilidad.dart';
import 'pantalla_mis_citas.dart';
import 'pantalla_reprogramar_cita.dart';

/// Camino del calendario de disponibilidad del taller.
const rutaDisponibilidad = '/citas/disponibilidad';

/// Camino del flujo para agendar una cita.
const rutaAgendarCita = '/citas/agendar';

/// Agendar con el vehiculo y el motivo ya elegidos (V2-M24.06):
/// `/citas/agendar?vehiculo=2&motivo=revision`.
String rutaAgendarCitaCon({int? vehiculoId, MotivoCita? motivo}) => Uri(
  path: rutaAgendarCita,
  queryParameters: {
    'vehiculo': ?vehiculoId?.toString(),
    'motivo': ?motivo?.codigo,
  },
).toString();

/// Camino de la lista de citas del cliente.
const rutaMisCitas = '/citas';

/// Camino para reprogramar una cita: `/citas/7/reprogramar`.
String rutaReprogramarCita(int id) => '$rutaMisCitas/$id/reprogramar';

/// Camino del comprobante con QR de la cita `citaId` (V2-M02.11).
String rutaComprobanteCita(int citaId) => '/citas/$citaId/comprobante';

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas que el modulo `citas` entrega al enrutador.
///
/// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
/// modulo v2 se envuelve con el tema Pista.
final rutasCitas = <RouteBase>[
  GoRoute(
    path: rutaMisCitas,
    name: 'citas-mis-citas',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisCitas()),
  ),
  GoRoute(
    path: '$rutaMisCitas/:id/reprogramar',
    name: 'citas-reprogramar',
    // Un id que no es numero cae en "no encontramos esta cita".
    builder: (context, state) => _conTemaPista(
      context,
      PantallaReprogramarCita(
        citaId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
  ),
  GoRoute(
    path: rutaDisponibilidad,
    name: 'citas-disponibilidad',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaDisponibilidad()),
  ),
  GoRoute(
    path: rutaAgendarCita,
    name: 'citas-agendar',
    // Datos raros en la consulta se ignoran y el formulario abre vacio.
    builder: (context, state) => _conTemaPista(
      context,
      PantallaAgendarCita(
        vehiculoInicial: int.tryParse(
          state.uri.queryParameters['vehiculo'] ?? '',
        ),
        motivoInicial: MotivoCita.desdeCodigo(
          state.uri.queryParameters['motivo'],
        ),
      ),
    ),
  ),
  GoRoute(
    path: '/citas/:citaId/comprobante',
    name: 'citas-comprobante',
    redirect: (context, state) =>
        int.tryParse(state.pathParameters['citaId'] ?? '') == null
        ? rutaDisponibilidad
        : null,
    builder: (context, state) => _conTemaPista(
      context,
      PantallaComprobanteCita(
        citaId: int.parse(state.pathParameters['citaId']!),
      ),
    ),
  ),
];
