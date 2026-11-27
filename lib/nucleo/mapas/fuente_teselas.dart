import 'package:flutter/painting.dart';

/// De dónde sale la imagen de cada tesela cuando no se descarga de la red.
///
/// El componente `Mapa` usa el servidor de `ConfiguracionTeselas`; las pruebas,
/// los golden y la galería le pasan una fuente propia y así no salen a la red.
abstract interface class FuenteTeselas {
  /// La imagen de la tesela `x`, `y` en ese nivel de acercamiento.
  ImageProvider tesela({required int x, required int y, required int zoom});
}
