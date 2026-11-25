import 'package:carecar_mobile/config/agencia.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M22.10: el aviso que trae la app (lo muestra la pantalla de perfil v1)
/// debe decir quién recibe datos, igual que la versión 2 del backend.
void main() {
  group('Agencia.avisoPrivacidad', () {
    test('nombra a los proveedores externos que reciben datos', () {
      for (final nombre in [
        'Microsoft Azure',
        'Neon',
        'OpenStreetMap',
        'Gemini',
      ]) {
        expect(
          Agencia.avisoPrivacidad,
          contains(nombre),
          reason: 'el aviso no menciona a $nombre',
        );
      }
    });

    test('ya no dice que solo las autoridades reciben datos', () {
      expect(
        Agencia.avisoPrivacidad,
        isNot(contains('Transferencias: solo compartimos tus datos con')),
      );
      expect(Agencia.avisoPrivacidad, contains('fuera de estos proveedores'));
    });

    test('conserva los derechos ARCO', () {
      expect(Agencia.avisoPrivacidad, contains('Derechos ARCO'));
    });
  });
}
