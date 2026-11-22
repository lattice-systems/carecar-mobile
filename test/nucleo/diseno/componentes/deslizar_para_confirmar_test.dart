import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  final perilla = find.byKey(const ValueKey('perilla'));

  Widget control(VoidCallback? alConfirmar, {bool peligro = false}) {
    return DeslizarParaConfirmar(
      texto: 'Cancelar cita',
      alConfirmar: alConfirmar,
      peligro: peligro,
    );
  }

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(control(() {}, peligro: true), escenario: escenario),
      );
      expect(find.text('Cancelar cita'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('deslizar hasta el final confirma una vez', (tester) async {
    var veces = 0;
    await tester.pumpWidget(conTemaPista(control(() => veces++)));
    await tester.drag(perilla, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(veces, 1);
  });

  testWidgets('soltar antes del umbral no confirma y regresa', (tester) async {
    var veces = 0;
    await tester.pumpWidget(conTemaPista(control(() => veces++)));
    final inicio = tester.getTopLeft(perilla).dx;
    final gesto = await tester.startGesture(tester.getCenter(perilla));
    await gesto.moveBy(const Offset(120, 0));
    await tester.pump();
    expect(tester.getTopLeft(perilla).dx, greaterThan(inicio));
    await gesto.up();
    await tester.pumpAndSettle();
    expect(veces, 0);
    expect(tester.getTopLeft(perilla).dx, closeTo(inicio, 0.5));
  });

  testWidgets('un toque suelto no confirma', (tester) async {
    var veces = 0;
    await tester.pumpWidget(conTemaPista(control(() => veces++)));
    await tester.tap(perilla);
    await tester.pumpAndSettle();
    expect(veces, 0);
  });

  testWidgets('deshabilitado no se mueve ni confirma', (tester) async {
    await tester.pumpWidget(conTemaPista(control(null)));
    final inicio = tester.getTopLeft(perilla).dx;
    await tester.drag(perilla, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(perilla).dx, inicio);
  });

  testWidgets('con reducir movimiento regresa sin animar', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: control(() {}),
        ),
      ),
    );
    final inicio = tester.getTopLeft(perilla).dx;
    final gesto = await tester.startGesture(tester.getCenter(perilla));
    await gesto.moveBy(const Offset(100, 0));
    await gesto.up();
    await tester.pump();
    expect(tester.getTopLeft(perilla).dx, closeTo(inicio, 0.5));
  });

  group('alternativa accesible', () {
    Widget accesible(VoidCallback alConfirmar) => conTemaPista(
      MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: control(alConfirmar),
      ),
    );

    testWidgets('cambia el arrastre por un boton', (tester) async {
      await tester.pumpWidget(accesible(() {}));
      expect(perilla, findsNothing);
      expect(find.byType(Boton), findsOneWidget);
    });

    testWidgets('confirma solo tras aceptar el dialogo', (tester) async {
      var veces = 0;
      await tester.pumpWidget(accesible(() => veces++));
      await tester.tap(find.byType(Boton));
      await tester.pumpAndSettle();
      expect(veces, 0);
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(veces, 1);
    });

    testWidgets('cancelar el dialogo no confirma', (tester) async {
      var veces = 0;
      await tester.pumpWidget(accesible(() => veces++));
      await tester.tap(find.byType(Boton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(veces, 0);
    });
  });
}
