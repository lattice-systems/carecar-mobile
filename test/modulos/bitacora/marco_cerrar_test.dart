import 'package:carecar_mobile/modulos/bitacora/presentacion/componentes/marco_bitacora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_circular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

void main() {
  testWidgets('«Cerrar» del marco es un BotonCircular y sale de la pantalla '
      '(V2-T02.18)', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      const MarcoBitacora(titulo: 'Gasto', slivers: []),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.byType(BotonCircular), findsOneWidget);
    expect(find.byTooltip('Cerrar'), findsOneWidget);

    await tester.tap(find.byType(BotonCircular));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
    expect(find.byType(MarcoBitacora), findsNothing);
  });
}
