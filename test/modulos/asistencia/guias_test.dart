import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hay una guia de llanta, de corriente y de choque, empaquetadas', () {
    expect(guiasDeEmergencia.map((g) => g.tipo), [
      TipoGuia.llanta,
      TipoGuia.corriente,
      TipoGuia.choque,
    ]);
  });

  test('cada guia trae pasos en orden', () {
    for (final guia in guiasDeEmergencia) {
      expect(guia.pasos, greaterThanOrEqualTo(4));
    }
  });

  test('el identificador de la guia viaja por la ruta y vuelve igual', () {
    for (final tipo in TipoGuia.values) {
      expect(TipoGuia.desdeId(tipo.id), tipo);
    }
    expect(TipoGuia.desdeId('inexistente'), isNull);
  });
}
