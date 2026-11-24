import 'package:carecar_mobile/nucleo/mapas/coordenada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dos coordenadas con los mismos valores son iguales', () {
    expect(const Coordenada(19.43, -99.13), const Coordenada(19.43, -99.13));
    expect(
      const Coordenada(19.43, -99.13).hashCode,
      const Coordenada(19.43, -99.13).hashCode,
    );
    expect(
      const Coordenada(19.43, -99.13) == const Coordenada(19.4, -99.1),
      isFalse,
    );
  });

  test('esValida rechaza latitudes y longitudes fuera de rango', () {
    expect(const Coordenada(19.43, -99.13).esValida, isTrue);
    expect(const Coordenada(91, 0).esValida, isFalse);
    expect(const Coordenada(0, -181).esValida, isFalse);
  });

  test('toString muestra latitud y longitud', () {
    expect(const Coordenada(1.5, 2.5).toString(), 'Coordenada(1.5, 2.5)');
  });
}
