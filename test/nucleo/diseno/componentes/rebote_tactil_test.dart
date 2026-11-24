import 'package:carecar_mobile/nucleo/diseno/componentes/rebote_tactil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  testWidgets('muestra el hijo correctamente', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const ReboteTactil(
          child: Text('Tócame'),
        ),
      ),
    );

    expect(find.text('Tócame'), findsOneWidget);
  });

  testWidgets('al presionar y soltar regresa a escala normal', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const ReboteTactil(
          child: SizedBox(width: 100, height: 100),
        ),
      ),
    );

    final gesto = await tester.startGesture(tester.getCenter(find.byType(ReboteTactil)));
    await tester.pump(const Duration(milliseconds: 60));
    await gesto.up();
    await tester.pumpAndSettle();

    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(ReboteTactil),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.0, 0.01));
  });

  testWidgets('deshabilitado no transforma', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const ReboteTactil(
          habilitado: false,
          child: Text('Deshabilitado'),
        ),
      ),
    );

    expect(find.text('Deshabilitado'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ReboteTactil),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('con alPulsar ejecuta la accion al tocar', (tester) async {
    var tocado = false;
    await tester.pumpWidget(
      conTemaPista(
        ReboteTactil(
          alPulsar: () => tocado = true,
          child: const Text('Acción'),
        ),
      ),
    );

    await tester.tap(find.text('Acción'));
    await tester.pumpAndSettle();
    expect(tocado, isTrue);
  });
}
