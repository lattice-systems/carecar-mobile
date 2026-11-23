import 'dart:typed_data';

import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

final _ahora = DateTime(2026, 11, 23, 12);

Widget _visorFalso(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
) => const SizedBox(height: 600);

Widget _app(Widget pantalla, Escenario escenario) => ProviderScope(
  overrides: [
    repositorioCitasProvider.overrideWithValue(
      RepositorioCitasFake(reloj: () => _ahora),
    ),
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    relojCitasProvider.overrideWithValue(() => _ahora),
  ],
  child: conTemaPista(pantalla, escenario: escenario),
);

/// Pantalla chica, se desplaza al fondo y el titulo contraido debe seguir
/// siendo lo que recibe el toque en su centro: nada pasa por encima.
void _prueba(String nombre, Widget Function() pantalla, String titulo) {
  for (final escenario in Escenario.values) {
    testWidgets(
      '$nombre: el titulo no queda tapado al desplazar ($escenario)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(pantalla(), escenario));
        await tester.pumpAndSettle();
        for (final dy in [-250.0, -600.0, -2000.0]) {
          await tester.drag(find.byType(CustomScrollView).first, Offset(0, dy));
          await tester.pumpAndSettle();
          expect(find.text(titulo).hitTestable(), findsOneWidget);
        }
      },
    );
  }
}

void main() {
  _prueba('mis citas', () => const PantallaMisCitas(), 'Mis citas');
  _prueba('agendar', () => const PantallaAgendarCita(), 'Agendar cita');
  _prueba(
    'disponibilidad',
    () => const PantallaDisponibilidad(),
    'Disponibilidad del taller',
  );
  _prueba(
    'reprogramar',
    () => const PantallaReprogramarCita(citaId: 1),
    'Reprogramar cita',
  );
  _prueba(
    'comprobante',
    () =>
        const PantallaComprobanteCita(citaId: 7, fabricaVisorPdf: _visorFalso),
    'Comprobante de cita',
  );
}
