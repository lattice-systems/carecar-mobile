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

Future<GoRouter> _montarConEnrutador(WidgetTester tester) async {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
      GoRoute(
        path: rutaDatosFiscales,
        builder: (_, _) =>
            const Scaffold(body: Text('datos fiscales abiertos')),
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
  testWidgets('el perfil ofrece «Datos fiscales» y la abre', (tester) async {
    await _montarConEnrutador(tester);

    final fila = find.byKey(PantallaPerfil.botonDatosFiscales);
    expect(fila, findsOneWidget);
    expect(find.text('Datos fiscales'), findsOneWidget);

    await tester.ensureVisible(fila);
    await tester.pumpAndSettle();
    await tester.tap(fila);
    await tester.pumpAndSettle();

    expect(find.text('datos fiscales abiertos'), findsOneWidget);
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

    expect(find.byKey(PantallaPerfil.botonDatosFiscales), findsNothing);
  });
}
