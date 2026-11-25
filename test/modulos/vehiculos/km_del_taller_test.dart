import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Desde V2-T05.06 el contrato no trae la fecha del km en `GET /vehiculos`:
/// llega en el plan de mantenimiento (`kmActualizadoEn` + `kmFuente`).
PlanMantenimiento _plan({
  int? km = 9000,
  DateTime? fecha,
  FuenteKm? fuente = FuenteKm.taller,
}) => PlanMantenimiento(
  vehiculoId: 1,
  kmActual: km,
  kmActualizadoEn: fecha ?? DateTime(2026, 11, 20),
  kmFuente: fuente,
  servicios: const [],
);

ProviderContainer _contenedor(RepositorioMantenimientoFake repo) {
  final contenedor = ProviderContainer(
    overrides: [repositorioMantenimientoProvider.overrideWithValue(repo)],
  );
  addTearDown(contenedor.dispose);
  return contenedor;
}

Widget _app({
  required List<VehiculoGaraje> autos,
  required RepositorioMantenimientoFake plan,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioGarajeProvider.overrideWithValue(
      RepositorioGarajeFake(datos: autos),
    ),
    repositorioMantenimientoProvider.overrideWithValue(plan),
  ],
  child: conTemaPista(
    const PantallaDetalleVehiculo(vehiculoId: 1),
    escenario: escenario,
  ),
);

const _sinFecha = VehiculoGaraje(
  id: 1,
  modelo: 'CX-5',
  anio: 2024,
  kilometraje: 900,
  vin: 'VIN1',
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

void main() {
  group('kmDelTallerProvider', () {
    test('trae el km y la fecha cuando el taller es la fuente', () async {
      final c = _contenedor(RepositorioMantenimientoFake(plan: _plan()));

      final km = await c.read(kmDelTallerProvider(1).future);

      expect(km, (km: 9000, fecha: DateTime(2026, 11, 20)));
    });

    test('una lectura del cliente no se presenta como del taller', () async {
      final c = _contenedor(
        RepositorioMantenimientoFake(plan: _plan(fuente: FuenteKm.cliente)),
      );

      expect(await c.read(kmDelTallerProvider(1).future), isNull);
    });

    test('sin km no hay nada que atribuir al taller', () async {
      final c = _contenedor(
        RepositorioMantenimientoFake(plan: _plan(km: null)),
      );

      expect(await c.read(kmDelTallerProvider(1).future), isNull);
    });

    test('si el plan falla no rompe: simplemente no hay fecha', () async {
      final c = _contenedor(
        RepositorioMantenimientoFake(error: const SinConexion()),
      );

      expect(await c.read(kmDelTallerProvider(1).future), isNull);
    });
  });

  group('detalle del vehiculo sin fecha propia', () {
    _prueba('toma km y fecha del plan cuando el taller los dejo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          autos: const [_sinFecha],
          plan: RepositorioMantenimientoFake(plan: _plan()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('9,000 km'), findsOneWidget);
      expect(
        find.textContaining('Actualizado por el taller el'),
        findsOneWidget,
      );
      expect(find.text('Aún sin actualización del taller'), findsNothing);
    });

    _prueba('si la ultima lectura es del cliente no inventa fecha', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          autos: const [_sinFecha],
          plan: RepositorioMantenimientoFake(
            plan: _plan(km: 9500, fuente: FuenteKm.cliente),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('900 km'), findsOneWidget);
      expect(find.text('Aún sin actualización del taller'), findsOneWidget);
    });

    _prueba('sin conexion al plan sigue mostrando el km del vehiculo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          autos: const [_sinFecha],
          plan: RepositorioMantenimientoFake(error: const SinConexion()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('900 km'), findsOneWidget);
      expect(find.text('Aún sin actualización del taller'), findsOneWidget);
    });

    _prueba('la fecha propia del vehiculo manda sobre la del plan', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          autos: [
            VehiculoGaraje(
              id: 1,
              modelo: 'CX-5',
              anio: 2024,
              kilometraje: 900,
              vin: 'VIN1',
              kilometrajeActualizadoEn: DateTime(2026, 10, 20),
            ),
          ],
          plan: RepositorioMantenimientoFake(plan: _plan()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('900 km'), findsOneWidget);
      expect(find.textContaining('octubre'), findsOneWidget);
    });

    for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
      _prueba('cabe sin desbordar en $escenario', (tester) async {
        await tester.pumpWidget(
          _app(
            autos: const [_sinFecha],
            plan: RepositorioMantenimientoFake(plan: _plan()),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
