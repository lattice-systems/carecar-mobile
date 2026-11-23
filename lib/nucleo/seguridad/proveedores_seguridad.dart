import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detector_integridad.dart';
import 'politica_datos_locales.dart';

/// El detector de root y jailbreak. Las pruebas lo sustituyen con
/// `overrideWithValue(DetectorIntegridadFalso(...))`.
final detectorIntegridadProvider = Provider<DetectorIntegridad>(
  (ref) => const DetectorIntegridadDelSistema(),
  name: 'detectorIntegridadProvider',
);

/// La politica de datos locales. `main.dart` inyecta la misma que ya evaluo al
/// arrancar; sin inyeccion arranca en `desconocido` (permite el cache).
final politicaDatosLocalesProvider = Provider<PoliticaDatosLocales>((ref) {
  final politica = PoliticaDatosLocales();
  ref.onDispose(politica.dispose);
  return politica;
}, name: 'politicaDatosLocalesProvider');
