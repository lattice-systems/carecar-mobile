import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

ServicioMantenimiento _servicio(
  int id, {
  EstadoServicio estado = EstadoServicio.pendiente,
}) => ServicioMantenimiento(
  id: id,
  nombre: 'Servicio $id',
  km: id * 5000,
  meses: id * 6,
  precioEstimado: 1500,
  conceptos: const ['Aceite'],
  estado: estado,
);

void main() {
  group('EstadoServicio', () {
    test('lee los cuatro estados del contrato', () {
      expect(EstadoServicio.desde('hecho'), EstadoServicio.hecho);
      expect(EstadoServicio.desde('pendiente'), EstadoServicio.pendiente);
      expect(EstadoServicio.desde('proximo'), EstadoServicio.proximo);
      expect(EstadoServicio.desde('vencido'), EstadoServicio.vencido);
    });

    test('un estado que la app no conoce se trata como pendiente', () {
      expect(EstadoServicio.desde('nuevo'), EstadoServicio.pendiente);
    });
  });

  group('MotivoProximo y FuenteKm', () {
    test('leen sus códigos y toleran lo desconocido', () {
      expect(MotivoProximo.desde('km'), MotivoProximo.km);
      expect(MotivoProximo.desde('tiempo'), MotivoProximo.tiempo);
      expect(MotivoProximo.desde('otro'), MotivoProximo.km);
      expect(FuenteKm.desde('taller'), FuenteKm.taller);
      expect(FuenteKm.desde('cliente'), FuenteKm.cliente);
      expect(FuenteKm.desde(null), isNull);
      expect(FuenteKm.desde('x'), isNull);
    });
  });

  group('ProximoServicio', () {
    ProximoServicio proximo({int faltanKm = 500, int faltanDias = 20}) =>
        ProximoServicio(
          servicioId: 2,
          nombre: 'Servicio 2',
          kmObjetivo: 10000,
          fechaEstimada: DateTime(2026, 12, 1),
          faltanKm: faltanKm,
          faltanDias: faltanDias,
          motivo: MotivoProximo.km,
        );

    test('todavía no toca cuando falta km y tiempo', () {
      expect(proximo().yaToca, isFalse);
    });

    test('ya toca cuando no falta km o no faltan días', () {
      expect(proximo(faltanKm: 0).yaToca, isTrue);
      expect(proximo(faltanKm: -80).yaToca, isTrue);
      expect(proximo(faltanDias: 0).yaToca, isTrue);
    });
  });

  group('PlanMantenimiento', () {
    PlanMantenimiento plan(List<ServicioMantenimiento> servicios) =>
        PlanMantenimiento(vehiculoId: 5, servicios: servicios);

    test('sin servicios no hay plan para el modelo', () {
      expect(plan(const []).sinPlan, isTrue);
      expect(plan([_servicio(1)]).sinPlan, isFalse);
    });

    test('encuentra un servicio por id o devuelve nulo', () {
      final p = plan([_servicio(1), _servicio(2)]);
      expect(p.servicioPorId(2)!.nombre, 'Servicio 2');
      expect(p.servicioPorId(9), isNull);
    });

    test('cuenta los hechos', () {
      final p = plan([
        _servicio(1, estado: EstadoServicio.hecho),
        _servicio(2, estado: EstadoServicio.hecho),
        _servicio(3, estado: EstadoServicio.proximo),
      ]);
      expect(p.hechos, 2);
    });
  });

  group('ServicioMantenimiento', () {
    test('solo los hechos no se pueden agendar', () {
      expect(_servicio(1).sePuedeAgendar, isTrue);
      expect(
        _servicio(1, estado: EstadoServicio.vencido).sePuedeAgendar,
        isTrue,
      );
      expect(
        _servicio(1, estado: EstadoServicio.hecho).sePuedeAgendar,
        isFalse,
      );
    });
  });
}
