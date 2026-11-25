import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/pantalla_estadisticas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grafica.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'arnes_bitacora.dart';

Widget _pantalla(
  RepositorioBitacoraFake repo, {
  Escenario escenario = Escenario.claro,
}) => aplicacion(
  const PantallaEstadisticas(vehiculoId: 4),
  repo: repo,
  escenario: escenario,
);

void main() {
  prueba('con cargas muestra km/l, \$/km y su base de cálculo', (tester) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba())),
    );
    await tester.pumpAndSettle();
    expect(find.text('10.0 km/l'), findsOneWidget);
    expect(find.text(r'$2.10/km'), findsOneWidget);
    expect(
      find.text('Calculado con 400 km recorridos en 1 tramo entre cargas.'),
      findsOneWidget,
    );
  });

  prueba('grafica el gasto por mes con tabla alternativa (V2-M18.03)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba())),
    );
    await tester.pumpAndSettle();
    final grafica = tester.widget<Grafica>(find.byType(Grafica));
    expect(grafica.titulo, 'Gasto por mes');
    expect(grafica.puntos.map((p) => p.valor), [1640, 80]);
    expect(grafica.puntos.first.etiqueta, 'octubre de 2026');
    // La tabla con los mismos datos se abre con el botón.
    await tester.tap(find.text('Ver como tabla'));
    await tester.pumpAndSettle();
    expect(find.text(r'$1,640.00'), findsOneWidget);
    expect(find.text(r'$80.00'), findsOneWidget);
  });

  prueba('con menos de 2 cargas explica por qué no hay rendimiento', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pantalla(
        RepositorioBitacoraFake(
          gastos: [carga(1, DateTime(2026, 10, 1), 10000, 40, 800)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay rendimiento'), findsOneWidget);
    expect(
      find.textContaining('necesitamos al menos 2 cargas'),
      findsOneWidget,
    );
    expect(find.textContaining('Tienes 1 carga.'), findsOneWidget);
  });

  prueba('sin gastos lo dice en lugar de mostrar una gráfica vacía', (
    tester,
  ) async {
    await tester.pumpWidget(_pantalla(RepositorioBitacoraFake()));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay gastos'), findsOneWidget);
    expect(find.byType(Grafica), findsNothing);
  });

  prueba('un fallo de red ofrece reintentar', (tester) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<EstadoError>(find.byType(EstadoError)).causa,
      CausaError.sinConexion,
    );
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('se ve completa con ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _pantalla(
          RepositorioBitacoraFake(gastos: gastosDePrueba()),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
