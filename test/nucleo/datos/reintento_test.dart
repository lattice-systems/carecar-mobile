import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/nucleo/datos/reintento.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/fallos_de_prueba.dart';

/// V2-T01.08 · la politica de reintento del nucleo.
///
/// Riverpod 3 reintenta **solo** cualquier proveedor que falle: hasta 10 veces,
/// con espera que dobla de 200 ms a 6.4 s, y solo se salta los `Error`
/// (`ProviderContainer.defaultRetry`). Como todos nuestros fallos son
/// `Exception`, sin esta politica un 404 se pide once veces para recibir once
/// veces lo mismo.
void main() {
  group('no insiste con lo que no va a cambiar', () {
    test('un 404 no se reintenta', () {
      expect(reintentoDelNucleo(0, Fallos.noEncontrado()), isNull);
    });

    test('un 400 de validacion no se reintenta', () {
      expect(reintentoDelNucleo(0, Fallos.validacion()), isNull);
    });

    test('un 409 no se reintenta', () {
      expect(
        reintentoDelNucleo(0, Fallos.conflicto(CodigoProblema.franjaSinCupo)),
        isNull,
      );
    });

    test('una sesion terminada no se reintenta: se vuelve a entrar', () {
      expect(reintentoDelNucleo(0, Fallos.sesionTerminada()), isNull);
      expect(reintentoDelNucleo(0, Fallos.cuentaDesactivada()), isNull);
    });

    test('un 429 no se reintenta: insistir alarga el bloqueo', () {
      expect(reintentoDelNucleo(0, Fallos.demasiadosIntentos()), isNull);
    });

    test('un bug nuestro no se reintenta', () {
      // Repetir un `TypeError` de mapeo da el mismo `TypeError`.
      expect(reintentoDelNucleo(0, ArgumentError('un bug')), isNull);
      expect(reintentoDelNucleo(0, TypeError()), isNull);
    });
  });

  group('insiste con lo que si puede cambiar', () {
    test('sin conexion se reintenta', () {
      expect(reintentoDelNucleo(0, Fallos.sinConexion()), isNotNull);
    });

    test('un 5xx se reintenta: suele ser pasajero', () {
      expect(reintentoDelNucleo(0, Fallos.servidor()), isNotNull);
    });

    test('la espera crece entre intentos', () {
      final primera = reintentoDelNucleo(0, Fallos.sinConexion())!;
      final segunda = reintentoDelNucleo(1, Fallos.sinConexion())!;
      expect(segunda, greaterThan(primera));
    });

    test('deja de insistir al llegar al tope', () {
      // Tres intentos y para. El de Riverpod son diez, que con la espera que
      // dobla deja al usuario mirando un error mas de medio minuto.
      expect(
        reintentoDelNucleo(maxIntentosDelNucleo - 1, Fallos.sinConexion()),
        isNotNull,
      );
      expect(
        reintentoDelNucleo(maxIntentosDelNucleo, Fallos.sinConexion()),
        isNull,
      );
    });
  });
}
