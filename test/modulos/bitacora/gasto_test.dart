import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hoy = DateTime(2026, 11, 23);

  BorradorGasto carga({
    double? monto = 800,
    double? litros = 40,
    int? km = 12500,
    DateTime? fecha,
  }) => BorradorGasto(
    tipo: TipoGasto.gasolina,
    monto: monto,
    litros: litros,
    km: km,
    fecha: fecha ?? DateTime(2026, 11, 20),
  );

  group('carga de gasolina (V2-M18.01)', () {
    test('una carga completa no tiene campos inválidos', () {
      expect(carga().camposInvalidos(hoy: hoy), isEmpty);
    });

    test('monto y litros deben ser mayores a 0', () {
      expect(carga(monto: 0, litros: 0).camposInvalidos(hoy: hoy), {
        CampoGasto.monto,
        CampoGasto.litros,
      });
      expect(carga(monto: null, litros: null).camposInvalidos(hoy: hoy), {
        CampoGasto.monto,
        CampoGasto.litros,
      });
    });

    test('el km es obligatorio', () {
      expect(carga(km: null).camposInvalidos(hoy: hoy), {CampoGasto.km});
    });

    test('el km no puede ser menor a la última lectura', () {
      final b = carga(km: 12000);
      expect(b.camposInvalidos(hoy: hoy, kmMinimo: 12500), {CampoGasto.km});
      expect(
        carga(km: 12500).camposInvalidos(hoy: hoy, kmMinimo: 12500),
        isEmpty,
      );
    });

    test('la fecha no puede ser futura', () {
      expect(carga(fecha: DateTime(2026, 11, 24)).camposInvalidos(hoy: hoy), {
        CampoGasto.fecha,
      });
      expect(
        carga(fecha: DateTime(2026, 11, 23)).camposInvalidos(hoy: hoy),
        isEmpty,
      );
    });
  });

  group('otros gastos (V2-M18.04)', () {
    test('estacionamiento, casetas y lavado solo piden monto y fecha', () {
      for (final tipo in [
        TipoGasto.estacionamiento,
        TipoGasto.casetas,
        TipoGasto.lavado,
      ]) {
        final b = BorradorGasto(
          tipo: tipo,
          monto: 50,
          fecha: DateTime(2026, 11, 1),
        );
        expect(b.camposInvalidos(hoy: hoy), isEmpty, reason: '$tipo');
      }
    });

    test('«otro» exige descripción', () {
      final b = BorradorGasto(
        tipo: TipoGasto.otro,
        monto: 90,
        fecha: DateTime(2026, 11, 1),
        descripcion: '  ',
      );
      expect(b.camposInvalidos(hoy: hoy), {CampoGasto.descripcion});
    });

    test('la descripción no pasa de 200 caracteres', () {
      final b = BorradorGasto(
        tipo: TipoGasto.lavado,
        monto: 90,
        fecha: DateTime(2026, 11, 1),
        descripcion: 'a' * 201,
      );
      expect(b.camposInvalidos(hoy: hoy), {CampoGasto.descripcion});
    });

    test('el monto debe ser mayor a 0', () {
      final b = BorradorGasto(
        tipo: TipoGasto.casetas,
        monto: -5,
        fecha: DateTime(2026, 11, 1),
      );
      expect(b.camposInvalidos(hoy: hoy), {CampoGasto.monto});
    });
  });

  test('TipoGasto.desde lee el texto del contrato y rechaza lo ajeno', () {
    expect(TipoGasto.desde('gasolina'), TipoGasto.gasolina);
    expect(TipoGasto.desde('otro'), TipoGasto.otro);
    expect(() => TipoGasto.desde('peaje'), throwsFormatException);
  });
}
