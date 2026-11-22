import 'package:carecar_mobile/modulos/citas/dominio/disponibilidad_taller.dart';
import 'package:flutter_test/flutter_test.dart';

FranjaDisponible _franja(int id, DateTime fecha, String inicio, int cupo) =>
    FranjaDisponible(
      franjaId: id,
      fecha: fecha,
      horaInicio: inicio,
      horaFin: '10:00',
      cupo: cupo,
    );

void main() {
  final lunes = DateTime(2026, 11, 23);
  final martes = DateTime(2026, 11, 24);

  group('DisponibilidadTaller', () {
    final taller = DisponibilidadTaller([
      _franja(2, lunes, '11:00', 1),
      _franja(1, lunes, '09:00', 3),
      _franja(3, martes, '09:00', 0),
    ]);

    test('un dia con franjas con cupo esta disponible', () {
      expect(taller.tieneCupo(lunes), isTrue);
    });

    test('un dia sin franjas o sin cupo no esta disponible', () {
      expect(taller.tieneCupo(martes), isFalse);
      expect(taller.tieneCupo(DateTime(2026, 11, 25)), isFalse);
    });

    test('ignora la hora al comparar el dia', () {
      expect(taller.tieneCupo(DateTime(2026, 11, 23, 18, 30)), isTrue);
    });

    test('las franjas de un dia salen ordenadas por hora y con cupo', () {
      final franjas = taller.franjasDe(lunes);
      expect(franjas.map((f) => f.franjaId), [1, 2]);
      expect(taller.franjasDe(martes), isEmpty);
    });

    test('sin franjas ningun dia tiene cupo', () {
      expect(DisponibilidadTaller(const []).tieneCupo(lunes), isFalse);
    });
  });

  group('franjas cercanas', () {
    final taller = DisponibilidadTaller([
      _franja(1, lunes, '09:00', 2),
      _franja(2, lunes, '11:00', 1),
      _franja(3, lunes, '15:00', 1),
      _franja(4, martes, '09:00', 4),
      _franja(5, DateTime(2026, 11, 30), '09:00', 4),
    ]);

    test('ofrece primero las del mismo dia, por cercania de hora', () {
      final cercanas = taller.cercanas(
        _franja(2, lunes, '11:00', 0),
        maximo: 2,
      );
      expect(cercanas.map((f) => f.franjaId), [1, 3]);
    });

    test('completa con otros dias, del mas cercano al mas lejano', () {
      final cercanas = taller.cercanas(_franja(2, lunes, '11:00', 0));
      expect(cercanas.map((f) => f.franjaId), [1, 3, 4]);
    });

    test('nunca ofrece la franja que se quedo sin cupo', () {
      final cercanas = taller.cercanas(_franja(1, lunes, '09:00', 0));
      expect(cercanas.any((f) => f.franjaId == 1), isFalse);
    });
  });
}
