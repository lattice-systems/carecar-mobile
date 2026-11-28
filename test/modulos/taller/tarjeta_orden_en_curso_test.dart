import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

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
    // El avance se lee debajo de la barra y el lector lo dice en porcentaje.
    expect(find.text('Avance de 43 %'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Avance de 43 %')), findsOneWidget);
    expect(
      find.widgetWithText(Insignia, '2 trabajos por aprobar'),
      findsOneWidget,
    );
  });

  pruebaTaller('el icono va arriba, junto al título, y el chevron al centro', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    final tarjeta = tester.getRect(find.byType(TarjetaResumen));
    final icono = tester.getRect(find.byIcon(LucideIcons300.wrench));
    final titulo = tester.getRect(
      find.text('Tu Nissan March 2026 está en el taller'),
    );
    final chevron = tester.getRect(find.byIcon(LucideIcons300.chevronRight));
    // El icono arranca a la altura del título, no en medio de la tarjeta.
    expect(icono.center.dy, lessThan(tarjeta.center.dy));
    expect(icono.top, lessThanOrEqualTo(titulo.top + 8));
    // Lo único que sigue centrado es el chevron.
    expect(chevron.center.dy, greaterThan(icono.center.dy));
  });

  pruebaTaller('es la misma tarjeta de resumen que usa el resto del inicio', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    final tarjeta = find.byType(TarjetaResumen);
    expect(tarjeta, findsOneWidget);
    // Un solo nodo para el lector, con lo que pasa al tocarla y el avance.
    final nodo = tester.getSemantics(tarjeta);
    expect(nodo.hint, 'Ver el avance de tu orden');
    expect(nodo.value, '43 %');
    expect(nodo.label, contains('Tu Nissan March 2026 está en el taller'));
    semantica.dispose();
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
