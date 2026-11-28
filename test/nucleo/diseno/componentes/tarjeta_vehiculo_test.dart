import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

/// V2-T02.27 · la tarjeta de vehículo es una tarjeta más del sistema: misma
/// superficie y sombra que las demás, sin degradado ni borde propios.
void main() {
  Widget tarjeta({VoidCallback? alToque, String? estado}) => conTemaPista(
    Center(
      child: TarjetaVehiculo(
        nombre: 'Nissan Versa 2025',
        detalle: 'Sense · Desde \$329,900',
        estado: estado,
        alToque: alToque,
      ),
    ),
  );

  testWidgets('usa la superficie del sistema, sin degradado', (tester) async {
    await tester.pumpWidget(tarjeta());

    final c = TokensPista.de(tester.element(find.byType(TarjetaVehiculo)))
        .colores;
    final decoraciones = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(TarjetaVehiculo),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((d) => d.decoration)
        .whereType<BoxDecoration>();
    expect(decoraciones.any((d) => d.color == c.superficie), isTrue);
    expect(decoraciones.every((d) => d.gradient == null), isTrue);
  });

  testWidgets('sin foto muestra la silueta y los textos', (tester) async {
    await tester.pumpWidget(tarjeta());

    expect(find.text('Nissan Versa 2025'), findsOneWidget);
    expect(find.text('Sense · Desde \$329,900'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el chevron aparece solo si se puede tocar', (tester) async {
    await tester.pumpWidget(tarjeta());
    expect(find.byIcon(LucideIcons300.chevronRight), findsNothing);

    var toques = 0;
    await tester.pumpWidget(tarjeta(alToque: () => toques++));
    expect(find.byIcon(LucideIcons300.chevronRight), findsOneWidget);
    await tester.tap(find.text('Nissan Versa 2025'));
    expect(toques, 1);
  });

  testWidgets('el estado va arriba, antes de la foto', (tester) async {
    await tester.pumpWidget(tarjeta(estado: 'Servicio en proceso'));

    final estado = tester.getTopLeft(find.text('Servicio en proceso'));
    final nombre = tester.getTopLeft(find.text('Nissan Versa 2025'));
    expect(estado.dy, lessThan(nombre.dy));
  });
}
