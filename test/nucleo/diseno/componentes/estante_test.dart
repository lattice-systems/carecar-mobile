import 'package:carecar_mobile/nucleo/diseno/componentes/estante.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _estante({VoidCallback? alVerTodo, int cuantas = 6}) => Estante(
  titulo: 'Para ti',
  alVerTodo: alVerTodo,
  anchoTarjeta: 140,
  hijos: [
    for (var i = 0; i < cuantas; i++)
      Container(
        key: ValueKey('t$i'),
        height: 140,
        color: Colors.blueGrey,
        alignment: Alignment.center,
        child: Text('Tarjeta $i'),
      ),
  ],
);

void main() {
  testWidgets('muestra el titulo como encabezado y las primeras tarjetas', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(conTemaPista(_estante()));
    expect(find.text('Para ti'), findsOneWidget);
    expect(find.text('Tarjeta 0'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Para ti')).flagsCollection.isHeader,
      isTrue,
    );
    semantica.dispose();
  });

  testWidgets('sin alVerTodo no muestra el enlace', (tester) async {
    await tester.pumpWidget(conTemaPista(_estante()));
    expect(find.text('Ver todo'), findsNothing);
  });

  testWidgets('con alVerTodo muestra el enlace y responde', (tester) async {
    var veces = 0;
    await tester.pumpWidget(conTemaPista(_estante(alVerTodo: () => veces++)));
    await tester.tap(find.text('Ver todo'));
    expect(veces, 1);
    expect(
      tester.getSize(find.bySemanticsLabel('Ver todo: Para ti')).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('al soltar el carrusel se queda alineado a una tarjeta', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_estante()));
    await tester.drag(find.byType(ListView), const Offset(-100, 0));
    await tester.pumpAndSettle();
    final posicion = tester.state<ScrollableState>(find.byType(Scrollable));
    // tarjeta de 140 mas separacion de 12
    expect(posicion.position.pixels % 152, closeTo(0, 0.5));
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(_estante(alVerTodo: () {}), escenario: escenario),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
