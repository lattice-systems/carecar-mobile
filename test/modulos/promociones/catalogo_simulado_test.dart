import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/promociones/datos/proveedores_publicaciones.dart';
import 'package:carecar_mobile/modulos/promociones/dominio/publicacion.dart';
import 'package:carecar_mobile/modulos/promociones/promociones.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final brillo in Brightness.values) {
    testWidgets(
      'abre la novedad simulada en ${brillo.name} con texto al 200 %',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        final enrutador = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: PromocionesInicio()),
            ),
            ...rutasPromociones,
          ],
        );
        addTearDown(enrutador.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              promocionesProvider.overrideWith((_) async => []),
              novedadesProvider.overrideWith(
                (_) async => [
                  Publicacion(
                    id: 1,
                    titulo: 'Novedad de prueba',
                    cuerpo: 'Contenido ficticio para la agencia.',
                    imagen: null,
                    fecha: DateTime.utc(2026, 1, 1),
                  ),
                ],
              ),
            ],
            child: MaterialApp.router(
              routerConfig: enrutador,
              locale: const Locale('es'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Novedades'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Novedad de prueba'));
        await tester.pumpAndSettle();
        expect(
          enrutador.routeInformationProvider.value.uri.path,
          '/novedades/1',
        );
        expect(find.byType(Image), findsOneWidget);
        final contenido = find.text('Contenido ficticio para la agencia.');
        await tester.scrollUntilVisible(
          contenido,
          120,
          scrollable: find.byType(Scrollable).last,
        );
        expect(contenido, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
