import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/accesos_rapidos_quick_actions.dart';
import '../datos/widgets_home_widget.dart';
import '../dominio/acceso_rapido.dart';
import '../dominio/contenido_widgets.dart';

/// El puerto con el sistema operativo para los accesos del icono. Las pruebas
/// lo sustituyen con `overrideWithValue`.
final puertoAccesosRapidosProvider = Provider<PuertoAccesosRapidos>(
  (ref) => AccesosRapidosQuickActions(),
  name: 'puertoAccesosRapidosProvider',
);

/// El puerto con los widgets de pantalla de inicio (V2-M25): próxima cita,
/// taller en vivo, mantenimiento, bitácora y accesos rápidos. Las pruebas lo
/// sustituyen con `overrideWithValue`.
final puertoWidgetsProvider = Provider<PuertoWidgets>(
  (ref) => WidgetsHomeWidget(),
  name: 'puertoWidgetsProvider',
);
