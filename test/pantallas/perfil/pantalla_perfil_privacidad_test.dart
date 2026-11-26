// V2-M22.01 y V2-M22.02 · «Privacidad y mis datos» desde el perfil.
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/privacidad/privacidad.dart';
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

/// La lista de Ajustes se construye perezosamente y la fila de privacidad va
/// casi al final: con una pantalla alta todas las filas existen.
void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _abrirAviso(WidgetTester tester) async {
  final fila = find.byKey(PantallaPerfil.botonPrivacidad);
  await tester.ensureVisible(fila);
  await tester.pumpAndSettle();
  await tester.tap(fila);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con enrutador abre Privacidad y mis datos, no el texto que trae '
      'la app', (tester) async {
    _pantallaAlta(tester);
    final enrutador = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
        ),
        GoRoute(
          path: rutaPrivacidad,
          builder: (_, _) =>
              const Scaffold(body: Text('privacidad y mis datos')),
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

    await _abrirAviso(tester);

    expect(find.text('privacidad y mis datos'), findsOneWidget);
    expect(find.text(Agencia.avisoPrivacidad), findsNothing);
  });

  testWidgets('sin enrutador (la v1 suelta) sigue mostrando el texto que la '
      'app trae', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(
      MaterialAppConShad(
        home: PantallaAjustes(api: ApiFalsa(), alCerrarSesion: () {}),
      ),
    );
    await tester.pumpAndSettle();

    await _abrirAviso(tester);

    expect(find.text(Agencia.avisoPrivacidad), findsOneWidget);
  });
}
