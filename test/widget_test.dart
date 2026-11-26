import 'package:carecar_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

/// Monta la app real y la deja avanzar un momento. No se usa
/// `pumpAndSettle`: con dirección por flavor la app arranca de verdad
/// (cortina, sesión, peticiones) y nunca queda quieta.
Future<void> _montarApp(WidgetTester tester) async {
  await tester.pumpWidget(const AppCareCar());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets(
    'sin --dart-define la app toma la dirección de su flavor y arranca',
    (tester) async {
      // Antes de V2-T01.04 las pruebas sin API_BASE_URL caían en la pantalla
      // de error. Ahora cada flavor trae su dirección por omisión (aquí
      // produccion), así que ese error ya no debe aparecer. Los casos de
      // dirección inválida se prueban en test/api/api_config_test.dart.
      await _montarApp(tester);

      expect(
        find.text('Falta configurar la dirección de la API'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('la app no arranca con el contador de ejemplo de Flutter', (
    tester,
  ) async {
    await _montarApp(tester);

    expect(find.byIcon(LucideIcons300.plus), findsNothing);
    expect(find.textContaining('You have pushed the button'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
