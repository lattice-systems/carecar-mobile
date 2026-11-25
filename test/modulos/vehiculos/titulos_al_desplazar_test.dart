import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/ficha_tecnica_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _RepoFicha implements RepositorioFichaTecnica {
  @override
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo) async =>
      FichaTecnicaVehiculo(
        secciones: [
          for (var i = 0; i < 12; i++)
            SeccionFicha(
              titulo: 'Seccion $i',
              especificaciones: const [
                EspecificacionFicha(clave: 'Dato', valor: 'Valor'),
              ],
            ),
        ],
      );
}

Widget _app(Widget pantalla, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        repositorioFichaTecnicaProvider.overrideWithValue(_RepoFicha()),
      ],
      child: conTemaPista(pantalla, escenario: escenario),
    );

/// Pantalla chica (360 x 640) para que haya que desplazar.
Future<void> _pantallaChica(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  for (final escenario in Escenario.values) {
    testWidgets('garaje: el titulo no queda tapado al desplazar ($escenario)', (
      tester,
    ) async {
      await _pantallaChica(tester);
      await tester.pumpWidget(
        _app(const PantallaGaraje(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Mi garaje').hitTestable(), findsOneWidget);
    });

    testWidgets('ficha: el titulo no queda tapado al desplazar ($escenario)', (
      tester,
    ) async {
      await _pantallaChica(tester);
      await tester.pumpWidget(
        _app(const PantallaFichaTecnica(vehiculoId: 1), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Ficha técnica').hitTestable(), findsOneWidget);
    });

    testWidgets(
      'detalle: el titulo no queda tapado al desplazar ($escenario)',
      (tester) async {
        await _pantallaChica(tester);
        await tester.pumpWidget(
          _app(
            const PantallaDetalleVehiculo(vehiculoId: 1),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(find.text('Detalle del vehículo').hitTestable(), findsOneWidget);
        // La barra ya es opaca: nada se lee a traves del titulo.
        final barra = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(AppBar),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(barra.color!.a, 1);
      },
    );
  }
}
