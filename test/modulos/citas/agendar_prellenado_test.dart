import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/componentes/tarjeta_vehiculo_cita.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/chip_pista.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/tema_pista.dart';

/// Lunes. El fake deja sin cupo los dias que terminan en 0 o 5.
final _hoy = DateTime(2026, 11, 23);

List<Override> _repos() => [
  repositorioCitasProvider.overrideWithValue(RepositorioCitasFake()),
  repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
  relojCitasProvider.overrideWithValue(() => _hoy),
];

Widget _app({int? vehiculoId, MotivoCita? motivo}) => ProviderScope(
  overrides: _repos(),
  child: conTemaPista(
    PantallaAgendarCita(vehiculoIdInicial: vehiculoId, motivoInicial: motivo),
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

bool _vehiculoElegido(WidgetTester tester, String nombre) => tester
    .widget<TarjetaVehiculoCita>(
      find.ancestor(
        of: find.text(nombre),
        matching: find.byType(TarjetaVehiculoCita),
      ),
    )
    .seleccionada;

bool _motivoElegido(WidgetTester tester, String texto) => tester
    .widget<ChipPista>(
      find.ancestor(of: find.text(texto), matching: find.byType(ChipPista)),
    )
    .seleccionado;

void main() {
  group('localizacionAgendarCita', () {
    test('sin datos es la ruta de siempre', () {
      expect(localizacionAgendarCita(), rutaAgendarCita);
    });

    test('lleva el vehículo y el motivo como parámetros', () {
      expect(
        localizacionAgendarCita(
          vehiculoId: 7,
          motivo: MotivoCita.mantenimiento,
        ),
        '/citas/agendar?vehiculoId=7&motivo=mantenimiento',
      );
    });

    test('con solo uno, solo ese viaja', () {
      expect(
        localizacionAgendarCita(vehiculoId: 7),
        '/citas/agendar?vehiculoId=7',
      );
    });
  });

  group('PantallaAgendarCita precargada', () {
    _prueba('llega con el vehículo y el motivo ya elegidos', (tester) async {
      await tester.pumpWidget(
        _app(vehiculoId: 1, motivo: MotivoCita.mantenimiento),
      );
      await tester.pumpAndSettle();

      expect(_vehiculoElegido(tester, 'Mazda CX-5 2024'), isTrue);
      expect(_motivoElegido(tester, 'Mantenimiento'), isTrue);
      expect(_motivoElegido(tester, 'Reparación'), isFalse);
    });

    _prueba('solo falta elegir el día y el horario para continuar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(vehiculoId: 1, motivo: MotivoCita.mantenimiento),
      );
      await tester.pumpAndSettle();
      await _tocar(tester, find.bySemanticsLabel('26 de noviembre'));
      await _tocar(tester, find.text('09:00 · 3 lugares'));
      await _tocar(tester, find.text('Revisar y confirmar'));

      expect(find.text('Resumen de tu cita'), findsOneWidget);
      expect(find.text('Mantenimiento'), findsWidgets);
    });

    _prueba('sin precarga nada viene elegido', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(_vehiculoElegido(tester, 'Mazda CX-5 2024'), isFalse);
      expect(_motivoElegido(tester, 'Mantenimiento'), isFalse);
    });

    _prueba('un vehículo que ya no está en el garaje se ignora', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(vehiculoId: 999, motivo: MotivoCita.mantenimiento),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_vehiculoElegido(tester, 'Mazda CX-5 2024'), isFalse);
      expect(_motivoElegido(tester, 'Mantenimiento'), isTrue);
    });
  });

  group('ruta /citas/agendar con parámetros', () {
    testWidgets('abre el flujo con el vehículo y el motivo precargados', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final api = ApiFalsa();
      final sesion = ControladorSesion(api, AlmacenEnMemoria());
      addTearDown(sesion.dispose);
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion, overrides: _repos()),
      );
      await tester.pumpAndSettle();

      enrutadorDe(tester).go(
        localizacionAgendarCita(
          vehiculoId: 1,
          motivo: MotivoCita.mantenimiento,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PantallaAgendarCita), findsOneWidget);
      expect(_vehiculoElegido(tester, 'Mazda CX-5 2024'), isTrue);
      expect(_motivoElegido(tester, 'Maintenance'), isTrue);
    });
  });
}
