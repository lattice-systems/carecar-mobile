import 'package:carecar_mobile/nucleo/diseno/componentes/tinte_auto.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final c = TokensPista.claro.colores;

  test('el tinte sale solo de los tokens segun el color del auto', () {
    expect(tinteDeColorAuto(c, 'Rojo'), c.peligro);
    expect(tinteDeColorAuto(c, 'Verde bosque'), c.exito);
    expect(tinteDeColorAuto(c, 'Amarillo'), c.advertencia);
    expect(tinteDeColorAuto(c, 'Naranja'), c.advertencia);
  });

  test('azul, neutros, desconocidos y sin color usan el acento', () {
    expect(tinteDeColorAuto(c, 'Azul'), c.acento);
    for (final neutro in ['Gris', 'Blanco', 'Plata', 'Negro', 'Silver']) {
      expect(tinteDeColorAuto(c, neutro), c.acento, reason: neutro);
    }
    expect(tinteDeColorAuto(c, 'Morado'), c.acento);
    expect(tinteDeColorAuto(c, null), c.acento);
  });
}
