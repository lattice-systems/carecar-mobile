import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_compuestos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fuentes_golden.dart';
import '../../../ayudas/tema_pista.dart';

/// Golden de la sección "Mensajes" en claro, oscuro y letra al 200 %.
void main() {
  prepararFuentesGolden();

  final seccion = seccionesCompuestos().firstWhere(
    (s) => s.titulo == 'Mensajes',
  );

  for (final escenario in Escenario.values) {
    testWidgets('Mensajes en ${escenario.name}', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        conTemaPista(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(builder: seccion.construir),
            ),
          ),
          escenario: escenario,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/mensajes_${escenario.name}.png'),
      );
    });
  }
}
