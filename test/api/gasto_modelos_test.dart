import 'package:carecar_mobile/api/modelos/gasto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GastoVehiculo', () {
    test('lee una carga de gasolina del contrato', () {
      final g = GastoVehiculo.fromJson(const {
        'id': 9,
        'vehiculoId': 4,
        'tipo': 'gasolina',
        'monto': 850,
        'litros': 35.4,
        'km': 12500,
        'fecha': '2026-11-20',
        'descripcion': null,
      });
      expect(g.id, 9);
      expect(g.vehiculoId, 4);
      expect(g.tipo, 'gasolina');
      expect(g.monto, 850.0);
      expect(g.litros, 35.4);
      expect(g.km, 12500);
      expect(g.fecha, DateTime(2026, 11, 20));
      expect(g.descripcion, isNull);
    });

    test('litros, km y descripción son opcionales', () {
      final g = GastoVehiculo.fromJson(const {
        'id': 1,
        'vehiculoId': 4,
        'tipo': 'otro',
        'monto': 90.5,
        'fecha': '2026-11-01',
        'descripcion': 'Grúa',
      });
      expect(g.litros, isNull);
      expect(g.km, isNull);
      expect(g.descripcion, 'Grúa');
    });

    test('un campo obligatorio ausente es un error de formato', () {
      expect(
        () => GastoVehiculo.fromJson(const {'id': 1}),
        throwsFormatException,
      );
    });
  });

  test('NuevoGasto escribe solo los campos que trae', () {
    expect(
      NuevoGasto(
        tipo: 'gasolina',
        monto: 850,
        litros: 35.4,
        km: 12500,
        fecha: DateTime(2026, 11, 20),
      ).toJson(),
      {
        'tipo': 'gasolina',
        'monto': 850,
        'litros': 35.4,
        'km': 12500,
        'fecha': '2026-11-20',
      },
    );
    expect(
      NuevoGasto(
        tipo: 'otro',
        monto: 90,
        fecha: DateTime(2026, 11, 1),
        descripcion: 'Grúa',
      ).toJson(),
      {
        'tipo': 'otro',
        'monto': 90,
        'fecha': '2026-11-01',
        'descripcion': 'Grúa',
      },
    );
  });
}
