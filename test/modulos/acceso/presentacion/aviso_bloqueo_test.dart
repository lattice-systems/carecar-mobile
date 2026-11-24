import 'package:carecar_mobile/modulos/acceso/dominio/bloqueo_por_intentos.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/aviso_bloqueo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

/// V2-M01.01 · «el bloqueo por intentos muestra minutos restantes».
///
/// El dominio ya sabe cuanto falta ([BloqueoPorIntentos]); esto comprueba que
/// la pantalla lo cuenta en voz alta y que el numero baja de verdad.
void main() {
  final base = DateTime(2026, 11, 24, 10, 0);

  /// Monta el aviso con un reloj que la prueba mueve a mano.
  Future<Future<void> Function(Duration)> montar(
    WidgetTester tester, {
    required Duration espera,
  }) async {
    var ahora = base;
    final bloqueo = BloqueoPorIntentos.desde(ahora: base, espera: espera)!;

    await tester.pumpWidget(
      conTemaPista(AvisoBloqueo(bloqueo: bloqueo, reloj: () => ahora)),
    );

    return (Duration transcurrido) async {
      ahora = base.add(transcurrido);
      await tester.pump(const Duration(seconds: 1));
    };
  }

  group('cuenta en minutos', () {
    testWidgets('al aparecer dice los minutos completos', (tester) async {
      await montar(tester, espera: const Duration(minutes: 15));

      expect(find.text('Demasiados intentos'), findsOneWidget);
      expect(find.textContaining('15 min'), findsOneWidget);
    });

    testWidgets('el numero baja con el reloj', (tester) async {
      final avanzar = await montar(tester, espera: const Duration(minutes: 15));

      await avanzar(const Duration(minutes: 10));

      // Es el error de la v1: alli seguiria diciendo 15.
      expect(find.textContaining('5 min'), findsOneWidget);
      expect(find.textContaining('15 min'), findsNothing);
    });

    testWidgets('es una advertencia, no un error', (tester) async {
      await montar(tester, espera: const Duration(minutes: 15));

      final aviso = tester.widget<Aviso>(find.byType(Aviso));
      // Reintentar antes no va a servir: es una espera, no algo que corregir.
      expect(aviso.tono, Tono.advertencia);
    });
  });

  group('el ultimo minuto cuenta en segundos', () {
    testWidgets('abajo de un minuto cambia a segundos', (tester) async {
      final avanzar = await montar(tester, espera: const Duration(minutes: 2));

      await avanzar(const Duration(minutes: 1, seconds: 15));

      expect(find.textContaining('45 s'), findsOneWidget);
      expect(find.textContaining('min'), findsNothing);
    });

    testWidgets('los segundos bajan uno por uno', (tester) async {
      final avanzar = await montar(tester, espera: const Duration(seconds: 50));

      await avanzar(const Duration(seconds: 1));
      expect(find.textContaining('49 s'), findsOneWidget);

      await avanzar(const Duration(seconds: 2));
      expect(find.textContaining('48 s'), findsOneWidget);
    });
  });

  group('cuando se acaba', () {
    testWidgets('el aviso desaparece', (tester) async {
      final avanzar = await montar(tester, espera: const Duration(seconds: 30));

      expect(find.byType(Aviso), findsOneWidget);

      await avanzar(const Duration(seconds: 30));

      // Ya se puede volver a intentar: dejar el aviso seria decirle a alguien
      // que espere cuando ya no hace falta.
      expect(find.byType(Aviso), findsNothing);
    });

    testWidgets('no deja temporizadores corriendo', (tester) async {
      final avanzar = await montar(tester, espera: const Duration(seconds: 5));
      await avanzar(const Duration(seconds: 6));

      // Si el temporizador siguiera vivo, el framework de pruebas se queja al
      // terminar. Que esto pase es la comprobacion.
      await tester.pumpWidget(conTemaPista(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });
}
