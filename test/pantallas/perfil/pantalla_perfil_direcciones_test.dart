// V2-M17.06 · «Mis direcciones» desde el perfil.
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
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

Future<GoRouter> _montarConEnrutador(WidgetTester tester) async {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
      GoRoute(
        path: rutaMisDirecciones,
        builder: (_, _) => const Scaffold(body: Text('direcciones abiertas')),
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
  return enrutador;
}

void main() {
  testWidgets('el perfil ofrece «Mis direcciones» y la abre', (tester) async {
    await _montarConEnrutador(tester);

    final fila = find.byKey(PantallaPerfil.botonMisDirecciones);
    expect(fila, findsOneWidget);
    expect(find.text('Mis direcciones'), findsOneWidget);

    await tester.ensureVisible(fila);
    await tester.pumpAndSettle();
    await tester.tap(fila);
    await tester.pumpAndSettle();

    expect(find.text('direcciones abiertas'), findsOneWidget);
  });

  testWidgets('regresar de las direcciones vuelve al perfil', (tester) async {
    final enrutador = await _montarConEnrutador(tester);

    await tester.ensureVisible(find.byKey(PantallaPerfil.botonMisDirecciones));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaPerfil.botonMisDirecciones));
    await tester.pumpAndSettle();
    enrutador.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaPerfil.botonMisDirecciones), findsOneWidget);
  });

  testWidgets('sin enrutador no hay fila que no sabria abrir nada', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialAppConShad(
        home: PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaPerfil.botonMisDirecciones), findsNothing);
  });
}
