import 'package:carecar_mobile/nucleo/diseno/tokens/movimiento.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las duraciones coinciden con el documento', () {
    expect(Movimiento.rapido.duracion, const Duration(milliseconds: 120));
    expect(Movimiento.base.duracion, const Duration(milliseconds: 220));
    expect(Movimiento.enfatico.duracion, const Duration(milliseconds: 360));
  });

  test('las curvas coinciden con el documento', () {
    expect(Movimiento.rapido.curva, Curves.easeOut);
    expect(Movimiento.base.curva, const Cubic(0.2, 0, 0, 1));
    expect(Movimiento.enfatico.curva, const Cubic(0.05, 0.7, 0.1, 1));
  });

  test('el resorte usa amortiguacion de 0.85', () {
    expect(Movimiento.resorte.damping > 0, isTrue);
    expect(Movimiento.amortiguacionResorte, 0.85);
  });

  test('con reducir movimiento todo pasa a un fundido de 120 ms', () {
    final reducido = Movimiento.enfatico.paraAccesibilidad(reducir: true);
    expect(reducido.duracion, const Duration(milliseconds: 120));
    expect(reducido.curva, Curves.linear);

    final normal = Movimiento.enfatico.paraAccesibilidad(reducir: false);
    expect(normal, Movimiento.enfatico);
  });
}
