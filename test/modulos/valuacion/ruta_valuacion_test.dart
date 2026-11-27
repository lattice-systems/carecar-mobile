import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/presentacion/rutas_valuacion.dart'
    show rutaDeLaCalculadora, rutaDeMisEstimaciones;
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_valuacion.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  pantallaAlta(tester);
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
      overrides: sustitutos(
        repositorio: RepositorioValuacionFake(
          valuaciones: [valuacion()],
          puntos: [punto(11, 110000)],
        ),
        extra: [
          repositorioCitasProvider.overrideWithValue(citasConCupo()),
          relojCitasProvider.overrideWithValue(() => lunes),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('los destinos hacia catalogo coinciden con sus rutas', () {
    expect(rutaDeMisEstimaciones, rutaMisEstimaciones);
    expect(rutaDeLaCalculadora, rutaCalculadora);
  });

  testWidgets('de la lista al detalle, las fotos y la inspeccion', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaValuaciones);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMisValuaciones), findsOneWidget);

    await tester.tap(find.text('Nissan March 2020'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaValuacion), findsOneWidget);

    await tester.tap(find.text('Subir fotos guiadas'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaFotosValuacion), findsOneWidget);

    enrutadorDe(tester).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agendar inspección'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAgendarInspeccion), findsOneWidget);
  });

  testWidgets('/valuaciones/valor/5 no se lee como una valuacion', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaValorVehiculo(5));
    await tester.pumpAndSettle();

    final pantalla = tester.widget<PantallaValorVehiculo>(
      find.byType(PantallaValorVehiculo),
    );
    expect(pantalla.vehiculoId, 5);
    expect(find.byType(PantallaValuacion), findsNothing);
  });

  testWidgets('un id que no es numero cae en no encontrada', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go('$rutaValuaciones/abc');
    await tester.pumpAndSettle();
    expect(find.text('No encontramos esa valuación'), findsOneWidget);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaValuaciones);
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });
}
