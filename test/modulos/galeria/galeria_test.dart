import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/galeria/galeria.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/pantalla_galeria.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/seccion_galeria.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_base.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_compuestos.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

void main() {
  final secciones = <SeccionGaleria>[
    ...seccionesBase(),
    ...seccionesCompuestos(),
    ...seccionesPantalla(),
  ];

  test(
    'la galeria trae una seccion por componente y sin titulos repetidos',
    () {
      final titulos = secciones.map((s) => s.titulo).toList();
      expect(titulos.toSet().length, titulos.length);
      expect(secciones.length, greaterThanOrEqualTo(15));
    },
  );

  for (final seccion in secciones) {
    testWidgets('"${seccion.titulo}" se ve en claro, oscuro y letra al 200 %', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            SingleChildScrollView(child: Builder(builder: seccion.construir)),
            escenario: escenario,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester.takeException(),
          isNull,
          reason: '${seccion.titulo} en ${escenario.name}',
        );
      }
    });
  }

  group('PantallaGaleria', () {
    Widget pantalla() => const MaterialApp(
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      home: PantallaGaleria(),
    );

    testWidgets('muestra los tres interruptores y la primera seccion', (
      tester,
    ) async {
      await tester.pumpWidget(pantalla());
      expect(find.text('Galeria del sistema'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(find.text('Letra 150 %'), findsOneWidget);
      expect(find.text('Letra 200 %'), findsOneWidget);
      expect(find.text('Boton'), findsOneWidget);
    });

    testWidgets('cambia a oscuro y a letra grande sin desbordar', (
      tester,
    ) async {
      await tester.pumpWidget(pantalla());
      await tester.tap(find.text('Oscuro'));
      await tester.pump();
      await tester.tap(find.text('Letra 200 %'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      final tema = Theme.of(tester.element(find.text('Galeria del sistema')));
      expect(tema.brightness, Brightness.dark);
      expect(
        MediaQuery.textScalerOf(tester.element(find.text('Oscuro'))).scale(10),
        20,
      );
    });

    testWidgets('al desplazar llega a las secciones de abajo', (tester) async {
      await tester.pumpWidget(pantalla());
      await tester.scrollUntilVisible(
        find.text('Barra de navegacion'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Barra de navegacion'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('exporta su ruta', () {
    expect(rutaGaleria, '/galeria');
    expect(rutasGaleria, isNotEmpty);
  });
}
