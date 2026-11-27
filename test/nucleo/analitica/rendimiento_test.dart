import 'package:carecar_mobile/nucleo/analitica/analitica.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'V2-M23.05: estima cuadros perdidos con la frecuencia de la pantalla',
    () {
      const rapido = Duration(milliseconds: 8);
      const lento = Duration(milliseconds: 24);
      expect(estimarCuadrosPerdidos(rapido, rapido, 60), 0);
      expect(estimarCuadrosPerdidos(lento, rapido, 60), 1);
      expect(estimarCuadrosPerdidos(rapido, lento, 120), 2);
      expect(estimarCuadrosPerdidos(rapido, lento, double.nan), 1);
    },
  );
}
