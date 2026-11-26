import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detector_integridad.dart';
import 'estado_de_conexion_segura.dart';
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

/// Si el certificado del servidor se rechazó (V2-M22.15). `main.dart` inyecta el
/// mismo que escucha el cliente de la API; sin inyección arranca sin problema.
final estadoConexionSeguraProvider = Provider<EstadoDeConexionSegura>((ref) {
  final estado = EstadoDeConexionSegura();
  ref.onDispose(estado.dispose);
  return estado;
}, name: 'estadoConexionSeguraProvider');
