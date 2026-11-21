import 'dart:typed_data';

import 'package:carecar_mobile/manuales/guardar_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el nombre de archivo es limpio', () {
    expect(
      nombreArchivoPdf('Nissan Frontier 2024: Manual/propietario'),
      'Manual Nissan Frontier 2024 Manual propietario.pdf',
    );
    expect(
      nombreArchivoPdf('Manual Nissan March 2026'),
      'Manual Nissan March 2026.pdf',
    );
  });

  test('guardar devuelve guardado o cancelado segun el selector', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    String? nombre;
    final ok = await guardarPdf(
      bytes,
      'Nissan March 2026',
      guardador: (b, n) async {
        nombre = n;
        return '/ruta/$n';
      },
    );
    expect(ok, ResultadoGuardado.guardado);
    expect(nombre, 'Manual Nissan March 2026.pdf');
    final cancelado = await guardarPdf(
      bytes,
      'x',
      guardador: (b, n) async => null,
    );
    expect(cancelado, ResultadoGuardado.cancelado);
  });
}
