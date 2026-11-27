// V2-M27.03 · entradas a «Contacto» y «Sucursales» desde la sección Ayuda del
// perfil.
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/ayuda/ayuda.dart';
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

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Key llave) async {
  final fila = find.byKey(llave);
  await tester.ensureVisible(fila);
  await tester.pumpAndSettle();
  await tester.tap(fila);
  await tester.pumpAndSettle();
}

Future<void> _montarConRutas(WidgetTester tester) async {
  _pantallaAlta(tester);
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
      GoRoute(
        path: rutaContacto,
        builder: (_, _) => const Scaffold(body: Text('pantalla de contacto')),
      ),
      GoRoute(
        path: rutaSucursales,
        builder: (_, _) => const Scaffold(body: Text('pantalla de sucursales')),
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

void main() {
  testWidgets('«Contactar a la agencia» abre la pantalla de contacto', (
    tester,
  ) async {
    await _montarConRutas(tester);

    await _tocar(tester, PantallaPerfil.botonContactar);

    expect(find.text('pantalla de contacto'), findsOneWidget);
  });

  testWidgets('«Sucursales» abre la pantalla de sucursales', (tester) async {
    await _montarConRutas(tester);

    expect(find.text('Sucursales y horarios'), findsOneWidget);
    await _tocar(tester, PantallaPerfil.botonSucursales);

    expect(find.text('pantalla de sucursales'), findsOneWidget);
  });

  testWidgets('sin enrutador (la v1 suelta) «Contactar» sigue mostrando la '
      'hoja con los datos de la config', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(
      MaterialAppConShad(
        home: PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
    );
    await tester.pumpAndSettle();

    await _tocar(tester, PantallaPerfil.botonContactar);

    expect(find.text(Agencia.telefono), findsOneWidget);
    expect(find.text(Agencia.correo), findsOneWidget);
    // Sin enrutador no hay a dónde ir, así que no se ofrece «Sucursales».
    expect(find.byKey(PantallaPerfil.botonSucursales), findsNothing);
  });
}
