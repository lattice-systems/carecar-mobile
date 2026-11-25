import 'package:carecar_mobile/api/modelos/mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

const _servicio = {
  'id': 3,
  'nombre': 'Servicio de 10,000 km',
  'km': 10000,
  'meses': 12,
  'precioEstimado': 1850,
  'conceptos': ['Aceite y filtro', 'Revisión de frenos'],
  'estado': 'proximo',
  'hechoEn': null,
};

const _plan = {
  'vehiculoId': 5,
  'kmActual': 9000,
  'kmActualizadoEn': '2026-11-20',
  'kmFuente': 'cliente',
  'promedioKmDiario': 38.5,
  'servicios': [_servicio],
  'proximo': {
    'servicioId': 3,
    'nombre': 'Servicio de 10,000 km',
    'kmObjetivo': 10000,
    'fechaEstimada': '2026-12-16',
    'faltanKm': 1000,
    'faltanDias': 26,
    'motivo': 'km',
  },
};

void main() {
  group('PlanMantenimientoDto', () {
    test('lee el plan completo del contrato', () {
      final plan = PlanMantenimientoDto.fromJson(_plan);

      expect(plan.vehiculoId, 5);
      expect(plan.kmActual, 9000);
      expect(plan.kmActualizadoEn, DateTime(2026, 11, 20));
      expect(plan.kmFuente, 'cliente');
      expect(plan.promedioKmDiario, 38.5);
      expect(plan.servicios.single.nombre, 'Servicio de 10,000 km');
      expect(plan.servicios.single.precioEstimado, 1850.0);
      expect(plan.servicios.single.conceptos, hasLength(2));
      expect(plan.servicios.single.hechoEn, isNull);
      expect(plan.proximo!.faltanKm, 1000);
      expect(plan.proximo!.fechaEstimada, DateTime(2026, 12, 16));
      expect(plan.proximo!.motivo, 'km');
    });

    test('sin plan para el modelo: servicios vacíos y sin próximo', () {
      final plan = PlanMantenimientoDto.fromJson(const {
        'vehiculoId': 5,
        'kmActual': null,
        'kmActualizadoEn': null,
        'kmFuente': null,
        'promedioKmDiario': null,
        'servicios': [],
        'proximo': null,
      });

      expect(plan.servicios, isEmpty);
      expect(plan.proximo, isNull);
      expect(plan.kmActual, isNull);
      expect(plan.kmFuente, isNull);
    });

    test('los campos opcionales pueden faltar del todo', () {
      final plan = PlanMantenimientoDto.fromJson(const {
        'vehiculoId': 5,
        'servicios': [],
      });

      expect(plan.kmActual, isNull);
      expect(plan.promedioKmDiario, isNull);
      expect(plan.proximo, isNull);
    });

    test('un servicio hecho trae la fecha en que se hizo', () {
      final s = ServicioMantenimientoDto.fromJson({
        ..._servicio,
        'estado': 'hecho',
        'hechoEn': '2026-05-02',
      });

      expect(s.estado, 'hecho');
      expect(s.hechoEn, DateTime(2026, 5, 2));
    });

    test('un campo obligatorio con tipo equivocado falla con claridad', () {
      expect(
        () => ServicioMantenimientoDto.fromJson({..._servicio, 'km': 'diez'}),
        throwsFormatException,
      );
      expect(
        () => PlanMantenimientoDto.fromJson({..._plan, 'servicios': 'x'}),
        throwsFormatException,
      );
    });
  });

  group('LecturaKmDto', () {
    test('lee la lectura que devuelve el POST', () {
      final l = LecturaKmDto.fromJson(const {
        'id': 9,
        'km': 12400,
        'fuente': 'cliente',
        'registradaEn': '2026-11-23T10:15:00',
      });

      expect(l.id, 9);
      expect(l.km, 12400);
      expect(l.fuente, 'cliente');
      expect(l.registradaEn, DateTime(2026, 11, 23, 10, 15));
    });
  });
}
