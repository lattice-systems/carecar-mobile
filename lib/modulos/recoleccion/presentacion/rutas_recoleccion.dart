import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../dominio/recoleccion_agendada.dart' show TipoTraslado;
import 'pantalla_checklist_traslado.dart';
import 'pantalla_mis_direcciones.dart';
import 'pantalla_seguimiento_traslado.dart';

/// Camino de la lista de direcciones guardadas (V2-M17.01).
const rutaMisDirecciones = '/recoleccion/direcciones';

/// Camino del seguimiento del traslado `id` (V2-M17.03).
String rutaSeguimientoTraslado(int id) => '/recoleccion/traslados/$id';

/// Camino del checklist del traslado `id` (V2-M17.04). Cuelga del seguimiento:
/// regresar lleva a él.
///
/// Con [contrario] (el otro traslado de la cita) el checklist muestra las
/// pestañas para alternar y comparar; [tipo] dice si `id` recoge o entrega, y
/// [comparar] abre directo en la comparación.
String rutaChecklistTraslado(
  int id, {
  int? contrario,
  TipoTraslado tipo = TipoTraslado.recoger,
  bool comparar = false,
}) {
  final base = '${rutaSeguimientoTraslado(id)}/checklist';
  if (contrario == null) return base;
  return '$base?contrario=$contrario'
      '${tipo == TipoTraslado.entregar ? '&tipo=entregar' : ''}'
      '${comparar ? '&ver=comparar' : ''}';
}

Widget _conTemaPista(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

/// Rutas que el modulo `recoleccion` entrega al enrutador.
///
/// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
/// modulo v2 se envuelve con el tema Pista. El alta y la edicion de
/// direcciones no tienen ruta propia: se abren encima de la lista. Un id de
/// traslado que no es un numero vuelve al inicio en vez de quedar en blanco.
final rutasRecoleccion = <RouteBase>[
  GoRoute(
    path: rutaMisDirecciones,
    name: 'recoleccion-direcciones',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMisDirecciones()),
  ),
  GoRoute(
    path: '/recoleccion/traslados/:id',
    name: 'recoleccion-traslado',
    redirect: (context, state) =>
        int.tryParse(state.pathParameters['id'] ?? '') == null
        ? Rutas.inicio
        : null,
    builder: (context, state) => _conTemaPista(
      context,
      PantallaSeguimientoTraslado(
        trasladoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    routes: [
      GoRoute(
        path: 'checklist',
        name: 'recoleccion-checklist',
        builder: (context, state) => _conTemaPista(
          context,
          PantallaChecklistTraslado(
            trasladoId: int.parse(state.pathParameters['id']!),
            trasladoContrarioId: int.tryParse(
              state.uri.queryParameters['contrario'] ?? '',
            ),
            tipo: state.uri.queryParameters['tipo'] == 'entregar'
                ? TipoTraslado.entregar
                : TipoTraslado.recoger,
            verComparacion: state.uri.queryParameters['ver'] == 'comparar',
          ),
        ),
      ),
    ],
  ),
];
