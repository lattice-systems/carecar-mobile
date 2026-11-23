import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/ficha_tecnica_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

class _FichaFalsa implements RepositorioFichaTecnica {
  @override
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo) async => null;
}

class _SinManual implements ServicioManuales {
  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async =>
      throw const FalloManual('sin manual');
}

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
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        repositorioFichaTecnicaProvider.overrideWithValue(_FichaFalsa()),
        servicioManualesProvider.overrideWithValue(_SinManual()),
      ],
    ),
  );
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

  testWidgets('el acceso Manuales del detalle abre el manual', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _montar(tester);
    enrutadorDe(tester).go(rutaDetalleVehiculo(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manuals'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaManual), findsOneWidget);
  });

  testWidgets('el acceso Ficha técnica del detalle abre la ficha', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _montar(tester);
    enrutadorDe(tester).go(rutaDetalleVehiculo(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical specs'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaFichaTecnica), findsOneWidget);
  });

  testWidgets('/garaje/:id/manual y /garaje/:id/ficha-tecnica existen', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaManualVehiculo(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaManual), findsOneWidget);
    enrutadorDe(tester).go(rutaFichaTecnicaVehiculo(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaFichaTecnica), findsOneWidget);
  });

  test('exporta su ruta', () {
    expect(rutaManualVehiculo(7), '/garaje/7/manual');
    expect(rutaFichaTecnicaVehiculo(7), '/garaje/7/ficha-tecnica');
    expect(rutaDetalleVehiculo(7), '/garaje/7');
    expect(rutaGaraje, '/garaje');
    expect(rutasVehiculos, isNotEmpty);
  });
}
