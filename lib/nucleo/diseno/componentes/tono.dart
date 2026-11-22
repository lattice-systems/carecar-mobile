import 'package:flutter/material.dart';

import '../tokens/colores.dart';

/// Intencion de color compartida por insignia y aviso.
enum Tono { neutro, informacion, exito, advertencia, peligro }

/// Colores y icono de un [Tono] en una paleta.
///
/// El icono acompana siempre al color para que el estado no dependa solo del
/// color.
class ColoresTono {
  const ColoresTono({
    required this.fondo,
    required this.frente,
    required this.icono,
  });

  final Color fondo;
  final Color frente;
  final IconData icono;

  static ColoresTono de(Tono tono, PaletaColores c) {
    return switch (tono) {
      Tono.neutro => ColoresTono(
        fondo: c.superficieHundida,
        frente: c.textoSecundario,
        icono: Icons.circle_outlined,
      ),
      Tono.informacion => ColoresTono(
        fondo: c.acentoSuave,
        frente: c.acento,
        icono: Icons.info_outline,
      ),
      Tono.exito => ColoresTono(
        fondo: c.exitoSuave,
        frente: c.exito,
        icono: Icons.check_circle_outline,
      ),
      Tono.advertencia => ColoresTono(
        fondo: c.advertenciaSuave,
        frente: c.advertencia,
        icono: Icons.warning_amber_rounded,
      ),
      Tono.peligro => ColoresTono(
        fondo: c.peligroSuave,
        frente: c.peligro,
        icono: Icons.error_outline,
      ),
    };
  }
}
