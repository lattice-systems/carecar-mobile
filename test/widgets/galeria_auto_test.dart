import 'package:carecar_mobile/widgets/galeria_auto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('las flechas avanzan y retroceden entre fotos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GaleriaAuto(
            modelo: 'Versa',
            alto: 200,
            extras: ['assets/autos/march.jpg', 'assets/autos/kicks.jpg'],
          ),
        ),
      ),
    );
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(GaleriaAuto.flechaAnterior), findsNothing);
    await tester.tap(find.byKey(GaleriaAuto.flechaSiguiente));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.byKey(GaleriaAuto.flechaAnterior));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
  });
}
