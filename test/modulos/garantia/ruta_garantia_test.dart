import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/garantia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_garantia.dart';

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
      idioma: const Locale('es'),
      overrides: [
        repositorioGarantiaProvider.overrideWithValue(
          RepositorioGarantiaFake(
            garantia: garantiaDeEjemplo(),
            campanas: campanasDeEjemplo(),
          ),
        ),
        repositorioCitasProvider.overrideWithValue(
          RepositorioCitasFake(reloj: () => hoyGarantia),
        ),
        relojCitasProvider.overrideWithValue(() => hoyGarantia),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/garantia/:vehiculoId abre la garantia', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaGarantiaVehiculo(5));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGarantia), findsOneWidget);
  });

  testWidgets('de la garantia a las campanas, su detalle y agendar', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaGarantiaVehiculo(5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Campañas de seguridad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campañas de seguridad'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaCampanas), findsOneWidget);

    await tester.tap(find.text('Bolsa de aire del conductor'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaCampana), findsOneWidget);

    await tester.ensureVisible(find.text('Agendar atención'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agendar atención'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAgendarCampana), findsOneWidget);
  });

  testWidgets('el enlace de una campana abre su detalle', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaCampanaVehiculo(5, 7));
    await tester.pumpAndSettle();
    final pantalla = tester.widget<PantallaCampana>(
      find.byType(PantallaCampana),
    );
    expect(pantalla.vehiculoId, 5);
    expect(pantalla.campanaId, 7);
  });

  testWidgets('el enlace para agendar abre la campana pedida', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAgendarCampana(5, 7));
    await tester.pumpAndSettle();
    final pantalla = tester.widget<PantallaAgendarCampana>(
      find.byType(PantallaAgendarCampana),
    );
    expect(pantalla.vehiculoId, 5);
    expect(pantalla.campanaId, 7);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaCampanasVehiculo(5));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });
}
