import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/accesos_rapidos_quick_actions.dart';
import '../dominio/acceso_rapido.dart';

/// El puerto con el sistema operativo para los accesos del icono. Las pruebas
/// lo sustituyen con `overrideWithValue`.
final puertoAccesosRapidosProvider = Provider<PuertoAccesosRapidos>(
  (ref) => AccesosRapidosQuickActions(),
  name: 'puertoAccesosRapidosProvider',
);
