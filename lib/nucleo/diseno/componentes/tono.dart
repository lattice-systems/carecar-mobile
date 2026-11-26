import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

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
        icono: LucideIcons300.circle,
      ),
      Tono.informacion => ColoresTono(
        fondo: c.acentoSuave,
        frente: c.acento,
        icono: LucideIcons300.info,
      ),
      Tono.exito => ColoresTono(
        fondo: c.exitoSuave,
        frente: c.exito,
        icono: LucideIcons300.circleCheck,
      ),
      Tono.advertencia => ColoresTono(
        fondo: c.advertenciaSuave,
        frente: c.advertencia,
        icono: LucideIcons300.triangleAlert,
      ),
      Tono.peligro => ColoresTono(
        fondo: c.peligroSuave,
        frente: c.peligro,
        icono: LucideIcons300.circleAlert,
      ),
    };
  }
}
