import 'package:carecar_mobile/nucleo/diseno/tokens/radios.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los radios coinciden con el documento', () {
    expect(Radios.control, 10);
    expect(Radios.tarjeta, 16);
    expect(Radios.hoja, 28);
    expect(Radios.pildora, 999);
  });

  test('la hoja solo redondea las esquinas de arriba', () {
    expect(
      Radios.bordeHoja,
      const BorderRadius.vertical(top: Radius.circular(28)),
    );
  });
}
