import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
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
      overrides: [
        repositorioAsistenciaProvider.overrideWithValue(
          RepositorioAsistenciaFake(),
        ),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        proveedorUbicacionProvider.overrideWithValue(UbicacionFalsa()),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('el acceso rapido SOS lleva a pedir ayuda, no a las guias', () {
    expect(rutaSos, rutaPedirAyuda);
    expect(rutaSos, isNot(rutaAsistenciaGuias));
  });

  testWidgets('la ruta abre la pantalla de pedir ayuda', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaPedirAyuda);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaPedirAyuda), findsOneWidget);
    expect(find.text('Desliza para pedir ayuda'), findsOneWidget);
  });

  testWidgets('sin sesion la ruta pide iniciar sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaPedirAyuda);
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });

  testWidgets(
    'el boton de la tarjeta de emergencias esta activo y abre la ruta',
    (tester) async {
      await _montar(tester);
      enrutadorDe(tester).go(rutaAsistenciaGuias);
      await tester.pumpAndSettle();
      expect(find.textContaining('estará disponible pronto'), findsNothing);
      await tester.tap(find.text('Pedir ayuda'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaPedirAyuda), findsOneWidget);
    },
  );

  testWidgets('desde pedir ayuda se regresa a las guias', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedir ayuda'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGuias), findsOneWidget);
  });
}
