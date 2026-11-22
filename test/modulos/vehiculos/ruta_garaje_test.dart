import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final api = ApiFalsa()
    ..alPedirVehiculos = () async => [
      const Vehiculo(
        id: 1,
        vin: 'VIN1',
        modelo: 'CX-5',
        anio: 2024,
        marca: 'Mazda',
        placas: 'ABC-123',
        kilometraje: 12500,
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
  testWidgets('/garaje con sesion muestra los vehiculos de la API', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaGaraje);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGaraje), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  testWidgets('/garaje sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaGaraje);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('tocar una tarjeta del garaje abre su detalle', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaGaraje);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mazda CX-5 2024'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDetalleVehiculo), findsOneWidget);
    expect(find.text('Vehicle details'), findsOneWidget);
    expect(find.text('VIN1'), findsOneWidget);
  });

  testWidgets('/garaje/:id abre el detalle de ese vehiculo', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaDetalleVehiculo(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDetalleVehiculo), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  testWidgets('/garaje/:id con un id que no es numero no queda en blanco', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go('/garaje/abc');
    await tester.pumpAndSettle();
    expect(find.text('We could not find the vehicle'), findsOneWidget);
  });

  testWidgets('/garaje/:id sin sesion manda al inicio de sesion', (
    tester,
  ) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaDetalleVehiculo(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  test('exporta su ruta', () {
    expect(rutaDetalleVehiculo(7), '/garaje/7');
    expect(rutaGaraje, '/garaje');
    expect(rutasVehiculos, isNotEmpty);
  });
}
