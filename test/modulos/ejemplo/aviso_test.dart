import 'package:carecar_mobile/modulos/ejemplo/ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalB = Aviso(id: 1, titulo: 'B', detalle: '');
  const normalA = Aviso(id: 2, titulo: 'A', detalle: '');
  const urgenteZ = Aviso(id: 3, titulo: 'Z', detalle: '', urgente: true);

  test('los urgentes van primero y el resto por titulo', () {
    expect(Aviso.ordenar([normalB, urgenteZ, normalA]), [
      urgenteZ,
      normalA,
      normalB,
    ]);
  });

  test('no modifica la lista original', () {
    final original = [normalB, normalA];
    Aviso.ordenar(original);
    expect(original, [normalB, normalA]);
  });
}
