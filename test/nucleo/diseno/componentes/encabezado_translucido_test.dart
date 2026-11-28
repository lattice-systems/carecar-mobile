import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _pantalla({required bool translucido}) => CustomScrollView(
  slivers: [
    EncabezadoGrande(
      titulo: 'Mi auto',
      subtitulo: 'Todo en orden',
      translucido: translucido,
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => SizedBox(height: 60, child: Text('Fila $i')),
        childCount: 40,
      ),
    ),
  ],
);

void main() {
  testWidgets('sin translucido nunca hay desenfoque', (tester) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: false)));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('translucido expandido no desenfoca y contraido si', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('contraido el fondo deja de ser opaco', (tester) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    final caja = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(BackdropFilter),
        matching: find.byType(DecoratedBox),
      ),
    );
    final color = (caja.decoration as BoxDecoration).color!;
    expect(color.a, lessThan(1));
  });

  testWidgets('al desplazar el titulo sigue visible y nada lo tapa', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    for (final dy in [-100.0, -400.0, -1200.0]) {
      await tester.drag(find.byType(CustomScrollView), Offset(0, dy));
      await tester.pump();
      expect(find.text('Mi auto').hitTestable(), findsOneWidget);
    }
  });

  testWidgets('contraido, el titulo chico va centrado en la pantalla', (
    tester,
  ) async {
    // Con botón de regreso y una acción de distinto ancho el título sigue en
    // el centro de la barra, no pegado al botón.
    await tester.pumpWidget(
      conTemaPista(
        CustomScrollView(
          slivers: [
            const EncabezadoGrande(
              titulo: 'Mi garaje',
              conRegreso: true,
              acciones: [SizedBox(width: 48, height: 48)],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => SizedBox(height: 60, child: Text('Fila $i')),
                childCount: 40,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();

    final pantalla = tester.view.physicalSize / tester.view.devicePixelRatio;
    final centro = tester.getCenter(find.text('Mi garaje'));
    expect(centro.dx, closeTo(pantalla.width / 2, 1));
  });

  testWidgets('sin regreso ni acciones el título sube a ocupar la barra', (
    tester,
  ) async {
    Future<double> arribaDeLaTarjeta({required bool conRegreso}) async {
      await tester.pumpWidget(
        conTemaPista(
          CustomScrollView(
            slivers: [
              EncabezadoGrande(
                titulo: 'Mi garaje',
                icono: Icons.directions_car,
                conRegreso: conRegreso,
              ),
            ],
          ),
        ),
      );
      return tester.getTopLeft(find.text('Mi garaje')).dy;
    }

    final conBoton = await arribaDeLaTarjeta(conRegreso: true);
    final sinBotones = await arribaDeLaTarjeta(conRegreso: false);

    // La barra vacía ya no deja un hueco sobre la tarjeta.
    expect(sinBotones, lessThan(conBoton - 40));
  });

  testWidgets('contraido el fondo cubre lo bastante para no leer lo de abajo', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_pantalla(translucido: true)));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    final caja = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(BackdropFilter),
        matching: find.byType(DecoratedBox),
      ),
    );
    final color = (caja.decoration as BoxDecoration).color!;
    expect(color.a, greaterThanOrEqualTo(0.9));
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(_pantalla(translucido: true), escenario: escenario),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
