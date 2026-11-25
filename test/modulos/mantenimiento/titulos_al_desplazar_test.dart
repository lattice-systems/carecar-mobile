import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Un plan largo para que haya que desplazar en pantalla chica.
PlanMantenimiento _planLargo() {
  final base = RepositorioMantenimientoFake.planDeEjemplo();
  return PlanMantenimiento(
    vehiculoId: base.vehiculoId,
    kmActual: base.kmActual,
    kmActualizadoEn: base.kmActualizadoEn,
    kmFuente: base.kmFuente,
    promedioKmDiario: base.promedioKmDiario,
    proximo: base.proximo,
    servicios: [
      for (var i = 1; i <= 14; i++)
        ServicioMantenimiento(
          id: i,
          nombre: 'Servicio de ${i * 5},000 km',
          km: i * 5000,
          meses: i * 6,
          precioEstimado: 1500,
          conceptos: [for (var j = 1; j <= 12; j++) 'Concepto $j'],
          estado: i == 1 ? EstadoServicio.hecho : EstadoServicio.pendiente,
        ),
    ],
  );
}

Widget _app(Widget pantalla, Escenario escenario) => ProviderScope(
  overrides: [
    repositorioMantenimientoProvider.overrideWithValue(
      RepositorioMantenimientoFake(plan: _planLargo()),
    ),
  ],
  child: conTemaPista(pantalla, escenario: escenario),
);

/// Pantalla chica y se desplaza hasta el fondo: el título (contraído) debe
/// seguir siendo lo que recibe el toque en su centro, sin nada encima.
void _prueba(
  String nombre,
  Widget Function() pantalla,
  String titulo,
  Finder Function() desplazable,
) {
  for (final escenario in Escenario.values) {
    testWidgets(
      '$nombre: el título no queda tapado al desplazar ($escenario)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(pantalla(), escenario));
        await tester.pumpAndSettle();
        for (final dy in [-250.0, -700.0, -3000.0]) {
          await tester.drag(desplazable().first, Offset(0, dy));
          await tester.pumpAndSettle();
          expect(find.text(titulo).hitTestable(), findsOneWidget);
        }
      },
    );
  }
}

void main() {
  _prueba(
    'plan',
    () => const PantallaPlanMantenimiento(vehiculoId: 5),
    'Mantenimiento',
    () => find.byType(ListView),
  );
  _prueba(
    'servicio',
    () => const PantallaServicioMantenimiento(vehiculoId: 5, servicioId: 3),
    'Servicio de 15,000 km',
    () => find.byType(CustomScrollView),
  );
  _prueba(
    'registrar km',
    () => const PantallaRegistrarKm(vehiculoId: 5),
    'Registrar kilometraje',
    () => find.byType(CustomScrollView),
  );

  testWidgets('plan: la barra queda opaca al desplazar, sin ver a través', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(const PantallaPlanMantenimiento(vehiculoId: 5), Escenario.claro),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    final barra = tester.widget<Material>(
      find
          .descendant(of: find.byType(AppBar), matching: find.byType(Material))
          .first,
    );
    expect(barra.color!.a, 1);
  });
}
