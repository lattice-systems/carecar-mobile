import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_adicionales.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_inspeccion.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_orden.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/proveedores_taller.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_taller.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
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
      overrides: [
        repositorioTallerProvider.overrideWithValue(RepositorioTallerFake()),
        imagenEvidenciaProvider.overrideWithValue(
          (_) => MemoryImage(pngDePrueba),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/taller/:ordenId abre la orden', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaOrdenTaller(41));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaOrden), findsOneWidget);
  });

  testWidgets('desde la orden se abren la inspeccion y los adicionales', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaOrdenTaller(41));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inspección multipunto'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaInspeccion), findsOneWidget);

    enrutadorDe(tester).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trabajos adicionales'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAdicionales), findsOneWidget);
  });

  testWidgets('los adicionales tambien llegan por enlace', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAdicionalesTaller(41));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAdicionales), findsOneWidget);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaInspeccionTaller(41));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });
}
