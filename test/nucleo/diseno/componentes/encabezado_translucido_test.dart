import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _pantalla({required bool translucido}) => CustomScrollView(
  slivers: [
    EncabezadoGrande(
      titulo: 'Mi auto',
      subtitulo: 'Todo en orden',
      translucido: translucido,
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => SizedBox(height: 60, child: Text('Fila $i')),
        childCount: 40,
      ),
    ),
  ],
);

void main() {
  testWidgets('sin translucido nunca hay desenfoque', (tester) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: false)));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('translucido expandido no desenfoca y contraido si', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('contraido el fondo deja de ser opaco', (tester) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    final caja = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(BackdropFilter),
        matching: find.byType(DecoratedBox),
      ),
    );
    final color = (caja.decoration as BoxDecoration).color!;
    expect(color.a, lessThan(1));
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(_pantalla(translucido: true), escenario: escenario),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
