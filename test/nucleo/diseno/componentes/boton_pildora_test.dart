import 'dart:ui' show Tristate;

import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  testWidgets('muestra su texto y llama a alPresionar', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      conTemaPista(
        BotonPildora(texto: 'Reproducir', alPresionar: () => toques++),
      ),
    );
    expect(find.text('Reproducir'), findsOneWidget);
    await tester.tap(find.byType(BotonPildora));
    expect(toques, 1);
  });

  testWidgets('sin alPresionar no responde y se anuncia deshabilitado', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(
      conTemaPista(const BotonPildora(texto: 'Reproducir', alPresionar: null)),
    );
    final nodo = tester.getSemantics(find.byType(BotonPildora));
    expect(nodo.label, 'Reproducir');
    expect(nodo.flagsCollection.isButton, isTrue);
    expect(nodo.flagsCollection.isEnabled, Tristate.isFalse);
    semantica.dispose();
  });

  testWidgets('la zona tactil mide al menos 48 de alto', (tester) async {
    await tester.pumpWidget(
      conTemaPista(BotonPildora(texto: 'Ok', alPresionar: () {})),
    );
    expect(
      tester.getSize(find.byType(BotonPildora)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('lleno usa el acento y tonal usa el acento suave', (
    tester,
  ) async {
    Color? fondoDe() => tester
        .widget<Material>(
          find.descendant(
            of: find.byType(BotonPildora),
            matching: find.byType(Material),
          ),
        )
        .color;

    await tester.pumpWidget(
      conTemaPista(BotonPildora(texto: 'Uno', alPresionar: () {})),
    );
    expect(fondoDe(), PaletaColores.claro.acento);

    await tester.pumpWidget(
      conTemaPista(
        BotonPildora(
          texto: 'Uno',
          variante: VarianteBotonPildora.tonal,
          alPresionar: () {},
        ),
      ),
    );
    expect(fondoDe(), PaletaColores.claro.acentoSuave);
  });

  testWidgets('expandido llena el ancho disponible', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        BotonPildora(texto: 'Ok', expandido: true, alPresionar: () {}),
      ),
    );
    expect(tester.getSize(find.byType(BotonPildora)).width, 360);
  });

  testWidgets('dos botones se reparten una fila', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        Row(
          children: [
            Expanded(
              child: BotonPildora(
                texto: 'Reproducir',
                icono: Icons.play_arrow,
                expandido: true,
                alPresionar: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonPildora(
                texto: 'Agendar',
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                alPresionar: () {},
              ),
            ),
          ],
        ),
      ),
    );
    final a = tester.getSize(find.byType(BotonPildora).first).width;
    final b = tester.getSize(find.byType(BotonPildora).last).width;
    expect(a, b);
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(
          Row(
            children: [
              Expanded(
                child: BotonPildora(
                  texto: 'Agendar cita de servicio',
                  icono: Icons.event,
                  expandido: true,
                  alPresionar: () {},
                ),
              ),
              Expanded(
                child: BotonPildora(
                  texto: 'Llamar',
                  variante: VarianteBotonPildora.tonal,
                  expandido: true,
                  alPresionar: () {},
                ),
              ),
            ],
          ),
          escenario: escenario,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('con reducir movimiento no se encoge al presionar', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: BotonPildora(texto: 'Ok', alPresionar: () {}),
          ),
        ),
      ),
    );
    final gesto = await tester.startGesture(
      tester.getCenter(find.byType(BotonPildora)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final escala = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(escala.scale, 1);
    await gesto.up();
  });
}
