import 'package:carecar_mobile/modulos/ayuda/dominio/enlaces_sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/tramos_de_dias.dart';
import 'package:flutter_test/flutter_test.dart';

Sucursal _sucursal({String? telefono = '+52 477 000 0000'}) => Sucursal(
  id: 1,
  nombre: 'CareCar León',
  direccion: 'Blvd. Ejemplo 100, León, Gto.',
  latitud: 21.125,
  longitud: -101.686,
  telefono: telefono,
  abiertaAhora: true,
  horarios: const [
    HorarioDeDepartamento(
      departamento: Departamento.refacciones,
      dias: [1, 2, 3, 4, 5],
      abre: '09:00',
      cierra: '17:00',
      abiertoAhora: false,
    ),
    HorarioDeDepartamento(
      departamento: Departamento.servicio,
      dias: [6],
      abre: '08:00',
      cierra: '14:00',
      abiertoAhora: false,
    ),
    HorarioDeDepartamento(
      departamento: Departamento.servicio,
      dias: [1, 2, 3, 4, 5],
      abre: '08:00',
      cierra: '18:00',
      abiertoAhora: true,
    ),
  ],
);

void main() {
  group('tramosDeDias', () {
    test('junta los días seguidos en un tramo', () {
      expect(tramosDeDias([1, 2, 3, 4, 5]), [(desde: 1, hasta: 5)]);
    });

    test('separa lo que no es seguido y lo ordena', () {
      expect(tramosDeDias([6, 1, 2, 4]), [
        (desde: 1, hasta: 2),
        (desde: 4, hasta: 4),
        (desde: 6, hasta: 6),
      ]);
    });

    test('ignora repetidos y días fuera de uno a siete', () {
      expect(tramosDeDias([3, 3, 0, 9]), [(desde: 3, hasta: 3)]);
    });

    test('una lista vacía no tiene tramos', () {
      expect(tramosDeDias(const []), isEmpty);
    });
  });

  group('Sucursal', () {
    test('agrupa los horarios por departamento en el orden de la agencia', () {
      final grupos = _sucursal().horariosPorDepartamento;

      expect(grupos.map((g) => g.departamento), [
        Departamento.servicio,
        Departamento.refacciones,
      ]);
      expect(grupos.first.tramos, hasLength(2));
    });

    test('un departamento está abierto si alguno de sus tramos lo está', () {
      final servicio = _sucursal().horariosPorDepartamento.first;

      expect(servicio.abiertoAhora, isTrue);
      expect(_sucursal().horariosPorDepartamento.last.abiertoAhora, isFalse);
    });
  });

  group('enlaces', () {
    test('llamar deja solo el signo más y los dígitos', () {
      expect(enlaceDeLlamada(_sucursal())!.toString(), 'tel:+524770000000');
    });

    test('sin teléfono no hay enlace de llamada', () {
      expect(enlaceDeLlamada(_sucursal(telefono: null)), isNull);
    });

    test('cómo llegar en Android abre la app de mapas con geo:', () {
      final enlace = enlaceComoLlegar(_sucursal(), apple: false);

      expect(enlace.scheme, 'geo');
      expect(enlace.toString(), contains('21.125,-101.686'));
    });

    test('cómo llegar en iPhone abre Mapas de Apple con la ruta', () {
      final enlace = enlaceComoLlegar(_sucursal(), apple: true);

      expect(enlace.host, 'maps.apple.com');
      expect(enlace.queryParameters['daddr'], '21.125,-101.686');
    });
  });
}
