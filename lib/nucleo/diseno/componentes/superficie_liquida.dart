import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Superficie translúcida con desenfoque de fondo dinámico estilo iOS / Telegram.
///
/// Combina aceleración por hardware mediante [BackdropFilter], tinte de
/// superficie con opacidad controlada y un filete de luz ultrafino de 0.5 px.
///
/// Permite que el contenido que se desplaza por detrás se vea desenfocado y
/// teñido, dándole la textura y física de cristal líquido.
class SuperficieLiquida extends StatelessWidget {
  const SuperficieLiquida({
    required this.child,
    this.radio = Radios.tarjeta,
    this.bordeRadio,
    this.intensidadDesenfoque = 20.0,
    this.opacidad = 0.82,
    this.mostrarBorde = true,
    this.colorFondo,
    this.colorBorde,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;

  /// Radio numérico para esquinas simétricas.
  final double radio;

  /// Opcional: radio detallado para esquinas asimétricas.
  final BorderRadius? bordeRadio;

  /// Intensidad del desenfoque gaussiano en sigmas.
  final double intensidadDesenfoque;

  /// Nivel de translucidez del fondo (0.0 a 1.0).
  final double opacidad;

  /// Si dibuja el filete de borde perimetral de 0.5 px.
  final bool mostrarBorde;

  /// Color de fondo personalizado. Si es nulo, usa `c.superficie` con [opacidad].
  final Color? colorFondo;

  /// Color de borde personalizado. Si es nulo, usa `c.borde` tenue.
  final Color? colorBorde;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<TokensPista>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? TokensPista.oscuro
            : TokensPista.claro);
    final c = tokens.colores;
    final r = bordeRadio ?? BorderRadius.all(Radius.circular(radio));
    final fondoEfectivo =
        colorFondo ?? c.superficie.withValues(alpha: opacidad);
    final bordeEfectivo = colorBorde ?? c.borde.withValues(alpha: 0.55);

    Widget contenido = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fondoEfectivo,
        borderRadius: r,
        border: mostrarBorde
            ? Border.all(color: bordeEfectivo, width: 0.5)
            : null,
      ),
      child: child,
    );

    if (intensidadDesenfoque > 0) {
      contenido = ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: intensidadDesenfoque,
            sigmaY: intensidadDesenfoque,
          ),
          child: contenido,
        ),
      );
    } else {
      contenido = ClipRRect(borderRadius: r, child: contenido);
    }

    if (margin != null) {
      contenido = Padding(padding: margin!, child: contenido);
    }

    return contenido;
  }
}
