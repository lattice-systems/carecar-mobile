import 'package:go_router/go_router.dart';

import 'pantalla_galeria.dart';

/// Camino de la galeria del sistema de diseno. Solo existe en desarrollo
/// (`registro_de_rutas.dart`).
const rutaGaleria = '/galeria';

/// Rutas que el modulo `galeria` entrega al enrutador.
final rutasGaleria = <RouteBase>[
  GoRoute(
    path: rutaGaleria,
    name: 'galeria',
    builder: (context, state) => const PantallaGaleria(),
  ),
];
