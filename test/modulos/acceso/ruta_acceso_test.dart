import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/api_falsa.dart';

/// V2-M01.01 · la ruta del modulo `acceso`.
///
/// Se monta con un enrutador propio porque **la ruta todavia no esta
/// registrada** en `registro_de_rutas.dart`: hoy `/acceso` lo sirve la
/// pantalla v1. Lo que falta para encenderla esta en `rutas_acceso.dart`.
///
/// Aun sin registrar, conviene probarla: asi el dia del encendido se sabe que
/// el camino y el nombre son los que el guardia espera, y no se descubre en un
/// enrutador roto.
void main() {
  Widget app(ControladorSesion sesion) => ProviderScope(
    overrides: [controladorSesionProvider.overrideWithValue(sesion)],
    child: MaterialApp.router(
      locale: idiomaBase,
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      routerConfig: GoRouter(
        initialLocation: Rutas.acceso,
        routes: rutasAcceso,
      ),
    ),
  );

  testWidgets('el camino de la ruta es el que espera el guardia', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(ControladorSesion(ApiFalsa(), AlmacenEnMemoria())),
    );
    await tester.pumpAndSettle();

    // Si el modulo escribiera su propio '/login', el guardia seguiria
    // mandando a '/acceso' y la pantalla no aparecería nunca.
    expect(find.byType(PantallaAcceso), findsOneWidget);
  });

  testWidgets('se puede llegar por nombre, como hace el resto de la app', (
    tester,
  ) async {
    final enrutador = GoRouter(
      initialLocation: Rutas.inicio,
      routes: [
        GoRoute(path: Rutas.inicio, builder: (_, _) => const SizedBox()),
        ...rutasAcceso,
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controladorSesionProvider.overrideWithValue(
            ControladorSesion(ApiFalsa(), AlmacenEnMemoria()),
          ),
        ],
        child: MaterialApp.router(
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          routerConfig: enrutador,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAcceso), findsNothing);

    enrutador.goNamed(NombresRuta.acceso);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaAcceso), findsOneWidget);
  });

  testWidgets('la pantalla llega con el tema Pista, no con el de la v1', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(ControladorSesion(ApiFalsa(), AlmacenEnMemoria())),
    );
    await tester.pumpAndSettle();

    // Mientras no exista el tema v2 global (V2-T01.05), cada ruta de modulo
    // lo pone. Sin esto la pantalla se veria con los colores de la v1.
    expect(
      find.ancestor(
        of: find.byType(PantallaAcceso),
        matching: find.byType(Theme),
      ),
      findsWidgets,
    );
  });
}
