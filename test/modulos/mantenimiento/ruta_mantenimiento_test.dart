import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/chip_pista.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

/// Lunes. El fake de citas deja sin cupo los dias que terminan en 0 o 5.
final _hoy = DateTime(2026, 11, 23);

Future<RepositorioMantenimientoFake> _montar(
  WidgetTester tester, {
  bool conSesion = true,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  final repo = RepositorioMantenimientoFake();
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        repositorioMantenimientoProvider.overrideWithValue(repo),
        repositorioCitasProvider.overrideWithValue(RepositorioCitasFake()),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        relojCitasProvider.overrideWithValue(() => _hoy),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  enrutadorDe(tester).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  test('las rutas se arman con el vehículo y el servicio', () {
    expect(rutaMantenimientoVehiculo(7), '/mantenimiento/7');
    expect(rutaServicioMantenimiento(7, 3), '/mantenimiento/7/servicio/3');
    expect(rutaKilometraje(7), '/mantenimiento/7/kilometraje');
  });

  test('ninguna ruta de mantenimiento es pública', () {
    expect(Rutas.publicas.contains(rutaMantenimientoVehiculo(7)), isFalse);
    expect(Rutas.publicas.contains(rutaKilometraje(7)), isFalse);
  });

  testWidgets('/mantenimiento/1 con sesión abre el plan', (tester) async {
    await _montar(tester);
    await _ir(tester, rutaMantenimientoVehiculo(1));
    expect(find.byType(PantallaPlanMantenimiento), findsOneWidget);
    expect(find.text('Servicio de 10,000 km'), findsWidgets);
  });

  testWidgets('sin sesión manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    await _ir(tester, rutaMantenimientoVehiculo(1));
    expect(pantallaDeAcceso, findsOneWidget);
    expect(find.byType(PantallaPlanMantenimiento), findsNothing);
  });

  testWidgets('tocar un servicio abre su detalle con el precio', (
    tester,
  ) async {
    await _montar(tester);
    await _ir(tester, rutaMantenimientoVehiculo(1));
    await _tocar(tester, find.text('Servicio de 15,000 km'));

    expect(find.byType(PantallaServicioMantenimiento), findsOneWidget);
    expect(find.text('Non-binding estimate'), findsOneWidget);
  });

  testWidgets('el detalle agenda con el vehículo y el motivo precargados', (
    tester,
  ) async {
    await _montar(tester);
    await _ir(tester, rutaServicioMantenimiento(1, 2));
    await _tocar(tester, find.text('Book this service'));

    expect(find.byType(PantallaAgendarCita), findsOneWidget);
    expect(
      tester.widget<ChipPista>(find.widgetWithText(ChipPista, 'Maintenance')),
      isA<ChipPista>().having((c) => c.seleccionado, 'seleccionado', isTrue),
    );
  });

  testWidgets('el héroe del plan agenda en un toque', (tester) async {
    await _montar(tester);
    await _ir(tester, rutaMantenimientoVehiculo(1));
    await _tocar(tester, find.text('Book this service'));

    expect(find.byType(PantallaAgendarCita), findsOneWidget);
    expect(
      tester.widget<ChipPista>(find.widgetWithText(ChipPista, 'Maintenance')),
      isA<ChipPista>().having((c) => c.seleccionado, 'seleccionado', isTrue),
    );
  });

  testWidgets('registrar km guarda, vuelve al plan y lo avisa', (tester) async {
    final repo = await _montar(tester);
    await _ir(tester, rutaMantenimientoVehiculo(1));
    await _tocar(tester, find.text('Log mileage'));
    expect(find.byType(PantallaRegistrarKm), findsOneWidget);

    await tester.enterText(find.byType(TextField), '9400');
    await _tocar(tester, find.text('Save mileage'));

    expect(repo.lecturas, [9400]);
    expect(find.byType(PantallaPlanMantenimiento), findsOneWidget);
    expect(
      find.text('Mileage saved. We updated your next service.'),
      findsOneWidget,
    );
    expect(find.text('9,400 km'), findsOneWidget);
  });
}
