import 'package:carecar_mobile/nucleo/diseno/componentes/superficie_liquida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  testWidgets('muestra su hijo y aplica desenfoque por defecto', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const SuperficieLiquida(
          child: Text('Contenido vítreo'),
        ),
      ),
    );

    expect(find.text('Contenido vítreo'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('sin desenfoque omite el BackdropFilter', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        const SuperficieLiquida(
          intensidadDesenfoque: 0,
          child: Text('Sin blur'),
        ),
      ),
    );

    expect(find.text('Sin blur'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
