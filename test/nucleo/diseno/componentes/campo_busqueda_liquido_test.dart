import 'package:carecar_mobile/nucleo/diseno/componentes/campo_busqueda_liquido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  testWidgets('muestra la sugerencia y el icono de busqueda', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const CampoBusquedaLiquido(sugerencia: 'Buscar vehículo o servicio…'),
      ),
    );

    expect(find.text('Buscar vehículo o servicio…'), findsOneWidget);
    expect(find.byIcon(LucideIcons300.search), findsOneWidget);
  });

  testWidgets('al escribir muestra el boton de limpiar y responde', (
    tester,
  ) async {
    String? cambio;
    await tester.pumpWidget(
      conTemaPista(
        CampoBusquedaLiquido(
          sugerencia: 'Buscar…',
          alCambiar: (v) => cambio = v,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Sentra');
    await tester.pump();

    expect(cambio, 'Sentra');
    expect(find.byIcon(LucideIcons300.x), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons300.x));
    await tester.pump();

    expect(find.text('Sentra'), findsNothing);
  });
}
