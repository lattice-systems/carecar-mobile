import 'package:carecar_mobile/modulos/acceso/dominio/bloqueo_por_intentos.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.01 · «el bloqueo por intentos muestra minutos restantes».
///
/// Dart puro: el dominio no importa Flutter y se prueba sin widgets.
///
/// Es lo unico de esta historia con logica nueva. La v1 muestra un texto fijo
/// armado en el momento del fallo («Espera 15 minutos») que se queda viejo: a
/// los diez minutos sigue diciendo quince. El documento del modulo pide cuenta
/// regresiva.
///
/// **El dominio entrega numeros, no textos.** La regla de `lib/modulos/README`
/// es que las cadenas visibles viven en el ARB y las arma la presentacion, asi
/// que aqui no hay nada parecido al `esperaLegible` de la v1.
void main() {
  final ahora = DateTime(2026, 11, 24, 10, 0);

  group('se arma con lo que dijo el servidor', () {
    test('el Retry-After fija cuando termina', () {
      final bloqueo = BloqueoPorIntentos.desde(
        ahora: ahora,
        espera: const Duration(minutes: 15),
      );

      expect(bloqueo, isNotNull);
      expect(bloqueo!.termina, DateTime(2026, 11, 24, 10, 15));
    });

    test('sin Retry-After no hay bloqueo que contar', () {
      // El encabezado es opcional en el contrato. Sin el no se puede hacer
      // cuenta regresiva, y la pantalla cae en el aviso generico.
      expect(BloqueoPorIntentos.desde(ahora: ahora, espera: null), isNull);
    });

    test('una espera de cero o negativa tampoco es bloqueo', () {
      expect(
        BloqueoPorIntentos.desde(ahora: ahora, espera: Duration.zero),
        isNull,
      );
      expect(
        BloqueoPorIntentos.desde(
          ahora: ahora,
          espera: const Duration(seconds: -5),
        ),
        isNull,
      );
    });
  });

  group('la cuenta baja con el reloj', () {
    final bloqueo = BloqueoPorIntentos.desde(
      ahora: ahora,
      espera: const Duration(minutes: 15),
    )!;

    test('al principio falta todo', () {
      expect(bloqueo.restante(ahora), const Duration(minutes: 15));
    });

    test('a los diez minutos faltan cinco, no quince', () {
      // Es justo el error de la v1.
      final despues = ahora.add(const Duration(minutes: 10));
      expect(bloqueo.restante(despues), const Duration(minutes: 5));
      expect(bloqueo.minutosRestantes(despues), 5);
    });

    test('nunca queda tiempo negativo', () {
      final mucho = ahora.add(const Duration(hours: 3));
      expect(bloqueo.restante(mucho), Duration.zero);
      expect(bloqueo.minutosRestantes(mucho), 0);
    });

    test('ya termino cuando llega la hora', () {
      expect(bloqueo.yaTermino(ahora), isFalse);
      expect(bloqueo.yaTermino(ahora.add(const Duration(minutes: 15))), isTrue);
      expect(bloqueo.yaTermino(ahora.add(const Duration(minutes: 16))), isTrue);
    });
  });

  group('los minutos se redondean hacia arriba', () {
    final bloqueo = BloqueoPorIntentos.desde(
      ahora: ahora,
      espera: const Duration(minutes: 15),
    )!;

    test('con un segundo corrido siguen siendo 15, no 16', () {
      expect(
        bloqueo.minutosRestantes(ahora.add(const Duration(seconds: 1))),
        15,
      );
    });

    test('con un segundo restante dice 1 minuto, no 0', () {
      // Decir «0 minutos» mientras sigue bloqueado seria mentirle al usuario.
      final casiListo = ahora.add(const Duration(minutes: 14, seconds: 59));
      expect(bloqueo.minutosRestantes(casiListo), 1);
      expect(bloqueo.yaTermino(casiListo), isFalse);
    });

    test('con 61 segundos restantes dice 2 minutos', () {
      final faltan61 = ahora.add(const Duration(minutes: 13, seconds: 59));
      expect(bloqueo.restante(faltan61), const Duration(seconds: 61));
      expect(bloqueo.minutosRestantes(faltan61), 2);
    });
  });

  group('el ultimo minuto se cuenta en segundos', () {
    final bloqueo = BloqueoPorIntentos.desde(
      ahora: ahora,
      espera: const Duration(minutes: 15),
    )!;

    test('arriba de un minuto se muestra en minutos', () {
      final faltan90 = ahora.add(const Duration(minutes: 13, seconds: 30));
      expect(bloqueo.seMuestraEnMinutos(faltan90), isTrue);
    });

    test('abajo de un minuto se muestra en segundos', () {
      // «Espera 1 minuto» durante 59 segundos se siente roto; los segundos
      // bajando dejan ver que algo pasa.
      final faltan45 = ahora.add(const Duration(minutes: 14, seconds: 15));
      expect(bloqueo.seMuestraEnMinutos(faltan45), isFalse);
      expect(bloqueo.segundosRestantes(faltan45), 45);
    });

    test('justo en un minuto se muestra en minutos', () {
      final faltan60 = ahora.add(const Duration(minutes: 14));
      expect(bloqueo.seMuestraEnMinutos(faltan60), isTrue);
      expect(bloqueo.minutosRestantes(faltan60), 1);
    });
  });
}
