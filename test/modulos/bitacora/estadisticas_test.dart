import 'package:carecar_mobile/modulos/bitacora/dominio/estadisticas.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:flutter_test/flutter_test.dart';

Gasto carga(int id, DateTime fecha, int km, double litros, double monto) =>
    Gasto(
      id: id,
      vehiculoId: 1,
      tipo: TipoGasto.gasolina,
      monto: monto,
      litros: litros,
      km: km,
      fecha: fecha,
    );

Gasto otro(int id, DateTime fecha, double monto, [TipoGasto? tipo]) => Gasto(
  id: id,
  vehiculoId: 1,
  tipo: tipo ?? TipoGasto.lavado,
  monto: monto,
  fecha: fecha,
);

void main() {
  group('rendimiento (V2-M18.03)', () {
    test('sin cargas o con una sola no hay datos todavía', () {
      expect(calcularRendimiento(const []), isNull);
      expect(
        calcularRendimiento([carga(1, DateTime(2026, 10, 1), 10000, 40, 800)]),
        isNull,
      );
    });

    test('km/l y \$/km se calculan entre cargas consecutivas', () {
      final r = calcularRendimiento([
        carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
        carga(2, DateTime(2026, 10, 15), 10400, 40, 840),
      ])!;
      // 400 km con los 40 l de la segunda carga; 840 pesos por 400 km.
      expect(r.kmRecorridos, 400);
      expect(r.kmPorLitro, closeTo(10, 1e-9));
      expect(r.costoPorKm, closeTo(2.1, 1e-9));
      expect(r.tramos, 1);
    });

    test('con varias cargas se pondera por kilómetros', () {
      final r = calcularRendimiento([
        carga(3, DateTime(2026, 11, 1), 10900, 30, 600),
        carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
        carga(2, DateTime(2026, 10, 15), 10400, 40, 840),
      ])!;
      // Tramos: 400 km/40 l/840 pesos y 500 km/30 l/600 pesos.
      expect(r.kmRecorridos, 900);
      expect(r.kmPorLitro, closeTo(900 / 70, 1e-9));
      expect(r.costoPorKm, closeTo(1440 / 900, 1e-9));
      expect(r.tramos, 2);
    });

    test('ignora otros gastos y el tramo sin avance de km', () {
      final r = calcularRendimiento([
        carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
        carga(2, DateTime(2026, 10, 2), 10000, 5, 100),
        otro(3, DateTime(2026, 10, 3), 999),
        carga(4, DateTime(2026, 10, 15), 10300, 30, 600),
      ])!;
      expect(r.kmRecorridos, 300);
      expect(r.kmPorLitro, closeTo(10, 1e-9));
      expect(r.costoPorKm, closeTo(2, 1e-9));
    });

    test('si ninguna pareja avanza no hay datos', () {
      expect(
        calcularRendimiento([
          carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
          carga(2, DateTime(2026, 10, 2), 10000, 40, 800),
        ]),
        isNull,
      );
    });
  });

  group('gasto por mes', () {
    test('suma todos los tipos y ordena del mes más viejo al más nuevo', () {
      final meses = gastoPorMes([
        otro(1, DateTime(2026, 11, 5), 100),
        carga(2, DateTime(2026, 10, 30), 10000, 40, 800),
        otro(3, DateTime(2026, 11, 20), 50, TipoGasto.casetas),
        otro(4, DateTime(2026, 9, 1), 20),
      ]);
      expect(meses.map((m) => m.mes), [
        DateTime(2026, 9),
        DateTime(2026, 10),
        DateTime(2026, 11),
      ]);
      expect(meses.map((m) => m.total), [20, 800, 150]);
    });

    test('sin gastos no hay meses', () {
      expect(gastoPorMes(const []), isEmpty);
    });
  });

  test('gastoDelMes suma solo el mes pedido', () {
    final gastos = [
      otro(1, DateTime(2026, 11, 5), 100),
      otro(2, DateTime(2026, 10, 5), 70),
    ];
    expect(gastoDelMes(gastos, DateTime(2026, 11, 23)), 100);
    expect(gastoDelMes(gastos, DateTime(2026, 8, 1)), 0);
  });

  test('kmMasAlto da la última lectura conocida', () {
    expect(kmMasAlto(const []), isNull);
    expect(
      kmMasAlto([
        carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
        carga(2, DateTime(2026, 10, 15), 10400, 40, 840),
        otro(3, DateTime(2026, 10, 16), 10),
      ]),
      10400,
    );
  });
}
