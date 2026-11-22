import 'package:carecar_mobile/nucleo/diseno/componentes/grafica.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

const _datos = [
  PuntoGrafica(etiqueta: 'Ene', valor: 1200),
  PuntoGrafica(etiqueta: 'Feb', valor: 800),
  PuntoGrafica(etiqueta: 'Mar', valor: 1500),
];

String _pesos(double v) => '\$${v.toInt()}';

void main() {
  for (final tipo in TipoGrafica.values) {
    testWidgets('${tipo.name} se dibuja en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Grafica(titulo: 'Gasto por mes', puntos: _datos, tipo: tipo),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Gasto por mes'), findsOneWidget);
        expect(find.text('Ene'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('el boton alterna entre grafica y tabla', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const Grafica(
          titulo: 'Gasto por mes',
          puntos: _datos,
          formatoValor: _pesos,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('\$1200'), findsNothing);
    await tester.tap(find.text('Ver como tabla'));
    await tester.pumpAndSettle();
    expect(find.text('\$1200'), findsOneWidget);
    expect(find.text('\$800'), findsOneWidget);
    await tester.tap(find.text('Ver grafica'));
    await tester.pumpAndSettle();
    expect(find.text('\$1200'), findsNothing);
  });

  testWidgets('con lector de pantalla muestra la tabla sin boton', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        const MediaQuery(
          data: MediaQueryData(accessibleNavigation: true),
          child: Grafica(
            titulo: 'Gasto por mes',
            puntos: _datos,
            formatoValor: _pesos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('\$1500'), findsOneWidget);
    expect(find.text('Ver como tabla'), findsNothing);
  });

  testWidgets('cada fila de la tabla se anuncia como un solo nodo', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        const MediaQuery(
          data: MediaQueryData(accessibleNavigation: true),
          child: Grafica(
            titulo: 'Gasto por mes',
            puntos: _datos,
            formatoValor: _pesos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Feb: \$800'), findsOneWidget);
  });

  testWidgets('sin datos explica por que no hay grafica', (tester) async {
    await tester.pumpWidget(
      conTemaPista(const Grafica(titulo: 'Gasto por mes', puntos: [])),
    );
    expect(find.text('Aun no hay datos para mostrar.'), findsOneWidget);
    expect(find.text('Ver como tabla'), findsNothing);
  });

  testWidgets('valores en cero o negativos no truenan', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const Grafica(
          titulo: 'Saldo',
          puntos: [
            PuntoGrafica(etiqueta: 'A', valor: 0),
            PuntoGrafica(etiqueta: 'B', valor: -40),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('con reducir movimiento aparece completa', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Grafica(titulo: 'Gasto por mes', puntos: _datos),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 130));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
