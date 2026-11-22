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

  static const double amortiguacionResorte = 0.85;

  static final SpringDescription resorte = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 300,
    ratio: amortiguacionResorte,
  );
}
