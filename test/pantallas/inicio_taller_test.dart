import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_orden.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';
import '../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, RepositorioTallerFake repo) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  await sesion.iniciarSesion(
    correo: 'cliente1@example.com',
    contrasena: 'CareCar2026',
  );
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      interruptor: InterruptorModulos.todoV1,
      overrides: [repositorioTallerProvider.overrideWithValue(repo)],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con el auto en el taller Inicio lo dice y abre la orden', (
    tester,
  ) async {
    await _montar(tester, RepositorioTallerFake());

    final tarjeta = find.text('Tu Nissan March 2026 está en el taller');
    expect(tarjeta, findsOneWidget);
    await tester.tap(tarjeta);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaOrden), findsOneWidget);
  });

  testWidgets('sin orden abierta Inicio no muestra la tarjeta', (tester) async {
    await _montar(
      tester,
      RepositorioTallerFake(
        ordenes: [ordenDeEjemplo(etapa: EtapaTaller.entregado)],
      ),
    );

    expect(find.textContaining('está en el taller'), findsNothing);
    // El resto del inicio sí se pinta.
    expect(find.byType(InicioNuevo), findsOneWidget);
  });
}
