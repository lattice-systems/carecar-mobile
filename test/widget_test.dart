import 'package:carecar_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'sin API_URL la app explica como configurarla en lugar de arrancar',
    (tester) async {
      // Las pruebas corren sin --dart-define, asi que ApiConfig.desdeEntorno()
      // falla a proposito. Es el comportamiento que se quiere: mejor un error
      // claro que una app apuntando a ningun lado.
      await tester.pumpWidget(const AppCareCar());
      await tester.pumpAndSettle();

      expect(
        find.text('Falta configurar la dirección de la API'),
        findsOneWidget,
      );
      expect(find.textContaining('--dart-define=API_URL'), findsOneWidget);
    },
  );

  testWidgets('la app no arranca con el contador de ejemplo de Flutter', (
    tester,
  ) async {
    await tester.pumpWidget(const AppCareCar());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.textContaining('You have pushed the button'), findsNothing);
  });
}
