import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/contraste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('Tono', () {
    for (final paleta in [PaletaColores.claro, PaletaColores.oscuro]) {
      for (final tono in Tono.values) {
        test('${tono.name} pasa AA sobre su fondo', () {
          final c = ColoresTono.de(tono, paleta);
          expect(Contraste.cumpleAA(c.frente, c.fondo), isTrue);
        });
      }
    }
  });

  group('Insignia', () {
    testWidgets('muestra el texto en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const Insignia(texto: 'En proceso', tono: Tono.advertencia),
            escenario: escenario,
          ),
        );
        expect(find.text('En proceso'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('con icono suma el icono del tono', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Insignia(texto: 'Listo', tono: Tono.exito, conIcono: true),
        ),
      );
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('sin icono no lo muestra', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const Insignia(texto: 'Listo', tono: Tono.exito)),
      );
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('avisa su texto al lector de pantalla', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(conTemaPista(const Insignia(texto: 'Listo')));
      expect(find.bySemanticsLabel('Listo'), findsOneWidget);
      semantica.dispose();
    });
  });

  group('Aviso', () {
    testWidgets('muestra titulo y mensaje en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const Aviso(
              titulo: 'Sin conexion',
              mensaje: 'Mostramos lo ultimo que guardamos.',
              tono: Tono.advertencia,
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('Sin conexion'), findsOneWidget);
        expect(find.text('Mostramos lo ultimo que guardamos.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('sin alCerrar no muestra el boton de cierre', (tester) async {
      await tester.pumpWidget(conTemaPista(const Aviso(mensaje: 'Hola')));
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('con alCerrar lo llama y mide 48', (tester) async {
      var cierres = 0;
      await tester.pumpWidget(
        conTemaPista(Aviso(mensaje: 'Hola', alCerrar: () => cierres++)),
      );
      final tamano = tester.getSize(find.byType(IconButton));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(IconButton));
      expect(cierres, 1);
    });

    testWidgets('es una region viva para el lector de pantalla', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(conTemaPista(const Aviso(mensaje: 'Hola')));
      final nodo = tester.getSemantics(find.text('Hola'));
      expect(nodo.label, contains('Hola'));
      semantica.dispose();
    });
  });
}
