import 'package:carecar_mobile/nucleo/diseno/componentes/barra_portada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _pantalla() => Scaffold(
  extendBodyBehindAppBar: true,
  appBar: const BarraPortada(titulo: 'Detalle'),
  body: ListView(
    children: [
      for (var i = 0; i < 40; i++) SizedBox(height: 80, child: Text('Fila $i')),
    ],
  ),
);

Color _fondoBarra(WidgetTester tester) {
  final material = tester.widget<Material>(
    find
        .descendant(of: find.byType(AppBar), matching: find.byType(Material))
        .first,
  );
  return material.color ?? Colors.transparent;
}

void main() {
  testWidgets('arriba es transparente y al desplazar se vuelve opaca', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla()));
    expect(_fondoBarra(tester).a, 0);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(_fondoBarra(tester).a, 1);
  });

  testWidgets('al desplazar el titulo sigue visible y nada lo tapa', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla()));
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Detalle').hitTestable(), findsOneWidget);
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(conTemaPista(_pantalla(), escenario: escenario));
      expect(tester.takeException(), isNull);
    }
  });
}
