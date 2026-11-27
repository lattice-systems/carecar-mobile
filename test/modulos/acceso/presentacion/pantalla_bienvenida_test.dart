import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/bienvenida/estado_bienvenida.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/app_enrutada.dart';

/// V2-M01.02 · la bienvenida del primer arranque.
///
/// Se prueba con la app enrutada y no con la pantalla sola, porque lo que pide
/// el criterio es justo lo que decide la guardia: que **aparezca** en el primer
/// arranque, antes del login, y que al saltarla no vuelva a estorbar.
void main() {
  Future<Widget> app(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    final api = ApiFalsa();
    return AppEnrutadaDePrueba(
      api: api,
      controlador: ControladorSesion(api, AlmacenEnMemoria()),
      overrides: [preferenciasProvider.overrideWithValue(prefs)],
      idioma: const Locale('es'),
    );
  }

  testWidgets('en el primer arranque aparece antes del acceso', (tester) async {
    await tester.pumpWidget(await app({}));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaBienvenida), findsOneWidget);
    expect(find.text('Tus autos, en un solo lugar'), findsOneWidget);
    expect(find.byType(PantallaLogin), findsNothing);
  });

  testWidgets('se puede saltar y entonces lleva al acceso', (tester) async {
    await tester.pumpWidget(await app({}));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(PantallaBienvenida.botonSaltar));
    await tester.pumpAndSettle();

    // `/acceso` lo sirve todavia la pantalla v1: el modulo `acceso` no esta
    // encendido (ver `rutas_acceso.dart`).
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaBienvenida), findsNothing);
  });

  testWidgets('si ya se vio, no vuelve a aparecer', (tester) async {
    await tester.pumpWidget(await app({claveBienvenidaVista: true}));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaBienvenida), findsNothing);
    // `/acceso` lo sirve todavia la pantalla v1: el modulo `acceso` no esta
    // encendido (ver `rutas_acceso.dart`).
    expect(find.byType(PantallaLogin), findsOneWidget);
  });
}
