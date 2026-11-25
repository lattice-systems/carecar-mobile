import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_taller.dart';

Widget _app(
  RepositorioTallerFake repo, {
  Escenario escenario = Escenario.claro,
  EventosEnVivoFake? eventos,
}) => appTaller(
  const SingleChildScrollView(child: TarjetaOrdenEnCurso()),
  repo,
  escenario: escenario,
  eventos: eventos,
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

  pruebaTaller('lista cambia a Listo con el total y el horario (V2-M04.06)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        RepositorioTallerFake(
          ordenes: [ordenDeEjemplo(etapa: EtapaTaller.listoParaEntrega)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu Nissan March 2026 está listo'), findsOneWidget);
    expect(find.text(r'Total a pagar $1,282.00'), findsOneWidget);
    expect(
      find.text('Recógelo el ${dia(DateTime(2026, 11, 25))} de 09:00 a 17:00'),
      findsOneWidget,
    );
    expect(find.widgetWithText(Insignia, 'Listo para entrega'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Avance de')), findsNothing);
  });

  pruebaTaller('cambia a Listo sola con el aviso en vivo (V2-M04.03)', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();
    expect(find.text('Tu Nissan March 2026 está en el taller'), findsOneWidget);

    repo.actualizar(ordenDeEjemplo(etapa: EtapaTaller.listoParaEntrega));
    eventos.emitir('orden', {'ordenId': 41, 'vehiculoId': 1});
    await tester.pumpAndSettle();

    expect(find.text('Tu Nissan March 2026 está listo'), findsOneWidget);
    expect(find.textContaining('está en el taller'), findsNothing);
  });

  pruebaTaller('al entregarse desaparece sola con el aviso en vivo', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();

    repo.actualizar(ordenDeEjemplo(etapa: EtapaTaller.entregado));
    eventos.emitir('orden', {'ordenId': 41, 'vehiculoId': 1});
    await tester.pumpAndSettle();

    expect(find.textContaining('Tu Nissan March 2026'), findsNothing);
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

    pruebaTaller('lista se ve sin desbordes en ${escenario.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          RepositorioTallerFake(
            ordenes: [ordenDeEjemplo(etapa: EtapaTaller.listoParaEntrega)],
          ),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
