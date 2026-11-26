import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Widget _app(Escenario escenario) => ProviderScope(
  overrides: [
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
  ],
  child: conTemaPista(
    const PantallaDetalleVehiculo(vehiculoId: 1),
    escenario: escenario,
  ),
);

Future<List<Rect>> _tarjetas(WidgetTester tester, Escenario escenario) async {
  tester.view.physicalSize = const Size(360, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(escenario));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  final tarjetas = find.byKey(const Key('accion-tu-auto'));
  expect(tarjetas, findsNWidgets(6));
  return [for (var i = 0; i < 6; i++) tester.getRect(tarjetas.at(i))];
}

void main() {
  for (final escenario in [Escenario.claro, Escenario.oscuro]) {
    testWidgets('Tu auto: cuadricula de dos columnas iguales ($escenario)', (
      tester,
    ) async {
      final r = await _tarjetas(tester, escenario);
      for (final t in r) {
        expect(t.width, closeTo(r[0].width, 0.5));
        expect(t.height, closeTo(r[0].height, 0.5));
      }
      for (var fila = 0; fila < 3; fila++) {
        final izquierda = r[fila * 2];
        final derecha = r[fila * 2 + 1];
        expect(derecha.top, closeTo(izquierda.top, 0.5));
        expect(izquierda.left, closeTo(r[0].left, 0.5));
        expect(derecha.left, closeTo(r[1].left, 0.5));
        if (fila > 0) {
          expect(izquierda.top, greaterThan(r[fila * 2 - 2].bottom - 0.5));
        }
      }
      expect(r[1].left, greaterThan(r[0].right - 0.5));
    });
  }

  testWidgets('Tu auto: con letra al 200 % pasa a una columna sin desbordar', (
    tester,
  ) async {
    final r = await _tarjetas(tester, Escenario.letraGrande);
    for (var i = 1; i < 6; i++) {
      expect(r[i].left, closeTo(r[0].left, 0.5));
      expect(r[i].width, closeTo(r[0].width, 0.5));
      expect(r[i].top, greaterThan(r[i - 1].bottom - 0.5));
    }
  });

  testWidgets('Tu auto: cada tarjeta es un boton con su nombre', (
    tester,
  ) async {
    await _tarjetas(tester, Escenario.claro);
    for (final nombre in [
      'Ficha técnica',
      'Historial de servicios',
      'Mantenimiento',
      'Bitácora',
      'Garantía',
      'Campañas de seguridad',
    ]) {
      expect(find.bySemanticsLabel(nombre), findsOneWidget);
    }
  });
}
