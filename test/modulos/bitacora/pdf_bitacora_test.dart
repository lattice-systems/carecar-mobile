import 'dart:convert';

import 'package:carecar_mobile/modulos/bitacora/datos/pdf_bitacora.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('genera un PDF válido con acentos y muchas filas (V2-M18.05)', () async {
    final bytes = await generarPdfBitacora(
      const DatosPdfBitacora(
        titulo: 'Bitácora de Aveo 2022',
        periodo: 'septiembre 2026 a noviembre 2026',
        columnas: ['Fecha', 'Tipo', 'Monto', 'Litros', 'Km', 'Detalle'],
        filas: [
          ['2026-11-20', 'Gasolina', r'$849.50', '35.42', '12500', ''],
          ['2026-11-21', 'Otro', r'$300.00', '', '', 'Placa y gestoría'],
        ],
        total: r'Total: $1,149.50',
      ),
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(500));
  });

  test(
    'con más filas de las que caben en una hoja pagina sin fallar',
    () async {
      final filas = [
        for (var i = 0; i < 120; i++)
          [
            '2026-11-${(i % 28 + 1).toString().padLeft(2, '0')}',
            'Lavado',
            r'$80.00',
            '',
            '',
            'Gasto $i',
          ],
      ];
      final bytes = await generarPdfBitacora(
        DatosPdfBitacora(
          titulo: 'Bitácora',
          periodo: 'noviembre 2026',
          columnas: const ['Fecha', 'Tipo', 'Monto', 'Litros', 'Km', 'Detalle'],
          filas: filas,
          total: r'Total: $9,600.00',
        ),
      );
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    },
  );
}
