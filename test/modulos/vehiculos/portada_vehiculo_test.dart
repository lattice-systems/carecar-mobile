import 'package:carecar_mobile/modulos/vehiculos/presentacion/portada_vehiculo.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final c = TokensPista.claro.colores;
  final tokens = TokensPista.claro;

  test('el tinte sale solo de los tokens segun el color del auto', () {
    expect(tinteDeColor(tokens, 'Rojo'), c.peligro);
    expect(tinteDeColor(tokens, 'Verde bosque'), c.exito);
    expect(tinteDeColor(tokens, 'Amarillo'), c.advertencia);
    expect(tinteDeColor(tokens, 'Azul'), c.acento);
    expect(tinteDeColor(tokens, 'Gris'), c.textoSecundario);
    expect(tinteDeColor(tokens, 'Morado'), c.marca);
    expect(tinteDeColor(tokens, null), c.marca);
  });
}
