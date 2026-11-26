import 'package:carecar_mobile/nucleo/diseno/componentes/cuadro_fecha.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _cuadro(
  DateTime fecha, {
  Tono tono = Tono.informacion,
  Escenario escenario = Escenario.claro,
}) => conTemaPista(
  Align(
    alignment: Alignment.topLeft,
    child: CuadroFecha(fecha: fecha, tono: tono),
  ),
  escenario: escenario,
);

void main() {
  group('CuadroFecha', () {
    testWidgets('dice el día y el mes abreviado en mayúsculas, sin punto', (
      tester,
    ) async {
      await tester.pumpWidget(_cuadro(DateTime(2026, 9, 15)));

      expect(find.text('15'), findsOneWidget);
      // «sept.» en español: sin el punto y en mayúsculas.
      expect(find.text('SEPT'), findsOneWidget);
    });

    testWidgets('es un cuadro pleno del tono con texto sobre acento', (
      tester,
    ) async {
      // Igual que el cuadro de icono de TarjetaResumen y de GrupoLista: no un
      // fondo pálido con texto de color (otro estilo para el mismo elemento).
      await tester.pumpWidget(
        _cuadro(DateTime(2026, 10, 21), tono: Tono.exito),
      );

      final paleta = TokensPista.claro.colores;
      final caja = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(CuadroFecha),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((caja.decoration as BoxDecoration).color, paleta.exito);
      final dia = tester.widget<Text>(find.text('21'));
      expect(dia.style?.color, paleta.sobreAcento);
    });

    testWidgets('mide lo mismo que el cuadro de icono de una tarjeta', (
      tester,
    ) async {
      await tester.pumpWidget(_cuadro(DateTime(2026, 10, 21)));

      expect(tester.getSize(find.byType(CuadroFecha)).width, 40);
    });

    testWidgets('es decorativo: la fila o la tarjeta ya leen la fecha', (
      tester,
    ) async {
      await tester.pumpWidget(_cuadro(DateTime(2026, 10, 21)));

      expect(
        find.descendant(
          of: find.byType(CuadroFecha),
          matching: find.byType(ExcludeSemantics),
        ),
        findsWidgets,
      );
    });

    for (final escenario in Escenario.values) {
      testWidgets('se ve sin desbordes en $escenario', (tester) async {
        await tester.pumpWidget(
          _cuadro(DateTime(2026, 12, 28), escenario: escenario),
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
