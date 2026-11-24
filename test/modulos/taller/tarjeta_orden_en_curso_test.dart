import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/etapa_taller.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_taller.dart';

Widget _app(
  RepositorioTallerFake repo, {
  Escenario escenario = Escenario.claro,
}) => appTaller(
  const SingleChildScrollView(child: TarjetaOrdenEnCurso()),
  repo,
  escenario: escenario,
);

void main() {
  pruebaTaller('con una orden abierta dice que el auto esta en el taller', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    expect(find.text('Tu Nissan March 2026 está en el taller'), findsOneWidget);
    expect(
      find.text('En reparación · entrega ${hora(DateTime(2026, 11, 24, 18))}'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Avance de 43 %')), findsOneWidget);
    expect(
      find.widgetWithText(Insignia, '2 trabajos por aprobar'),
      findsOneWidget,
    );
  });

  pruebaTaller('al entregarse la orden la tarjeta desaparece', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioTallerFake(
          ordenes: [ordenDeEjemplo(etapa: EtapaTaller.entregado)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('está en el taller'), findsNothing);
  });

  pruebaTaller('si falla no ocupa lugar en Inicio', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioTallerFake()..falla = const SinConexion()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('está en el taller'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final escenario in Escenario.values) {
    pruebaTaller('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioTallerFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
