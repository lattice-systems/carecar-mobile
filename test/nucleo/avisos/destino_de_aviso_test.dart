import 'package:carecar_mobile/nucleo/avisos/destino_de_aviso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.03 · a dónde lleva tocar un aviso.
///
/// El destino viaja **dentro** del aviso, así que entra a la app desde afuera
/// y hay que tratarlo como lo que es: un dato de fuera. Lo que se prueba aquí
/// es que solo se acepte una ruta interna, y que el destino se entregue una
/// sola vez (si no, cada reconstrucción volvería a navegar).
void main() {
  group('el destino que trae un aviso', () {
    test('una ruta interna se acepta tal cual', () {
      expect(destinoDeAviso('/citas'), '/citas');
      expect(destinoDeAviso('/citas/7/comprobante'), '/citas/7/comprobante');
      expect(destinoDeAviso('/citas?vehiculo=2'), '/citas?vehiculo=2');
    });

    test('sin destino no se navega', () {
      expect(destinoDeAviso(null), isNull);
      expect(destinoDeAviso(''), isNull);
      expect(destinoDeAviso('   '), isNull);
    });

    test('nada que salga de la app: el aviso no manda a internet', () {
      expect(destinoDeAviso('https://example.com'), isNull);
      expect(destinoDeAviso('carecar://citas'), isNull);
      // `//host` lo lee el navegador como otro servidor.
      expect(destinoDeAviso('//example.com/citas'), isNull);
      expect(destinoDeAviso('citas'), isNull);
    });
  });

  group('el destino pendiente', () {
    ProviderContainer contenedor() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('nace vacío: nadie ha tocado nada', () {
      expect(contenedor().read(destinoDeAvisoProvider), isNull);
    });

    test('un toque deja el destino listo para el enrutador', () {
      final c = contenedor();

      c.read(destinoDeAvisoProvider.notifier).llego('/citas');

      expect(c.read(destinoDeAvisoProvider), '/citas');
    });

    test('un destino inválido no pisa lo que había', () {
      final c = contenedor();
      c.read(destinoDeAvisoProvider.notifier).llego('/citas');

      c.read(destinoDeAvisoProvider.notifier).llego('https://example.com');

      expect(c.read(destinoDeAvisoProvider), '/citas');
    });

    test('atenderlo lo vacía: no se navega dos veces', () {
      final c = contenedor();
      c.read(destinoDeAvisoProvider.notifier).llego('/citas');

      c.read(destinoDeAvisoProvider.notifier).atendido();

      expect(c.read(destinoDeAvisoProvider), isNull);
    });
  });
}
