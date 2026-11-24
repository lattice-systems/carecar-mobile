import 'package:flutter/foundation.dart';

import '../../config/flavor.dart';

/// De dónde salen las teselas del mapa y qué crédito se muestra.
///
/// Decisión 0006: la URL y la atribución se configuran, no se escriben en las
/// pantallas. Se leen de `--dart-define=TILES_URL=...` y
/// `--dart-define=TILES_ATTRIBUTION=...`; sin ellas, desarrollo usa las teselas
/// públicas de OpenStreetMap con tráfico mínimo. Un build de producción
/// (`--dart-define=TILES_PRODUCTION=true`) exige un proveedor propio, porque la
/// política de OpenStreetMap prohíbe el servidor público para apps con tráfico.
@immutable
class ConfiguracionTeselas {
  const ConfiguracionTeselas({
    required this.urlPlantilla,
    required this.atribucion,
    this.esProduccion = false,
  });

  /// Plantilla con `{z}`, `{x}` y `{y}` (y opcionalmente `{s}`).
  final String urlPlantilla;

  /// Crédito obligatorio por licencia; la pantalla lo muestra sobre el mapa.
  final String atribucion;

  /// Si el build es de producción (con proveedor contratado).
  final bool esProduccion;

  /// Servidor público de OpenStreetMap: solo desarrollo y pruebas manuales.
  static const openStreetMapDesarrollo = ConfiguracionTeselas(
    urlPlantilla: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    atribucion: '© colaboradores de OpenStreetMap',
  );

  /// Valores de `--dart-define`; vacíos si no se pasaron.
  static const _urlDefinida = String.fromEnvironment('TILES_URL');
  static const _atribucionDefinida = String.fromEnvironment(
    'TILES_ATTRIBUTION',
  );
  static const _produccionDefinida = bool.fromEnvironment('TILES_PRODUCTION');

  /// Configuración de este build.
  static ConfiguracionTeselas get delEntorno =>
      ConfiguracionTeselas.desdeEntorno(
        url: _urlDefinida,
        atribucion: _atribucionDefinida,
        produccion: _produccionDefinida,
        permitirHttp: Flavor.actual.permiteHttpEnClaro,
      );

  /// Resuelve la configuración a partir de los valores del entorno.
  ///
  /// Lanza [StateError] si es producción y falta la URL del proveedor.
  factory ConfiguracionTeselas.desdeEntorno({
    required String url,
    required String atribucion,
    required bool produccion,
    bool permitirHttp = false,
  }) {
    // V2-M22.09: fuera de desarrollo las teselas viajan por https.
    if (url.startsWith('http://') && !permitirHttp) {
      throw StateError(
        'TILES_URL debe usar https fuera del flavor de desarrollo.',
      );
    }
    if (url.isEmpty) {
      if (produccion) {
        throw StateError(
          'Producción exige TILES_URL: el servidor público de OpenStreetMap '
          'no se puede usar con tráfico real.',
        );
      }
      return openStreetMapDesarrollo;
    }
    return ConfiguracionTeselas(
      urlPlantilla: url,
      atribucion: atribucion.isEmpty ? '© OpenStreetMap' : atribucion,
      esProduccion: produccion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ConfiguracionTeselas &&
      other.urlPlantilla == urlPlantilla &&
      other.atribucion == atribucion &&
      other.esProduccion == esProduccion;

  @override
  int get hashCode => Object.hash(urlPlantilla, atribucion, esProduccion);
}
