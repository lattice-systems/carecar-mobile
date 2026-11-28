import 'package:carecar_mobile/nucleo/navegacion/barra_de_pestanas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pestanaDe', () {
    test('el inicio es la primera pestaña', () {
      expect(pestanaDe('/'), 0);
    });

    test('cada raíz y lo que cuelga de ella conserva su pestaña', () {
      expect(pestanaDe('/garaje'), 1);
      expect(pestanaDe('/garaje/5'), 1);
      expect(pestanaDe('/citas'), 2);
      expect(pestanaDe('/catalogo/1'), 3);
    });

    test('las pantallas completas no llevan barra', () {
      expect(pestanaDe('/citas/agendar'), isNull);
      expect(pestanaDe('/garaje/5/manual'), isNull);
      expect(pestanaDe('/catalogo/1/calculadora'), isNull);
    });

    test('lo que no es una pestaña no lleva barra', () {
      expect(pestanaDe('/ajustes'), isNull);
      expect(pestanaDe('/taller/41'), isNull);
    });
  });
}
