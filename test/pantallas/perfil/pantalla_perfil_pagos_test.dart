import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/pagos/pagos.dart';
import 'package:carecar_mobile/pantallas/pantalla_ajustes.dart';
import 'package:carecar_mobile/pantallas/perfil/pantalla_perfil.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/envolver_con_shad.dart';

Future<void> _montarConEnrutador(WidgetTester tester) async {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
      GoRoute(
        path: rutaMisPagos,
        builder: (_, _) => const Scaffold(body: Text('mis pagos abiertos')),
      ),
      GoRoute(
        path: rutaMetodosPago,
        builder: (_, _) =>
            const Scaffold(body: Text('metodos de pago abiertos')),
      ),
    ],
  );
  addTearDown(enrutador.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: ShadApp.custom(
        theme: TemaCareCar.shad,
        appBuilder: (context) => MaterialApp.router(
          routerConfig: enrutador,
          theme: TemaCareCar.claro,
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          builder: (context, child) => ShadAppBuilder(child: child!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Key llave) async {
  final fila = find.byKey(llave);
  expect(fila, findsOneWidget);
  await tester.ensureVisible(fila);
  await tester.pumpAndSettle();
  await tester.tap(fila);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el perfil ofrece «Mis pagos» y la abre (V2-M08.07)', (
    tester,
  ) async {
    await _montarConEnrutador(tester);
    expect(find.text('Mis pagos'), findsOneWidget);

    await _tocar(tester, PantallaPerfil.botonMisPagos);

    expect(find.text('mis pagos abiertos'), findsOneWidget);
  });

  testWidgets('el perfil ofrece «Métodos de pago» y la abre (V2-M08.04)', (
    tester,
  ) async {
    await _montarConEnrutador(tester);
    expect(find.text('Métodos de pago'), findsOneWidget);

    await _tocar(tester, PantallaPerfil.botonMetodosPago);

    expect(find.text('metodos de pago abiertos'), findsOneWidget);
  });

  testWidgets('sin enrutador no hay filas que no sabrian abrir nada', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialAppConShad(
        home: PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaPerfil.botonMisPagos), findsNothing);
    expect(find.byKey(PantallaPerfil.botonMetodosPago), findsNothing);
  });
}
