import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/portada_vehiculo.dart';
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

void main() {
  for (final escenario in Escenario.values) {
    testWidgets('detalle: la portada empieza debajo de la barra ($escenario)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(escenario));
      await tester.pumpAndSettle();
      final barra = tester.getRect(find.byType(AppBar));
      final pieza = tester.getRect(find.byType(PortadaVehiculo).last);
      expect(pieza.top, greaterThanOrEqualTo(barra.bottom));
    });
  }
}
