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

  testWidgets('el camino del cambio obligatorio es el que espera el guardia', (
    tester,
  ) async {
    // Si este camino no coincidiera con `Rutas.cambiarContrasena`, el guardia
    // mandaria a una ruta que no existe y el cliente quedaria en blanco con
    // la contrasena temporal sin cambiar.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controladorSesionProvider.overrideWithValue(
            ControladorSesion(ApiFalsa(), AlmacenEnMemoria()),
          ),
          repositorioAccesoProvider.overrideWithValue(RepositorioAccesoFake()),
        ],
        child: MaterialApp.router(
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          routerConfig: GoRouter(
            initialLocation: Rutas.cambiarContrasena,
            routes: rutasAcceso,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PantallaCambiarContrasena), findsOneWidget);
  });

  testWidgets('las cuatro rutas del modulo no comparten camino', (
    tester,
  ) async {
    final caminos = rutasAcceso.whereType<GoRoute>().map((r) => r.path);
    expect(caminos.toSet().length, caminos.length);
    expect(
      caminos,
      containsAll([
        Rutas.acceso,
        Rutas.cambiarContrasena,
        Rutas.recuperar,
        Rutas.restablecer,
      ]),
    );
  });

  testWidgets('el enlace del correo llega a la pantalla con su token', (
    tester,
  ) async {
    // La vuelta completa del criterio: `carecar://restablecer?token=abc` lo
    // traduce el nucleo a esta ruta, y la pantalla tiene que recibir el token
    // por la consulta. Si el camino o el nombre del parametro no coincidieran,
    // el enlace del correo abriria una pantalla que dice «enlace roto».
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controladorSesionProvider.overrideWithValue(
            ControladorSesion(ApiFalsa(), AlmacenEnMemoria()),
          ),
          repositorioAccesoProvider.overrideWithValue(RepositorioAccesoFake()),
        ],
        child: MaterialApp.router(
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          routerConfig: GoRouter(
            initialLocation: '${Rutas.restablecer}?token=abc123',
            routes: rutasAcceso,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pantalla = tester.widget<PantallaNuevaContrasena>(
      find.byType(PantallaNuevaContrasena),
    );
    expect(pantalla.token, 'abc123');
    // Y por tanto pide la contrasena en vez de decir que el enlace no sirve.
    expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsOneWidget);
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
