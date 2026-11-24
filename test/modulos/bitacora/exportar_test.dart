import 'package:carecar_mobile/modulos/bitacora/dominio/exportar_bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:flutter_test/flutter_test.dart';

Gasto g(
  int id,
  DateTime fecha,
  TipoGasto tipo,
  double monto, {
  double? litros,
  int? km,
  String? descripcion,
}) => Gasto(
  id: id,
  vehiculoId: 1,
  tipo: tipo,
  monto: monto,
  fecha: fecha,
  litros: litros,
  km: km,
  descripcion: descripcion,
);

void main() {
  final gastos = [
    g(1, DateTime(2026, 9, 3), TipoGasto.lavado, 80),
    g(
      2,
      DateTime(2026, 10, 10),
      TipoGasto.gasolina,
      849.5,
      litros: 35.42,
      km: 12500,
    ),
    g(
      3,
      DateTime(2026, 11, 20),
      TipoGasto.otro,
      300,
      descripcion: 'Placa, "mica" y gestoría',
    ),
  ];

  group('rango de meses (V2-M18.05)', () {
    test('incluye el primer y el último mes del rango', () {
      final r = gastosEnRango(gastos, DateTime(2026, 10), DateTime(2026, 11));
      expect(r.map((x) => x.id), [2, 3]);
    });

    test('un solo mes', () {
      expect(
        gastosEnRango(gastos, DateTime(2026, 9), DateTime(2026, 9)).single.id,
        1,
      );
    });

    test('ordena del más reciente al más viejo', () {
      final r = gastosEnRango(gastos, DateTime(2026, 9), DateTime(2026, 11));
      expect(r.map((x) => x.id), [3, 2, 1]);
    });
  });

  group('CSV', () {
    final csv = gastosACsv(gastos);
    final lineas = csv.split('\r\n');

    test('trae encabezado y una fila por gasto', () {
      expect(lineas.first, 'fecha,tipo,monto,litros,km,descripcion');
      expect(lineas.where((l) => l.isNotEmpty), hasLength(4));
    });

    test('fechas ISO, decimales con punto y vacíos donde no aplica', () {
      expect(lineas, contains('2026-09-03,lavado,80.00,,,'));
      expect(lineas, contains('2026-10-10,gasolina,849.50,35.42,12500,'));
    });

    test('escapa comas y comillas de la descripción', () {
      expect(
        lineas,
        contains('2026-11-20,otro,300.00,,,"Placa, ""mica"" y gestoría"'),
      );
    });

    test('empieza con la marca UTF-8 para que Excel lea los acentos', () {
      expect(csv.startsWith('﻿'), isTrue);
    });
  });

  test('nombreArchivoBitacora arma un nombre sin espacios ni acentos', () {
    expect(
      nombreArchivoBitacora('Aveo 2022', DateTime(2026, 9), DateTime(2026, 11)),
      'bitacora-aveo-2022-2026-09-a-2026-11',
    );
  });
}
