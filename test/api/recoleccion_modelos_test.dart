import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

const _cita = <String, Object?>{
  'id': 9,
  'vehiculoId': 1,
  'franjaId': 4,
  'fecha': '2026-11-26',
  'horaInicio': '09:00',
  'horaFin': '10:00',
  'estado': 'CONFIRMADA',
};

void main() {
  group('NuevaCita con recoleccion (V2-M17.02)', () {
    test('manda recoleccion.direccionId cuando se pidió', () {
      final json = NuevaCita(
        vehiculoId: 1,
        franjaId: 4,
        fecha: DateTime(2026, 11, 26),
        recoleccionDireccionId: 7,
      ).toJson();
      expect(json['recoleccion'], {'direccionId': 7});
    });

    test('sin recolección omite la clave', () {
      final json = NuevaCita(
        vehiculoId: 1,
        franjaId: 4,
        fecha: DateTime(2026, 11, 26),
      ).toJson();
      expect(json.containsKey('recoleccion'), isFalse);
    });
  });

  group('Cita.recoleccion', () {
    test('es nula cuando el servidor no la manda o manda null', () {
      expect(Cita.fromJson(_cita).recoleccion, isNull);
      expect(Cita.fromJson({..._cita, 'recoleccion': null}).recoleccion, isNull);
    });

    test('lee los traslados de recoger y entregar', () {
      final cita = Cita.fromJson({
        ..._cita,
        'recoleccion': {
          'direccionId': 7,
          'costoTotal': 300.0,
          'traslados': [
            {
              'id': 1,
              'tipo': 'recoger',
              'estado': 'programado',
              'costo': 150,
              'fecha': '2026-11-26',
              'ventanaInicio': '07:00',
              'ventanaFin': '09:00',
            },
            {
              'id': 2,
              'tipo': 'entregar',
              'estado': 'programado',
              'costo': 150.0,
              'fecha': '2026-11-26',
              'ventanaInicio': '17:00',
              'ventanaFin': '19:00',
            },
          ],
        },
      });
      final r = cita.recoleccion!;
      expect(r.direccionId, 7);
      expect(r.costoTotal, 300);
      expect(r.traslados.map((t) => t.tipo), ['recoger', 'entregar']);
      expect(r.traslados.first.costo, 150);
      expect(r.traslados.first.ventanaFin, '09:00');
      expect(r.traslados.last.fecha, DateTime(2026, 11, 26));
    });
  });
}
