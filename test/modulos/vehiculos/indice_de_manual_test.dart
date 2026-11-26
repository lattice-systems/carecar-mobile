import 'package:carecar_mobile/modulos/vehiculos/dominio/indice_de_manual.dart';
import 'package:flutter_test/flutter_test.dart';

IndiceDeManual _indice() => const IndiceDeManual(
  manual: 'Nissan March 2020',
  paginas: [
    PaginaDeManual(1, 'Prefacio y bienvenida al vehículo'),
    PaginaDeManual(12, 'Cómo revisar la presión de las llantas con seguridad'),
    PaginaDeManual(40, 'El nivel del aceite del motor y su cambio'),
    PaginaDeManual(41, 'Cambio de aceite recomendado cada 10 000 km'),
  ],
);

void main() {
  test('encuentra la página que contiene el término', () {
    final r = _indice().buscar('llantas');
    expect(r.map((e) => e.pagina), [12]);
  });

  test('ignora mayúsculas y acentos en ambos lados', () {
    expect(_indice().buscar('ACEITE').map((e) => e.pagina), [40, 41]);
    expect(_indice().buscar('prefacio').map((e) => e.pagina), [1]);
    expect(_indice().buscar('vehiculo').map((e) => e.pagina), [1]);
  });

  test('el fragmento rodea el término hallado', () {
    final r = _indice().buscar('presión');
    expect(r.single.fragmento, contains('presión de las llantas'));
  });

  test('ordena por página y no repite una página', () {
    final r = _indice().buscar('aceite');
    expect(r.map((e) => e.pagina), [40, 41]);
  });

  test('una búsqueda muy corta o vacía no devuelve nada', () {
    expect(_indice().buscar('a'), isEmpty);
    expect(_indice().buscar('   '), isEmpty);
  });

  test('sin coincidencias devuelve lista vacía', () {
    expect(_indice().buscar('turbocompresor'), isEmpty);
  });
}
