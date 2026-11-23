import 'package:carecar_mobile/modulos/citas/dominio/cita_cliente.dart';
import 'package:flutter_test/flutter_test.dart';

CitaCliente _cita({
  EstadoDeCita estado = EstadoDeCita.confirmada,
  DateTime? fecha,
  String horaInicio = '09:00',
}) => CitaCliente(
  id: 1,
  vehiculoId: 2,
  fecha: fecha ?? DateTime(2026, 11, 25),
  horaInicio: horaInicio,
  horaFin: '10:00',
  estado: estado,
);

void main() {
  final ahora = DateTime(2026, 11, 23, 12);

  group('inicio', () {
    test('une la fecha con la hora de inicio', () {
      expect(_cita(horaInicio: '15:30').inicio, DateTime(2026, 11, 25, 15, 30));
    });

    test('una hora ilegible se toma como inicio del dia', () {
      expect(_cita(horaInicio: 'tarde').inicio, DateTime(2026, 11, 25));
    });
  });

  group('esProxima y sePuedeModificar', () {
    test('confirmada y en el futuro es proxima y se puede modificar', () {
      final c = _cita();
      expect(c.esProxima(ahora), isTrue);
      expect(c.sePuedeModificar(ahora), isTrue);
    });

    test('confirmada que ya paso es pasada y no se puede modificar', () {
      final c = _cita(fecha: DateTime(2026, 11, 20));
      expect(c.esProxima(ahora), isFalse);
      expect(c.sePuedeModificar(ahora), isFalse);
    });

    test('confirmada de hoy a una hora que ya paso es pasada', () {
      final c = _cita(fecha: DateTime(2026, 11, 23), horaInicio: '09:00');
      expect(c.esProxima(ahora), isFalse);
    });

    test('confirmada de hoy a una hora que falta es proxima', () {
      final c = _cita(fecha: DateTime(2026, 11, 23), horaInicio: '15:00');
      expect(c.esProxima(ahora), isTrue);
    });

    for (final estado in [
      EstadoDeCita.atendida,
      EstadoDeCita.noAsistio,
      EstadoDeCita.cancelada,
      EstadoDeCita.desconocido,
    ]) {
      test('$estado futura no es proxima ni se puede modificar', () {
        final c = _cita(estado: estado);
        expect(c.esProxima(ahora), isFalse);
        expect(c.sePuedeModificar(ahora), isFalse);
      });
    }
  });

  group('PaginaDeCitas', () {
    test('hayMas es verdadero mientras queden paginas', () {
      expect(
        const PaginaDeCitas(citas: [], pagina: 0, totalPaginas: 2).hayMas,
        isTrue,
      );
      expect(
        const PaginaDeCitas(citas: [], pagina: 1, totalPaginas: 2).hayMas,
        isFalse,
      );
    });
  });
}
