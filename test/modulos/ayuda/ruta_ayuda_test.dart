import 'package:carecar_mobile/api/modelos/sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/ayuda.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  if (conSesion) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(360, 2400);
    addTearDown(tester.view.reset);
  }
  final api = ApiFalsa()
    ..sucursalesApi = const [
      SucursalApi(
        id: 1,
        nombre: 'CareCar León',
        direccion: 'Blvd. Ejemplo 100',
        latitud: 21.125,
        longitud: -101.686,
        abiertaAhora: true,
      ),
    ];
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(AppEnrutadaDePrueba(api: api, controlador: sesion));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/sucursales con sesión muestra las sucursales de la API', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaSucursales);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaSucursales), findsOneWidget);
    expect(find.text('CareCar León'), findsOneWidget);
  });

  testWidgets('/sucursales sin sesión manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaSucursales);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaSucursales), findsNothing);
  });

  test('las sucursales no son una ruta pública', () {
    expect(Rutas.publicas.contains(rutaSucursales), isFalse);
  });

  test('exporta sus rutas', () {
    expect(rutaSucursales, '/sucursales');
    expect(rutasAyuda, isNotEmpty);
  });
}
