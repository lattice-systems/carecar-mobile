import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _json([Map<String, Object?> cambios = const {}]) => {
  'id': 4,
  'tipo': 'ACCESO',
  'estado': 'PENDIENTE',
  'creadaEn': '2026-11-25T18:30:00Z',
  ...cambios,
};

void main() {
  group('SolicitudArco (V2-M22.02)', () {
    test('lee una solicitud pendiente', () {
      final s = SolicitudArco.fromJson(_json());
      expect(s.id, 4);
      expect(s.tipo, 'ACCESO');
      expect(s.estado, 'PENDIENTE');
      expect(s.creadaEn, DateTime.utc(2026, 11, 25, 18, 30));
      expect(s.resueltaEn, isNull);
      expect(s.venceEn, isNull);
    });

    test('lee cuando se resolvio y hasta cuando se puede descargar', () {
      final s = SolicitudArco.fromJson(
        _json({
          'estado': 'RESUELTA',
          'resueltaEn': '2026-11-25T18:30:02Z',
          'venceEn': '2026-12-02T18:30:02Z',
        }),
      );
      expect(s.estado, 'RESUELTA');
      expect(s.resueltaEn, DateTime.utc(2026, 11, 25, 18, 30, 2));
      expect(s.venceEn, DateTime.utc(2026, 12, 2, 18, 30, 2));
    });

    test('resueltaEn y venceEn nulos son lo mismo que no venir', () {
      final s = SolicitudArco.fromJson(
        _json({'resueltaEn': null, 'venceEn': null}),
      );
      expect(s.resueltaEn, isNull);
      expect(s.venceEn, isNull);
    });

    for (final campo in ['id', 'tipo', 'estado', 'creadaEn']) {
      test('sin «$campo» no respeta el contrato', () {
        final json = _json()..remove(campo);
        expect(
          () => SolicitudArco.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('una fecha rota falla, no se inventa una', () {
      expect(
        () => SolicitudArco.fromJson(_json({'creadaEn': 'ayer'})),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SolicitudArco.fromJson(_json({'venceEn': 'pronto'})),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
