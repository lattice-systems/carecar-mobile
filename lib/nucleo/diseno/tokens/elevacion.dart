import 'dart:ui';

import 'package:flutter/painting.dart';

import 'colores.dart';

/// Elevacion del sistema de diseno v2.
///
/// En claro se usa una sombra suave de dos capas. En oscuro no hay sombra y se
/// sube un tono de superficie.
abstract final class Elevacion {
  static const List<BoxShadow> _sombrasClaro = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static List<BoxShadow> sombras(Brightness brillo) {
    return brillo == Brightness.light ? _sombrasClaro : const [];
  }

  /// Color de superficie para un nivel. El nivel 0 es la superficie base y
  /// cualquier nivel mayor usa la superficie elevada.
  static Color superficie(
    PaletaColores paleta,
    Brightness brillo, {
    required int nivel,
  }) {
    return nivel <= 0 ? paleta.superficie : paleta.superficieElevada;
  }
}
