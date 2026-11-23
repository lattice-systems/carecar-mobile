import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/accesos_rapidos_quick_actions.dart';
import '../datos/widget_cita_home_widget.dart';
import '../dominio/acceso_rapido.dart';
import '../dominio/proxima_cita_widget.dart';

/// El puerto con el sistema operativo para los accesos del icono. Las pruebas
/// lo sustituyen con `overrideWithValue`.
final puertoAccesosRapidosProvider = Provider<PuertoAccesosRapidos>(
  (ref) => AccesosRapidosQuickActions(),
  name: 'puertoAccesosRapidosProvider',
);

/// El puerto con el widget de pantalla de inicio de la proxima cita
/// (V2-M25.01). Las pruebas lo sustituyen con `overrideWithValue`.
final puertoWidgetCitaProvider = Provider<PuertoWidgetCita>(
  (ref) => WidgetCitaHomeWidget(),
  name: 'puertoWidgetCitaProvider',
);
