import 'dart:ui' show Tristate;

import 'package:carecar_mobile/nucleo/diseno/componentes/boton_circular.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Color? _fondo(WidgetTester tester) {
  final caja = tester.widget<Container>(
    find.descendant(
      of: find.byType(BotonCircular),
      matching: find.byKey(const ValueKey('boton-circular-fondo')),
    ),
  );
  return (caja.decoration! as BoxDecoration).color;
}

void main() {
  group('BotonCircular (V2-T02.17)', () {
    testWidgets('mide 48, tiene nombre y responde al toque', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        conTemaPista(
          BotonCircular(
            icono: Icons.send,
            etiqueta: 'Enviar',
            alPresionar: () => toques++,
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('boton-circular-fondo'))),
        const Size(48, 48),
      );
      expect(find.bySemanticsLabel('Enviar'), findsOneWidget);
      await tester.tap(find.byType(BotonCircular));
      await tester.pumpAndSettle();
      expect(toques, 1);
    });

    testWidgets('acento habilitado se rellena como el 👍 marcado', (
      tester,
    ) async {
      late TokensPista tokens;
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) {
              tokens = TokensPista.de(context);
              return BotonCircular(
                icono: Icons.send,
                etiqueta: 'Enviar',
                variante: VarianteBotonCircular.acento,
                alPresionar: () {},
              );
            },
          ),
        ),
      );
      expect(_fondo(tester), tokens.colores.acentoSuave);
    });

    testWidgets('deshabilitado no responde y se ve apagado', (tester) async {
      late TokensPista tokens;
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) {
              tokens = TokensPista.de(context);
              return const BotonCircular(
                icono: Icons.send,
                etiqueta: 'Enviar',
                variante: VarianteBotonCircular.acento,
                alPresionar: null,
              );
            },
          ),
        ),
      );
      expect(_fondo(tester), tokens.colores.superficieHundida);
      final datos = tester
          .getSemantics(find.bySemanticsLabel('Enviar'))
          .getSemanticsData();
      expect(datos.flagsCollection.isEnabled, Tristate.isFalse);
    });

    testWidgets('marcado se anuncia como seleccionado y cambia de icono', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          BotonCircular(
            icono: Icons.thumb_up_outlined,
            iconoMarcado: Icons.thumb_up,
            etiqueta: 'Me sirvió',
            marcado: true,
            alPresionar: () {},
          ),
        ),
      );
      final datos = tester
          .getSemantics(find.bySemanticsLabel('Me sirvió'))
          .getSemanticsData();
      expect(datos.flagsCollection.isSelected, Tristate.isTrue);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('vidrio es translucido con borde de luz (V2-T02.19)', (
      tester,
    ) async {
      late TokensPista tokens;
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) {
              tokens = TokensPista.de(context);
              return BotonCircular(
                icono: Icons.attach_file,
                etiqueta: 'Adjuntar',
                variante: VarianteBotonCircular.vidrio,
                alPresionar: () {},
              );
            },
          ),
          escenario: Escenario.oscuro,
        ),
      );
      final caja = tester.widget<Container>(
        find.byKey(const ValueKey('boton-circular-fondo')),
      );
      final deco = caja.decoration! as BoxDecoration;
      expect(deco.color, tokens.colores.texto.withValues(alpha: 0.06));
      expect(deco.border, isNotNull);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.attach_file)).color,
        tokens.colores.acento,
      );
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            BotonCircular(
              icono: Icons.send,
              etiqueta: 'Enviar',
              alPresionar: () {},
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
