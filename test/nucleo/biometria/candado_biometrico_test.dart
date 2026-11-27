import 'package:carecar_mobile/nucleo/biometria/candado_biometrico.dart';
import 'package:carecar_mobile/nucleo/biometria/lector_biometrico.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V2-M01.05 · el candado de huella o rostro.
///
/// Dos criterios se deciden aquí: que sea **opt-in** —apagado mientras nadie
/// lo prenda— y que **un cambio de biometría pida la contraseña**.
void main() {
  Future<ProviderContainer> contenedor(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [preferenciasProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('el candado', () {
    test('nace apagado: nadie lo prendió', () async {
      final c = await contenedor({});
      expect(c.read(candadoProvider), EstadoCandado.apagado);
      expect(c.read(candadoPorAbrirProvider), isFalse);
    });

    test('prenderlo guarda la firma y deja la app abierta', () async {
      final c = await contenedor({});

      await c.read(candadoProvider.notifier).prender('fingerprint');

      // Abierto y no por abrir: acaba de identificarse para prenderlo.
      expect(c.read(candadoProvider), EstadoCandado.abierto);
      expect(c.read(candadoProvider.notifier).firmaGuardada, 'fingerprint');
    });

    test('prendido, al reabrir la app está por abrir', () async {
      final c = await contenedor({
        claveCandadoActivo: true,
        claveCandadoFirma: 'fingerprint',
      });
      expect(c.read(candadoPorAbrirProvider), isTrue);
    });

    test('apagarlo olvida la firma', () async {
      final c = await contenedor({
        claveCandadoActivo: true,
        claveCandadoFirma: 'fingerprint',
      });

      await c.read(candadoProvider.notifier).apagar();

      expect(c.read(candadoProvider), EstadoCandado.apagado);
      expect(c.read(candadoProvider.notifier).firmaGuardada, isNull);
    });
  });

  group('si cambia la biometría del equipo', () {
    test('la misma firma no pide nada', () {
      expect(
        biometriaCambio(guardada: 'fingerprint', ahora: 'fingerprint'),
        isFalse,
      );
    });

    test('otra firma cuenta como cambio', () {
      expect(biometriaCambio(guardada: 'fingerprint', ahora: 'face'), isTrue);
      expect(biometriaCambio(guardada: 'fingerprint', ahora: ''), isTrue);
    });

    test('sin firma guardada se pide la contraseña, por el lado seguro', () {
      expect(biometriaCambio(guardada: null, ahora: 'fingerprint'), isTrue);
      expect(biometriaCambio(guardada: '', ahora: 'fingerprint'), isTrue);
    });
  });
}
