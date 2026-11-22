import 'package:carecar_mobile/nucleo/diseno/tokens/espaciado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la escala usa base de 4 y los valores del documento', () {
    expect(Espaciado.e1, 4);
    expect(Espaciado.e2, 8);
    expect(Espaciado.e3, 12);
    expect(Espaciado.e4, 16);
    expect(Espaciado.e5, 20);
    expect(Espaciado.e6, 24);
    expect(Espaciado.e8, 32);
    expect(Espaciado.e10, 40);
    expect(Espaciado.e14, 56);
    expect(Espaciado.e18, 72);
  });

  test('todos los valores son multiplos de 4', () {
    for (final valor in Espaciado.escala) {
      expect(valor % 4, 0);
    }
  });

  test('margenes y ancho maximo del documento', () {
    expect(Espaciado.margenTelefono, 16);
    expect(Espaciado.margenTableta, 24);
    expect(Espaciado.anchoMaximoContenido, 640);
    expect(Espaciado.objetivoTactilMinimo, 48);
  });
}
