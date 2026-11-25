import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
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

Future<void> _montar(WidgetTester tester, Escenario escenario) async {
  tester.view.physicalSize = const Size(360, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(escenario));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

const _destinos = [
  'Ficha técnica',
  'Historial de servicios',
  'Mantenimiento',
  'Bitácora',
];

/// El grupo de lista que lleva el encabezado «Tu auto».
Finder _grupoTuAuto() =>
    find.byWidgetPredicate((w) => w is GrupoLista && w.encabezado == 'Tu auto');

void main() {
  // V2-T02.23: la navegación a pantallas hijas es una lista con chevron, como
  // en Privacidad y Mantenimiento, no una cuadrícula de tarjetas iguales con
  // icono en medallón (otro lenguaje que el resto de la app).
  for (final escenario in Escenario.values) {
    testWidgets(
      'Tu auto: filas de una lista agrupada, una bajo otra ($escenario)',
      (tester) async {
        await _montar(tester, escenario);

        final grupo = _grupoTuAuto();
        expect(grupo, findsOneWidget);
        final filas = (tester.widget(grupo) as GrupoLista).filas;
        expect([for (final f in filas) f.titulo], _destinos);
        for (final f in filas) {
          expect(f.alToque, isNotNull, reason: f.titulo);
          expect(f.icono, isNotNull, reason: f.titulo);
        }

        // Una fila bajo la otra, todas del mismo ancho.
        final cajas = [
          for (final nombre in _destinos)
            tester.getRect(
              find.descendant(of: grupo, matching: find.text(nombre)),
            ),
        ];
        for (var i = 1; i < cajas.length; i++) {
          expect(cajas[i].top, greaterThan(cajas[i - 1].bottom - 0.5));
          expect(cajas[i].left, closeTo(cajas[0].left, 0.5));
        }
        // Ya no es una cuadrícula.
        expect(find.byType(GridView), findsNothing);
      },
    );
  }

  testWidgets('Tu auto: cada fila es un botón con su nombre', (tester) async {
    final semantica = tester.ensureSemantics();
    await _montar(tester, Escenario.claro);
    for (final nombre in _destinos) {
      expect(find.bySemanticsLabel(nombre), findsOneWidget, reason: nombre);
    }
    semantica.dispose();
  });
}
