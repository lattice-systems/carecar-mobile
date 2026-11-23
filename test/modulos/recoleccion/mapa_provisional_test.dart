import 'package:carecar_mobile/modulos/recoleccion/presentacion/provisional/mapa_provisional.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Widget _app({
  Coordenada? pin,
  required ValueChanged<Coordenada> alElegir,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    configuracionTeselasProvider.overrideWithValue(
      const ConfiguracionTeselas(
        urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
        atribucion: '© Mapas de prueba',
      ),
    ),
  ],
  child: conTemaPista(
    MapaProvisional(pin: pin, alElegir: alElegir),
    escenario: escenario,
  ),
);

void main() {
  testWidgets('muestra la atribución de las teselas', (tester) async {
    await tester.pumpWidget(_app(alElegir: (_) {}));
    await tester.pump();
    expect(find.text('© Mapas de prueba'), findsOneWidget);
  });

  testWidgets('tocar el mapa entrega la coordenada tocada', (tester) async {
    Coordenada? elegida;
    await tester.pumpWidget(_app(alElegir: (c) => elegida = c));
    await tester.pump();

    await tester.tapAt(tester.getCenter(find.byType(MapaProvisional)));
    // El mapa espera un instante por si el toque es el primero de un doble.
    await tester.pump(const Duration(milliseconds: 600));

    expect(elegida, isNotNull);
    expect(elegida!.esValida, isTrue);
  });

  testWidgets('con pin dibuja el marcador y lo anuncia', (tester) async {
    await tester.pumpWidget(
      _app(pin: const Coordenada(19.4326, -99.1332), alElegir: (_) {}),
    );
    await tester.pump();
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Pin en 19.4326, -99.1332')),
      findsOneWidget,
    );
  });

  testWidgets('sin pin no hay marcador y dice que falta', (tester) async {
    await tester.pumpWidget(_app(alElegir: (_) {}));
    await tester.pump();
    expect(find.byIcon(Icons.location_on), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Todavía no hay pin')), findsOneWidget);
  });

  for (final e in Escenario.values) {
    testWidgets('se dibuja sin desbordar ($e)', (tester) async {
      await tester.pumpWidget(_app(alElegir: (_) {}, escenario: e));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
