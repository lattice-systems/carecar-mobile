import 'package:flutter/animation.dart';

/// Una duracion con su curva.
class TokenMovimiento {
  const TokenMovimiento(this.duracion, this.curva);

  final Duration duracion;
  final Curve curva;

  /// Con reducir movimiento todo pasa a un fundido corto y lineal.
  TokenMovimiento paraAccesibilidad({required bool reducir}) {
    if (!reducir) return this;
    return const TokenMovimiento(Duration(milliseconds: 120), Curves.linear);
  }
}

/// Duraciones y curvas del sistema de diseno v2.
abstract final class Movimiento {
  /// Micro-interaccion tactil para toques instantaneos (70 ms y frenado suave).
  static const TokenMovimiento toqueBajada = TokenMovimiento(
    Duration(milliseconds: 70),
    Curves.easeOutCubic,
  );

  /// Recuperacion elástica tras soltar (100 ms y curva suave).
  static const TokenMovimiento toqueSubida = TokenMovimiento(
    Duration(milliseconds: 100),
    Curves.easeOutCubic,
  );

  static const TokenMovimiento rapido = TokenMovimiento(
    Duration(milliseconds: 120),
    Curves.easeOut,
  );
  static const TokenMovimiento base = TokenMovimiento(
    Duration(milliseconds: 220),
    Cubic(0.2, 0, 0, 1),
  );
  static const TokenMovimiento enfatico = TokenMovimiento(
    Duration(milliseconds: 360),
    Cubic(0.05, 0.7, 0.1, 1),
  );

  /// Entrada de una portada (inicio, acceso): larga, arranca rápido y se posa.
  /// Se reparte en tramos con `Aparecer`.
  static const TokenMovimiento portada = TokenMovimiento(
    Duration(milliseconds: 1100),
    Cubic(0.16, 1, 0.3, 1),
  );

  /// Curva con la que se trazan las dos C del logo: arranca y frena suave.
  static const Curve curvaDeTrazo = Curves.easeInOutCubic;

  static const double amortiguacionResorte = 0.85;

  static final SpringDescription resorte = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 300,
    ratio: amortiguacionResorte,
  );
}
