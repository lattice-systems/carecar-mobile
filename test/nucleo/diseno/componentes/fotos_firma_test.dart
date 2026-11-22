import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/nucleo/diseno/componentes/comparacion_antes_despues.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/firma.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

FotoGaleria _foto(String descripcion) =>
    FotoGaleria(imagen: MemoryImage(_png), descripcion: descripcion);

void main() {
  group('GaleriaFotos', () {
    final fotos = [_foto('Frente'), _foto('Lateral'), _foto('Interior')];

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(GaleriaFotos(fotos: fotos), escenario: escenario),
        );
        await tester.pump();
        expect(find.text('1 de 3'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('las flechas cambian de foto y se apagan en los extremos', (
      tester,
    ) async {
      await tester.pumpWidget(conTemaPista(GaleriaFotos(fotos: fotos)));
      await tester.pump();
      IconButton flecha(Key k) => tester.widget<IconButton>(find.byKey(k));
      expect(flecha(GaleriaFotos.flechaAnterior).onPressed, isNull);
      await tester.tap(find.byKey(GaleriaFotos.flechaSiguiente));
      await tester.pumpAndSettle();
      expect(find.text('2 de 3'), findsOneWidget);
      await tester.tap(find.byKey(GaleriaFotos.flechaSiguiente));
      await tester.pumpAndSettle();
      expect(flecha(GaleriaFotos.flechaSiguiente).onPressed, isNull);
    });

    testWidgets('las flechas miden al menos 48', (tester) async {
      await tester.pumpWidget(conTemaPista(GaleriaFotos(fotos: fotos)));
      await tester.pump();
      final tamano = tester.getSize(find.byKey(GaleriaFotos.flechaSiguiente));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
    });

    testWidgets('con una sola foto no hay flechas', (tester) async {
      await tester.pumpWidget(
        conTemaPista(GaleriaFotos(fotos: [_foto('Frente')])),
      );
      await tester.pump();
      expect(find.byKey(GaleriaFotos.flechaSiguiente), findsNothing);
    });

    testWidgets('tocar una foto abre el visor con zoom y se cierra', (
      tester,
    ) async {
      await tester.pumpWidget(conTemaPista(GaleriaFotos(fotos: fotos)));
      await tester.pump();
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.byTooltip('Cerrar foto'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('sin fotos muestra el mensaje', (tester) async {
      await tester.pumpWidget(conTemaPista(const GaleriaFotos(fotos: [])));
      expect(find.text('Aun no hay fotos.'), findsOneWidget);
    });

    testWidgets('cada foto se anuncia con su descripcion', (tester) async {
      await tester.pumpWidget(conTemaPista(GaleriaFotos(fotos: fotos)));
      await tester.pump();
      expect(find.bySemanticsLabel('Frente'), findsOneWidget);
    });
  });

  group('ComparacionAntesDespues', () {
    Widget comparacion({double inicial = 0.5}) => conTemaPista(
      ComparacionAntesDespues(
        antes: _foto('Rayon en la puerta'),
        despues: _foto('Puerta reparada'),
        inicial: inicial,
      ),
    );

    testWidgets('se ve en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            ComparacionAntesDespues(
              antes: _foto('Antes'),
              despues: _foto('Despues'),
            ),
            escenario: escenario,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('arrastrar mueve la barra', (tester) async {
      await tester.pumpWidget(comparacion());
      await tester.pump();
      final inicio = tester.getCenter(
        find.byKey(ComparacionAntesDespues.barra),
      );
      await tester.drag(
        find.byKey(ComparacionAntesDespues.barra),
        const Offset(60, 0),
      );
      await tester.pump();
      final fin = tester.getCenter(find.byKey(ComparacionAntesDespues.barra));
      expect(fin.dx, greaterThan(inicio.dx));
    });

    testWidgets('la barra no se sale de los extremos', (tester) async {
      await tester.pumpWidget(comparacion());
      await tester.pump();
      await tester.drag(
        find.byKey(ComparacionAntesDespues.barra),
        const Offset(2000, 0),
      );
      await tester.pump();
      expect(
        tester.getCenter(find.byKey(ComparacionAntesDespues.barra)).dx,
        lessThanOrEqualTo(
          tester.getRect(find.byType(ComparacionAntesDespues)).right,
        ),
      );
    });

    testWidgets('el lector de pantalla puede subir y bajar el valor', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(comparacion());
      await tester.pump();
      final nodo = find.bySemanticsLabel(RegExp('Comparacion'));
      expect(
        tester.getSemantics(nodo),
        matchesSemantics(
          label: 'Comparacion. Rayon en la puerta contra Puerta reparada',
          value: '50 % del antes',
          increasedValue: '60 %',
          decreasedValue: '40 %',
          isSlider: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      tester.semantics.increase(find.semantics.byLabel(RegExp("Comparacion")));
      await tester.pump();
      expect(tester.getSemantics(nodo).value, '60 % del antes');
      semantica.dispose();
    });
  });

  group('Firma', () {
    testWidgets('muestra firmante y fecha en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Firma(
              firmante: 'Ana Perez',
              fecha: '12 de noviembre de 2026',
              imagen: MemoryImage(_png),
            ),
            escenario: escenario,
          ),
        );
        await tester.pump();
        expect(find.text('Ana Perez, 12 de noviembre de 2026'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('sin imagen dice que aun no hay firma', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const Firma(firmante: 'Ana Perez', imagen: null)),
      );
      expect(find.text('Aun sin firma'), findsOneWidget);
      expect(find.bySemanticsLabel('Sin firma de Ana Perez'), findsOneWidget);
    });

    testWidgets('con imagen se anuncia como firma', (tester) async {
      await tester.pumpWidget(
        conTemaPista(Firma(firmante: 'Ana Perez', imagen: MemoryImage(_png))),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Firma de Ana Perez'), findsOneWidget);
    });
  });
}
