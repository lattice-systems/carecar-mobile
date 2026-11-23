import 'dart:async';
import 'dart:typed_data';

import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector_franja.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/visor_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/tema_pista.dart';

void main() {
  const ingles = Locale('en');

  testWidgets('el selector de horarios habla ingles', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        SelectorFranja(
          franjas: const [
            FranjaHoraria(etiqueta: '09:00', cupo: 2),
            FranjaHoraria(etiqueta: '10:00', cupo: 0),
          ],
          seleccionada: null,
          alSeleccionar: (_) {},
        ),
        idioma: ingles,
      ),
    );
    expect(find.text('09:00 · 2 spots'), findsOneWidget);
    expect(find.text('10:00 · fully booked'), findsOneWidget);
  });

  testWidgets('el selector sin horarios explica en ingles', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        SelectorFranja(
          franjas: const [],
          seleccionada: null,
          alSeleccionar: (_) {},
        ),
        idioma: ingles,
      ),
    );
    expect(find.text('There are no time slots for this day.'), findsOneWidget);
  });

  testWidgets('el aviso cierra con texto en ingles', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        Aviso(mensaje: 'Hi', alCerrar: () {}),
        idioma: ingles,
      ),
    );
    expect(find.byTooltip('Close notice'), findsOneWidget);
  });

  testWidgets('la galeria vacia explica en ingles', (tester) async {
    await tester.pumpWidget(
      conTemaPista(const GaleriaFotos(fotos: []), idioma: ingles),
    );
    expect(find.text('There are no photos yet.'), findsOneWidget);
  });

  testWidgets('el visor de documentos anuncia la carga en ingles', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        SizedBox(
          height: 600,
          child: VisorPdf(
            cargar: () => Completer<Uint8List>().future,
            descripcion: 'Manual',
          ),
        ),
        idioma: ingles,
      ),
    );
    expect(find.bySemanticsLabel('Loading document'), findsOneWidget);
  });
}
