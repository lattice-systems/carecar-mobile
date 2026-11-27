import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/bitacora/bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'arnes_bitacora.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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
        repositorioBitacoraProvider.overrideWithValue(
          RepositorioBitacoraFake(
            gastos: [carga(1, DateTime(2026, 10, 1), 10000, 40, 800)],
          ),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('los caminos llevan el id y, si hay, el nombre del vehículo', () {
    expect(rutaBitacoraVehiculo(7), '/bitacora/7');
    expect(
      rutaBitacoraVehiculo(7, nombre: 'Aveo 2022'),
      '/bitacora/7?nombre=Aveo+2022',
    );
    expect(rutaEstadisticasBitacora(7), '/bitacora/7/estadisticas');
    expect(rutaExportarBitacora(7), '/bitacora/7/exportar');
  });

  testWidgets('/bitacora/:id abre la bitácora con el nombre recibido', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaBitacoraVehiculo(1, nombre: 'Mazda CX-5 2024'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaBitacora), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  testWidgets('/bitacora/:id sin sesión manda al inicio de sesión', (
    tester,
  ) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaBitacoraVehiculo(1));
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });

  testWidgets('estadísticas y exportación tienen su ruta', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaEstadisticasBitacora(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaEstadisticas), findsOneWidget);
    enrutadorDe(tester).go(rutaExportarBitacora(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaExportar), findsOneWidget);
  });

  testWidgets('un id que no es número no deja la pantalla en blanco', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go('/bitacora/abc');
    await tester.pumpAndSettle();
    expect(find.byType(PantallaBitacora), findsOneWidget);
  });

  testWidgets('el detalle del vehículo tiene la fila Bitácora', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaDetalleVehiculo(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logbook'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaBitacora), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });
}
