import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _avisoJson([Map<String, Object?> cambios = const {}]) => {
  'id': 3,
  'version': 2,
  'texto': 'Primer párrafo.\n\nSegundo párrafo.',
  'vigenteDesde': '2026-11-25T18:30:00Z',
  'aceptado': false,
  ...cambios,
};

void main() {
  group('AvisoPrivacidad (V2-M22.01)', () {
    test('lee un aviso sin aceptar', () {
      final a = AvisoPrivacidad.fromJson(_avisoJson());
      expect(a.id, 3);
      expect(a.version, 2);
      expect(a.texto, 'Primer párrafo.\n\nSegundo párrafo.');
      expect(a.vigenteDesde, DateTime.utc(2026, 11, 25, 18, 30));
      expect(a.aceptado, isFalse);
      expect(a.aceptadoEn, isNull);
    });

    test('lee cuando y si ya lo acepto', () {
      final a = AvisoPrivacidad.fromJson(
        _avisoJson({'aceptado': true, 'aceptadoEn': '2026-11-26T09:00:00Z'}),
      );
      expect(a.aceptado, isTrue);
      expect(a.aceptadoEn, DateTime.utc(2026, 11, 26, 9));
    });

    test(
      'una fecha sin zona se toma como UTC, que es lo que declara el contrato',
      () {
        final a = AvisoPrivacidad.fromJson(
          _avisoJson({'vigenteDesde': '2026-11-25T18:30:00'}),
        );
        expect(a.vigenteDesde, DateTime.utc(2026, 11, 25, 18, 30));
        expect(a.vigenteDesde.isUtc, isTrue);
      },
    );

    test('un aceptadoEn nulo es lo mismo que no venir', () {
      final a = AvisoPrivacidad.fromJson(_avisoJson({'aceptadoEn': null}));
      expect(a.aceptadoEn, isNull);
    });

    for (final campo in [
      'id',
      'version',
      'texto',
      'vigenteDesde',
      'aceptado',
    ]) {
      test('sin «$campo» no respeta el contrato', () {
        final json = _avisoJson()..remove(campo);
        expect(
          () => AvisoPrivacidad.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('«aceptado» que no es booleano falla, no se adivina', () {
      expect(
        () => AvisoPrivacidad.fromJson(_avisoJson({'aceptado': 'si'})),
        throwsA(isA<FormatException>()),
      );
    });

    test('una fecha rota falla, no se inventa una', () {
      expect(
        () => AvisoPrivacidad.fromJson(_avisoJson({'vigenteDesde': 'ayer'})),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => AvisoPrivacidad.fromJson(
          _avisoJson({'aceptado': true, 'aceptadoEn': 'ayer'}),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AceptacionAviso (V2-M22.01)', () {
    test('lee el aviso, su version y cuando se registro', () {
      final a = AceptacionAviso.fromJson({
        'avisoId': 3,
        'version': 2,
        'aceptadoEn': '2026-11-26T09:00:00Z',
      });
      expect(a.avisoId, 3);
      expect(a.version, 2);
      expect(a.aceptadoEn, DateTime.utc(2026, 11, 26, 9));
    });

    for (final campo in ['avisoId', 'version', 'aceptadoEn']) {
      test('sin «$campo» no respeta el contrato', () {
        final json = <String, Object?>{
          'avisoId': 3,
          'version': 2,
          'aceptadoEn': '2026-11-26T09:00:00Z',
        }..remove(campo);
        expect(
          () => AceptacionAviso.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    }
  });
}
