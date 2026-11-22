import 'package:carecar_mobile/modulos/galeria/presentacion/seccion_galeria.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_base.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_compuestos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/tema_pista.dart';

/// Auditoria automatica de accesibilidad (V2-M20.02 y V2-M20.08) sobre la
/// galeria del sistema: todos los componentes con sus estados, en los tres
/// escenarios. Las guias de Flutter revisan zona tactil, etiquetas y contraste.
void main() {
  final secciones = <SeccionGaleria>[
    ...seccionesBase(),
    ...seccionesCompuestos(),
  ];

  Future<void> montar(
    WidgetTester tester,
    SeccionGaleria seccion,
    Escenario escenario,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        SingleChildScrollView(child: Builder(builder: seccion.construir)),
        escenario: escenario,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final seccion in secciones) {
    group(seccion.titulo, () {
      testWidgets('toda zona tactil mide al menos 48 x 48 (Android)', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, seccion, Escenario.claro);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        semantica.dispose();
      });

      testWidgets('toda zona tactil mide al menos 44 x 44 (iOS)', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, seccion, Escenario.claro);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        semantica.dispose();
      });

      testWidgets('todo control tocable tiene etiqueta para el lector', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, seccion, Escenario.claro);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantica.dispose();
      });

      for (final escenario in [Escenario.claro, Escenario.oscuro]) {
        testWidgets('el texto cumple el contraste en ${escenario.name}', (
          tester,
        ) async {
          final semantica = tester.ensureSemantics();
          await montar(tester, seccion, escenario);
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          semantica.dispose();
        });
      }

      testWidgets('con letra al 200 % nada se desborda (V2-M20.03)', (
        tester,
      ) async {
        await montar(tester, seccion, Escenario.letraGrande);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
