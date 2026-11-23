import 'dart:async';
import 'dart:typed_data';

import 'package:carecar_mobile/nucleo/diseno/componentes/semaforo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/visor_pdf.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/contraste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('Semaforo', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            SingleChildScrollView(
              child: Column(
                children: [
                  for (final estado in EstadoSemaforo.values)
                    Semaforo(
                      punto: 'Frenos y balatas delanteras',
                      estado: estado,
                      detalle: 'Balatas al 10 %, cambio recomendado',
                      alToque: () {},
                    ),
                ],
              ),
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('Urgente'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('cada estado lleva icono y texto propios, no solo color', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          Column(
            children: [
              for (final estado in EstadoSemaforo.values)
                Semaforo(punto: 'Punto', estado: estado),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Bien'), findsOneWidget);
      expect(find.text('Requiere atencion'), findsOneWidget);
    });

    test('los tres tonos pasan AA en claro y oscuro', () {
      for (final paleta in [PaletaColores.claro, PaletaColores.oscuro]) {
        for (final estado in EstadoSemaforo.values) {
          final c = ColoresTono.de(estado.tono, paleta);
          expect(Contraste.cumpleAA(c.frente, c.fondo), isTrue);
        }
      }
    });

    testWidgets('se anuncia como un solo nodo con su estado', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Semaforo(
            punto: 'Frenos',
            estado: EstadoSemaforo.urgente,
            detalle: 'Balatas al 10 %',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Frenos: urgente. Balatas al 10 %'),
        findsOneWidget,
      );
    });

    testWidgets('con toque responde y mide al menos 48', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(
          Semaforo(
            punto: 'Luces',
            estado: EstadoSemaforo.bien,
            alToque: () => veces++,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Semaforo)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Luces'));
      expect(veces, 1);
    });

    testWidgets('sin toque no muestra chevron', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Semaforo(punto: 'Luces', estado: EstadoSemaforo.bien),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('VisorPdf', () {
    Widget visor(
      Future<Uint8List> Function() cargar, {
      Escenario escenario = Escenario.claro,
      FabricaVisorPdf? fabrica,
    }) => conTemaPista(
      SizedBox(
        height: 600,
        child: VisorPdf(
          cargar: cargar,
          descripcion: 'Manual del Mazda CX-5',
          fabrica: fabrica ?? _fabricaFalsa(),
        ),
      ),
      escenario: escenario,
    );

    testWidgets('mientras carga muestra un esqueleto y lo anuncia', (
      tester,
    ) async {
      final espera = Completer<Uint8List>();
      await tester.pumpWidget(visor(() => espera.future));
      expect(find.bySemanticsLabel('Cargando documento'), findsOneWidget);
      expect(find.text('Página 1 de 5'), findsNothing);
    });

    testWidgets('con los bytes muestra el visor y el contador de paginas', (
      tester,
    ) async {
      await tester.pumpWidget(visor(() async => Uint8List.fromList([1, 2, 3])));
      await tester.pump();
      await tester.pump();
      expect(find.text('visor falso'), findsOneWidget);
      expect(find.text('Página 1 de 5'), findsOneWidget);
    });

    testWidgets('el contador sigue el cambio de pagina', (tester) async {
      await tester.pumpWidget(visor(() async => Uint8List.fromList([1])));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('visor falso'));
      await tester.pump();
      expect(find.text('Página 2 de 5'), findsOneWidget);
    });

    testWidgets('si falla muestra el error y reintenta', (tester) async {
      var intentos = 0;
      await tester.pumpWidget(
        visor(() async {
          intentos++;
          if (intentos == 1) throw Exception('sin red');
          return Uint8List.fromList([1]);
        }),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('No pudimos cargar esto'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump();
      expect(intentos, 2);
      expect(find.text('visor falso'), findsOneWidget);
    });

    testWidgets('el documento se nombra para el lector de pantalla', (
      tester,
    ) async {
      await tester.pumpWidget(visor(() async => Uint8List.fromList([1])));
      await tester.pump();
      await tester.pump();
      expect(find.bySemanticsLabel('Manual del Mazda CX-5'), findsOneWidget);
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          visor(() async => Uint8List.fromList([1]), escenario: escenario),
        );
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}

FabricaVisorPdf _fabricaFalsa() {
  var cargado = false;
  var pagina = 1;
  return (context, bytes, alCargar, alCambiarPagina) {
    if (!cargado) {
      cargado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => alCargar(5));
    }
    return GestureDetector(
      onTap: () => alCambiarPagina(++pagina),
      child: const Center(child: Text('visor falso')),
    );
  };
}
