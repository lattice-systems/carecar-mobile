import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/textos_guias.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

AppLocalizations textosDe(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(CustomScrollView)));

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

    testWidgets('guia: el titulo no queda tapado al desplazar ($escenario)', (
      tester,
    ) async {
      _pantallaChica(tester);
      final guia = guiasDeEmergencia.first;
      await tester.pumpWidget(
        conTemaPista(PantallaGuia(guia: guia), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      // Recogido el encabezado, la barra con «Regresar» sigue a la vista y
      // el titulo pequeño de la guia ocupa su lugar.
      expect(find.byType(BotonRegresar).hitTestable(), findsOneWidget);
      expect(
        find.text(textosDe(tester).tituloDeGuia(guia.tipo)),
        findsOneWidget,
      );
    });
  }
}
