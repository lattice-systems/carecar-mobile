import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/lealtad.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_lealtad.dart';

Future<RepositorioLealtadFake> _montar(
  WidgetTester tester, {
  bool conSesion = true,
}) async {
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
  final repo = repoDeEjemplo();
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      idioma: const Locale('es'),
      overrides: [
        repositorioLealtadProvider.overrideWithValue(repo),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('/lealtad abre Mis puntos', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaLealtad);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLealtad), findsOneWidget);
  });

  testWidgets('de Mis puntos a cada pantalla del modulo', (tester) async {
    await _montar(tester);
    final destinos = {
      'Recompensas': PantallaRecompensas,
      'Mis canjes': PantallaCanjes,
      'Movimientos': PantallaMovimientos,
      'Referir a un amigo': PantallaReferir,
    };
    for (final MapEntry(key: texto, value: tipo) in destinos.entries) {
      enrutadorDe(tester).go(rutaLealtad);
      await tester.pumpAndSettle();
      await tester.tap(find.text(texto));
      await tester.pumpAndSettle();
      expect(find.byType(tipo), findsOneWidget, reason: texto);
    }
  });

  testWidgets('el enlace de un canje abre su codigo', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaCanje(2));
    await tester.pumpAndSettle();
    final pantalla = tester.widget<PantallaCanje>(find.byType(PantallaCanje));
    expect(pantalla.canjeId, 2);
    expect(find.text('5A6H4J78'), findsOneWidget);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaLealtad);
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });
}
