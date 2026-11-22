import 'package:carecar_mobile/nucleo/diseno/tokens/contraste.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const negro = Color(0xFF000000);
  const blanco = Color(0xFFFFFFFF);

  test('negro sobre blanco da 21 a 1', () {
    expect(Contraste.razon(negro, blanco), closeTo(21, 0.01));
  });

  test('un color contra si mismo da 1 a 1', () {
    expect(Contraste.razon(blanco, blanco), closeTo(1, 0.0001));
  });

  test('el orden de los colores no cambia la razon', () {
    const gris = Color(0xFF767676);
    expect(Contraste.razon(gris, blanco), Contraste.razon(blanco, gris));
  });

  test('gris 767676 sobre blanco es el limite conocido de AA', () {
    const gris = Color(0xFF767676);
    expect(Contraste.cumpleAA(gris, blanco), isTrue);
    const masClaro = Color(0xFF777777);
    expect(Contraste.cumpleAA(masClaro, blanco), isFalse);
  });

  test('texto grande y componentes piden solo 3 a 1', () {
    const gris = Color(0xFF949494);
    expect(Contraste.cumpleAA(gris, blanco), isFalse);
    expect(Contraste.cumpleAA(gris, blanco, textoGrande: true), isTrue);
  });
}
