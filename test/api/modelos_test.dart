import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RespuestaLogin', () {
    test('lee el token y la bandera de contrasena temporal', () {
      final r = RespuestaLogin.fromJson({
        'accessToken': 'abc.def.ghi',
        'debeCambiarContrasena': true,
      });
      expect(r.accessToken, 'abc.def.ghi');
      expect(r.debeCambiarContrasena, isTrue);
    });
  });

  group('PeticionLogin', () {
    test('usa las claves del contrato, sin acentos', () {
      const p = PeticionLogin(usuario: 'cliente1', contrasena: 'CareCar2026');
      expect(p.toJson(), {'usuario': 'cliente1', 'contrasena': 'CareCar2026'});
    });
  });

  group('Vehiculo', () {
    test('lee un vehiculo completo', () {
      final v = Vehiculo.fromJson({
        'id': 1,
        'vin': '3N1CN7AD5ML000111',
        'modelo': 'Versa',
        'anio': 2024,
        'placas': 'ABC-12-34',
        'kilometraje': 18450,
      });
      expect(v.id, 1);
      expect(v.vin, '3N1CN7AD5ML000111');
      expect(v.modelo, 'Versa');
      expect(v.anio, 2024);
      expect(v.placas, 'ABC-12-34');
      expect(v.kilometraje, 18450);
    });

    test(
      'acepta placas y kilometraje nulos, que el contrato marca opcionales',
      () {
        final v = Vehiculo.fromJson({
          'id': 2,
          'vin': '3N1CP5CD8ML000222',
          'modelo': 'Kicks',
          'anio': 2023,
          'placas': null,
          'kilometraje': null,
        });
        expect(v.placas, isNull);
        expect(v.kilometraje, isNull);
      },
    );

    test('acepta que las claves opcionales ni vengan', () {
      final v = Vehiculo.fromJson({
        'id': 3,
        'vin': 'MAJ6S3KL9NC000333',
        'modelo': 'Sentra',
        'anio': 2025,
      });
      expect(v.placas, isNull);
      expect(v.kilometraje, isNull);
    });
  });

  group('Servicio', () {
    test('lee la fecha, el estatus y el total', () {
      final s = Servicio.fromJson({
        'id': 1,
        'fecha': '2026-09-18',
        'estatus': 'Terminado',
        'total': 4850.5,
      });
      expect(s.id, 1);
      expect(s.fecha, DateTime(2026, 9, 18));
      expect(s.estatus, 'Terminado');
      expect(s.total, 4850.5);
    });

    test('acepta un total entero, porque JSON no distingue 980 de 980.0', () {
      final s = Servicio.fromJson({
        'id': 5,
        'fecha': '2026-10-02',
        'estatus': 'Terminado',
        'total': 980,
      });
      expect(s.total, 980.0);
    });
  });

  group('Manual', () {
    test('lee el enlace del PDF', () {
      final m = Manual.fromJson({
        'id': 1,
        'modelo': 'Versa',
        'anio': 2024,
        'url': 'http://localhost:3000/manual.pdf',
      });
      expect(m.url, 'http://localhost:3000/manual.pdf');
    });
  });

  group('Disponibilidad', () {
    test('lee la franja con su cupo', () {
      final d = Disponibilidad.fromJson({
        'fecha': '2026-10-20',
        'franjaId': 1,
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'cupoDisponible': 2,
      });
      expect(d.fecha, DateTime(2026, 10, 20));
      expect(d.franjaId, 1);
      expect(d.horaInicio, '09:00');
      expect(d.horaFin, '10:00');
      expect(d.cupoDisponible, 2);
    });
  });

  group('NuevaCita', () {
    test('serializa la fecha en ISO 8601, solo la parte de fecha', () {
      final n = NuevaCita(
        vehiculoId: 1,
        franjaId: 6,
        fecha: DateTime(2026, 10, 22),
      );
      expect(n.toJson(), {
        'vehiculoId': 1,
        'franjaId': 6,
        'fecha': '2026-10-22',
      });
    });

    test('rellena con cero el mes y el dia de un digito', () {
      final n = NuevaCita(
        vehiculoId: 1,
        franjaId: 2,
        fecha: DateTime(2026, 1, 5),
      );
      expect(n.toJson()['fecha'], '2026-01-05');
    });
  });

  group('Cita', () {
    test('lee los cuatro estados del contrato', () {
      for (final par in {
        'CONFIRMADA': EstadoCita.confirmada,
        'ATENDIDA': EstadoCita.atendida,
        'NO_ASISTIO': EstadoCita.noAsistio,
        'CANCELADA': EstadoCita.cancelada,
      }.entries) {
        final c = Cita.fromJson({
          'id': 1,
          'vehiculoId': 1,
          'fecha': '2026-10-21',
          'horaInicio': '09:00',
          'horaFin': '10:00',
          'estado': par.key,
        });
        expect(c.estado, par.value, reason: 'estado ${par.key}');
      }
    });

    test('un estado desconocido no tumba la app: cae en desconocido', () {
      final c = Cita.fromJson({
        'id': 1,
        'vehiculoId': 1,
        'fecha': '2026-10-21',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'REAGENDADA',
      });
      expect(c.estado, EstadoCita.desconocido);
    });
  });

  group('ModeloCatalogo', () {
    test('lee el modelo', () {
      final m = ModeloCatalogo.fromJson({'id': 1, 'modelo': 'Versa'});
      expect(m.modelo, 'Versa');
    });
  });

  group('Problema', () {
    test('lee el formato de error del backend', () {
      final p = Problema.fromJson({
        'timestamp': '2026-10-13T19:51:05.258Z',
        'status': 409,
        'error': 'Conflict',
        'message': 'La franja ya no tiene cupo',
        'path': '/api/v1/app/citas',
      });
      expect(p.status, 409);
      expect(p.message, 'La franja ya no tiene cupo');
      expect(p.path, '/api/v1/app/citas');
    });

    test('sobrevive a un cuerpo de error incompleto', () {
      final p = Problema.fromJson({'status': 500});
      expect(p.status, 500);
      expect(p.message, isNotEmpty);
    });
  });
}
