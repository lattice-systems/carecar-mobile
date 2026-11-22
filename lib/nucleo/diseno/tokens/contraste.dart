import 'dart:math' as math;
import 'dart:ui';

/// Calculo de contraste segun WCAG 2.2.
abstract final class Contraste {
  static const double minimoTexto = 4.5;
  static const double minimoTextoGrande = 3;

  /// Razon de contraste entre dos colores, de 1 a 21.
  static double razon(Color a, Color b) {
    final la = _luminancia(a);
    final lb = _luminancia(b);
    final mayor = math.max(la, lb);
    final menor = math.min(la, lb);
    return (mayor + 0.05) / (menor + 0.05);
  }

  static bool cumpleAA(Color a, Color b, {bool textoGrande = false}) {
    final minimo = textoGrande ? minimoTextoGrande : minimoTexto;
    return razon(a, b) >= minimo;
  }

  static double _luminancia(Color c) {
    return 0.2126 * _canal(c.r) + 0.7152 * _canal(c.g) + 0.0722 * _canal(c.b);
  }

  static double _canal(double valor) {
    if (valor <= 0.03928) return valor / 12.92;
    return math.pow((valor + 0.055) / 1.055, 2.4).toDouble();
  }
}
