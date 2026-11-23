import 'package:carecar_mobile/nucleo/privacidad/cubierta_en_segundo_plano.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => const MaterialApp(
  home: CubiertaEnSegundoPlano(child: Text('Datos del cliente')),
);

void main() {
  testWidgets('con la app activa no hay cubierta', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byKey(CubiertaEnSegundoPlano.cubierta), findsNothing);
    expect(find.text('Datos del cliente'), findsOneWidget);
  });

  for (final estado in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    testWidgets('al pasar a $estado se tapa el contenido', (tester) async {
      await tester.pumpWidget(_app());
      tester.binding.handleAppLifecycleStateChanged(estado);
      await tester.pump();
      expect(find.byKey(CubiertaEnSegundoPlano.cubierta), findsOneWidget);
    });
  }

  testWidgets('al volver a resumed se retira la cubierta', (tester) async {
    await tester.pumpWidget(_app());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byKey(CubiertaEnSegundoPlano.cubierta), findsNothing);
  });

  testWidgets('la cubierta no deja ver ni leer el contenido', (tester) async {
    await tester.pumpWidget(_app());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    // El contenido sigue montado (conserva estado) pero fuera del arbol
    // semantico y opaco.
    final cubierta = tester.widget<ColoredBox>(
      find.byKey(CubiertaEnSegundoPlano.cubierta),
    );
    expect(cubierta.color.a, 1.0);
  });
}
