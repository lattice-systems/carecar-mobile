import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:carecar_mobile/nucleo/navegacion/registro_de_rutas.dart';
import 'package:carecar_mobile/pantallas/perfil/pantalla_perfil.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

/// V2-T01.10 con las pantallas de acceso de M01 que entraron despues: el
/// interruptor de Daniel y las rutas de la bienvenida, la cuenta desactivada,
/// mi contrasena y cambiar correo tienen que convivir.
void main() {
  /// Todos los caminos completos del arbol de rutas, hijas incluidas.
  List<String> caminos(List<RouteBase> rutas, [String base = '']) => [
    for (final r in rutas)
      if (r is GoRoute) ...[
        _unir(base, r.path),
        ...caminos(r.routes, _unir(base, r.path)),
      ],
  ];

  group('nunca dos rutas con el mismo camino', () {
    final interruptores = {
      'por defecto': InterruptorModulos.porDefecto,
      'todo v1': InterruptorModulos.todoV1,
      'todo v2': InterruptorModulos.todoV2,
      'acceso en v1': InterruptorModulos.desdeValores(v1: 'acceso'),
      'recuperacion en v2': InterruptorModulos.desdeValores(v2: 'recuperacion'),
    };
    for (final e in interruptores.entries) {
      test(e.key, () {
        final todos = caminos(rutasDeLaApp(e.value));
        final repetidos = {
          for (final c in todos)
            if (todos.where((o) => o == c).length > 1) c,
        };
        expect(repetidos, isEmpty);
      });
    }
  });

  Future<ControladorSesion> montar(
    WidgetTester tester, {
    bool conSesion = true,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final api = ApiFalsa();
    final sesion = ControladorSesion(api, AlmacenEnMemoria());
    addTearDown(sesion.dispose);
    if (conSesion) {
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
    }
    await tester.pumpWidget(
      AppEnrutadaDePrueba(
        api: api,
        controlador: sesion,
        interruptor: InterruptorModulos.porDefecto,
        idioma: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();
    return sesion;
  }

  testWidgets('con el acceso v2 por defecto se ve la cuenta desactivada', (
    tester,
  ) async {
    final sesion = await montar(tester);
    await sesion.terminarPorCuentaDesactivada();
    await tester.pumpAndSettle();

    expect(find.byType(PantallaCuentaDesactivada), findsOneWidget);
    expect(pantallaDeAcceso, findsNothing);
  });

  testWidgets('mi perfil y cambiar correo abren su pantalla v2 por defecto', (
    tester,
  ) async {
    await montar(tester);
    enrutadorDe(tester).go(rutaMiPerfil);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMiPerfil), findsOneWidget);

    enrutadorDe(tester).go(rutaCambiarCorreo);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaCambiarCorreo), findsOneWidget);
  });

  testWidgets('Cambiar contrasena de Ajustes abre la v2', (tester) async {
    await montar(tester);
    await tester.tap(find.byTooltip('Perfil y ajustes'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(PantallaPerfil.botonCambiarContrasena),
    );
    await tester.tap(find.byKey(PantallaPerfil.botonCambiarContrasena));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaMiContrasena), findsOneWidget);
  });
}

String _unir(String base, String hija) =>
    hija.startsWith('/') ? hija : '$base/$hija'.replaceAll('//', '/');
