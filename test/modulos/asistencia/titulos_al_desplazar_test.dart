import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

void _pantallaChica(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 480);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  for (final escenario in Escenario.values) {
    testWidgets('guias: el titulo no queda tapado al desplazar ($escenario)', (
      tester,
    ) async {
      _pantallaChica(tester);
      await tester.pumpWidget(
        conTemaPista(const PantallaGuias(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Emergencias').hitTestable(), findsOneWidget);
    });

    testWidgets('guia: la barra se vuelve opaca al desplazar ($escenario)', (
      tester,
    ) async {
      _pantallaChica(tester);
      await tester.pumpWidget(
        conTemaPista(
          PantallaGuia(guia: guiasDeEmergencia.first),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      Color barra() => tester
          .widget<Material>(
            find
                .descendant(
                  of: find.byType(AppBar),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color!;
      expect(barra().a, 0);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(barra().a, 1);
    });
  }
}
