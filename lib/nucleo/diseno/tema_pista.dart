import 'package:flutter/material.dart';

import 'tokens/tokens_pista.dart';

/// Construye el `ThemeData` del sistema de diseno v2 «Pista».
///
/// Material 3 aporta gestos y accesibilidad, la identidad visual sale de los
/// tokens. Los componentes propios leen `TokensPista.de(context)`.
abstract final class TemaPista {
  static ThemeData claro() => _construir(TokensPista.claro);

  static ThemeData oscuro() => _construir(TokensPista.oscuro);

  static ThemeData _construir(TokensPista tokens) {
    final c = tokens.colores;
    final t = tokens.tipografia;

    final esquema = ColorScheme(
      brightness: tokens.brillo,
      primary: c.acento,
      onPrimary: c.sobreAcento,
      secondary: c.marca,
      onSecondary: c.superficie,
      error: c.peligro,
      onError: c.sobreAcento,
      surface: c.superficie,
      onSurface: c.texto,
      onSurfaceVariant: c.textoSecundario,
      surfaceContainerLowest: c.fondo,
      surfaceContainerLow: c.superficie,
      surfaceContainer: c.superficie,
      surfaceContainerHigh: c.superficieElevada,
      surfaceContainerHighest: c.superficieHundida,
      outline: c.borde,
      outlineVariant: c.borde,
      scrim: c.velo,
    );

    final texto = TextTheme(
      displayLarge: t.display,
      displayMedium: t.display,
      displaySmall: t.titulo1,
      headlineLarge: t.titulo1,
      headlineMedium: t.titulo2,
      headlineSmall: t.titulo3,
      titleLarge: t.titulo3,
      titleMedium: t.cuerpoFuerte,
      titleSmall: t.etiqueta,
      bodyLarge: t.cuerpo,
      bodyMedium: t.cuerpoChico,
      bodySmall: t.cuerpoChico,
      labelLarge: t.etiqueta,
      labelMedium: t.etiqueta,
      labelSmall: t.micro,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: tokens.brillo,
      colorScheme: esquema,
      scaffoldBackgroundColor: c.fondo,
      canvasColor: c.fondo,
      dividerColor: c.borde,
      textTheme: texto,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [tokens],
    );
  }
}
