import 'package:carecar_mobile/pantallas/pantalla_arranque.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(bool listo, Duration minimo) => MaterialApp(
    home: CortinaArranque(
      listo: listo,
      duracionMinima: minimo,
      siguiente: (_) => const Text('Iniciar sesión'),
    ),
  );

  testWidgets('muestra el telon hasta que termina la restauracion', (
    tester,
  ) async {
    await tester.pumpWidget(app(false, Duration.zero));
    expect(find.byKey(CortinaArranque.logo), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);

    await tester.pumpWidget(app(true, Duration.zero));
    await tester.pumpAndSettle();
    expect(find.byKey(CortinaArranque.logo), findsNothing);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('con duracion minima la cortina se abre y se descarta', (
    tester,
  ) async {
    await tester.pumpWidget(app(true, const Duration(milliseconds: 1200)));
    expect(find.byKey(CortinaArranque.logo), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byKey(CortinaArranque.logo), findsNothing);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
