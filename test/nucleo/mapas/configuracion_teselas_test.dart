import 'package:carecar_mobile/nucleo/mapas/configuracion_teselas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el valor de desarrollo usa OpenStreetMap con su atribución', () {
    const c = ConfiguracionTeselas.openStreetMapDesarrollo;
    expect(c.urlPlantilla, contains('{z}'));
    expect(c.urlPlantilla, contains('{x}'));
    expect(c.urlPlantilla, contains('{y}'));
    expect(c.atribucion, contains('OpenStreetMap'));
    expect(c.esProduccion, isFalse);
  });

  test('desdeEntorno sin definiciones cae en OpenStreetMap', () {
    final c = ConfiguracionTeselas.desdeEntorno(
      url: '',
      atribucion: '',
      produccion: false,
    );
    expect(c, ConfiguracionTeselas.openStreetMapDesarrollo);
  });

  test('desdeEntorno respeta URL y atribución del proveedor contratado', () {
    final c = ConfiguracionTeselas.desdeEntorno(
      url: 'https://teselas.ejemplo.mx/{z}/{x}/{y}.png',
      atribucion: 'Proveedor Ejemplo',
      produccion: true,
    );
    expect(c.urlPlantilla, 'https://teselas.ejemplo.mx/{z}/{x}/{y}.png');
    expect(c.atribucion, 'Proveedor Ejemplo');
    expect(c.esProduccion, isTrue);
  });

  test('en producción sin URL propia se rechaza usar OpenStreetMap', () {
    expect(
      () => ConfiguracionTeselas.desdeEntorno(
        url: '',
        atribucion: '',
        produccion: true,
      ),
      throwsStateError,
    );
  });
}
