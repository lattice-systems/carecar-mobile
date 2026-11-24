import 'package:carecar_mobile/modulos/asistencia/dominio/solicitud_asistencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipoAsistencia', () {
    test('usa los nombres del contrato', () {
      expect(TipoAsistencia.values.map((t) => t.enElContrato), [
        'llanta',
        'bateria',
        'choque',
        'sin_gasolina',
        'otro',
      ]);
    });

    test('desde reconoce cada valor y rechaza lo desconocido', () {
      for (final t in TipoAsistencia.values) {
        expect(TipoAsistencia.desde(t.enElContrato), t);
      }
      expect(TipoAsistencia.desde('grua'), isNull);
      expect(TipoAsistencia.desde(null), isNull);
    });
  });

  group('SolicitudAsistencia.desdeJson', () {
    test('lee todos los campos', () {
      final s = SolicitudAsistencia.desdeJson(const {
        'id': 7,
        'vehiculoId': 3,
        'tipo': 'sin_gasolina',
        'lat': 19.43,
        'lng': -99.13,
        'comentario': 'Frente al parque',
        'estado': 'recibida',
        'creadaEn': '2026-11-23T15:00:00Z',
      });
      expect(s.id, 7);
      expect(s.vehiculoId, 3);
      expect(s.tipo, TipoAsistencia.sinGasolina);
      expect(s.ubicacion?.latitud, 19.43);
      expect(s.ubicacion?.longitud, -99.13);
      expect(s.comentario, 'Frente al parque');
      expect(s.estado, EstadoSolicitud.recibida);
      expect(s.creadaEn, DateTime.utc(2026, 11, 23, 15));
    });

    test('sin ubicacion ni comentario quedan nulos', () {
      final s = SolicitudAsistencia.desdeJson(const {
        'id': 1,
        'vehiculoId': 2,
        'tipo': 'otro',
        'lat': null,
        'lng': null,
        'comentario': null,
        'estado': 'en_camino',
        'creadaEn': '2026-11-23T15:00:00Z',
      });
      expect(s.ubicacion, isNull);
      expect(s.comentario, isNull);
      expect(s.estado, EstadoSolicitud.enCamino);
    });

    test('un tipo fuera del contrato es FormatException', () {
      expect(
        () => SolicitudAsistencia.desdeJson(const {
          'id': 1,
          'vehiculoId': 2,
          'tipo': 'grua',
          'estado': 'recibida',
          'creadaEn': '2026-11-23T15:00:00Z',
        }),
        throwsFormatException,
      );
    });

    test('un estado nuevo no rompe: se trata como recibida', () {
      final s = SolicitudAsistencia.desdeJson(const {
        'id': 1,
        'vehiculoId': 2,
        'tipo': 'otro',
        'estado': 'reasignada',
        'creadaEn': '2026-11-23T15:00:00Z',
      });
      expect(s.estado, EstadoSolicitud.recibida);
    });

    test('solo recibida y en_camino estan abiertas', () {
      expect(EstadoSolicitud.recibida.abierta, isTrue);
      expect(EstadoSolicitud.enCamino.abierta, isTrue);
      expect(EstadoSolicitud.atendida.abierta, isFalse);
      expect(EstadoSolicitud.cancelada.abierta, isFalse);
    });
  });
}
