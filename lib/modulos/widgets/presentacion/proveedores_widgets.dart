import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/accesos_rapidos_quick_actions.dart';
import '../datos/repositorio_actividad_en_vivo_api.dart';
import '../datos/servicio_actividad_en_vivo_canal.dart';
import '../datos/servicio_actividad_en_vivo_nulo.dart';
import '../datos/widgets_home_widget.dart';
import '../dominio/acceso_rapido.dart';
import '../dominio/actividad_en_vivo.dart';
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

/// El puente con ActivityKit para la Live Activity del taller (V2-M25.05).
/// Solo en iPhone se usa el canal; en Android, escritorio, web y pruebas, el
/// nulo. Las pruebas lo sustituyen con `ServicioActividadEnVivoFake`.
final servicioActividadEnVivoProvider = Provider<ServicioActividadEnVivo>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? ServicioActividadEnVivoCanal()
      : const ServicioActividadEnVivoNulo(),
  name: 'servicioActividadEnVivoProvider',
);

/// Registro del push token de la Live Activity en el backend. Las pruebas lo
/// sustituyen con `RepositorioActividadEnVivoFake`.
final repositorioActividadEnVivoProvider = Provider<RepositorioActividadEnVivo>(
  (ref) => RepositorioActividadEnVivoApi(ref.watch(apiClienteProvider)),
  name: 'repositorioActividadEnVivoProvider',
);
