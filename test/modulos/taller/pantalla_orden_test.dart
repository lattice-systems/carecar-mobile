import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/etapa_taller.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_orden.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/linea_de_tiempo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
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
  const PantallaOrden(ordenId: 41),
  repo,
  escenario: escenario,
  eventos: eventos,
);

void main() {
  pruebaTaller('muestra la etapa actual, su avance, la entrega y el asesor', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    expect(find.text('Tu orden'), findsOneWidget);
    expect(find.text('Nissan March 2026'), findsOneWidget);
    expect(find.text('En reparación'), findsWidgets);
    expect(find.text('Avance de 43 %'), findsOneWidget);
    expect(find.bySemanticsLabel('Avance de 43 %'), findsOneWidget);
    expect(find.text(hora(DateTime(2026, 11, 24, 18))), findsOneWidget);
    expect(find.text('Laura Méndez'), findsOneWidget);
  });

  pruebaTaller('la linea de tiempo trae cada etapa con su hora en orden', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    final linea = tester.widget<LineaDeTiempo>(find.byType(LineaDeTiempo));
    expect(linea.pasos.map((p) => p.titulo), [
      'Recibido',
      'Diagnóstico',
      'Esperando aprobación',
      'En reparación',
      'Control de calidad',
      'Lavado',
      'Listo para entrega',
      'Entregado',
    ]);
    expect(linea.pasos.map((p) => p.estado), [
      EstadoPaso.hecho,
      EstadoPaso.hecho,
      EstadoPaso.hecho,
      EstadoPaso.actual,
      EstadoPaso.pendiente,
      EstadoPaso.pendiente,
      EstadoPaso.pendiente,
      EstadoPaso.pendiente,
    ]);
    expect(linea.pasos.first.hora, horaCorta(DateTime(2026, 11, 24, 9, 30)));
    expect(linea.pasos[3].hora, horaCorta(DateTime(2026, 11, 24, 12, 30)));
    expect(
      linea.pasos[3].nota,
      'Cambio de balatas · entrega estimada '
      '${hora(DateTime(2026, 11, 24, 18))}',
    );
    expect(linea.pasos[4].hora, isNull);
    expect(
      find.bySemanticsLabel(RegExp(r'^Etapa 4 de 8, en curso, En reparación')),
      findsOneWidget,
    );
  });

  pruebaTaller('una etapa saltada no aparece en la linea de tiempo', (
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

    final linea = tester.widget<LineaDeTiempo>(find.byType(LineaDeTiempo));
    expect(linea.pasos.map((p) => p.titulo), isNot(contains('Lavado')));
    expect(linea.pasos.last.titulo, 'Entregado');
    expect(linea.pasos.last.estado, EstadoPaso.pendiente);
  });

  pruebaTaller('avisa los trabajos adicionales por aprobar', (tester) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    expect(find.byType(Aviso), findsOneWidget);
    expect(
      find.text('El taller te propone 2 trabajos adicionales'),
      findsOneWidget,
    );
    expect(find.text('2 por aprobar'), findsOneWidget);
    expect(find.text('3 puntos revisados'), findsOneWidget);
  });

  pruebaTaller('lista para entrega avisa el horario y el total (V2-M04.06)', (
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

    expect(find.text('Tu auto está listo'), findsOneWidget);
    expect(
      find.text('Recógelo el ${dia(DateTime(2026, 11, 25))} de 09:00 a 17:00'),
      findsOneWidget,
    );
    expect(find.text(r'$1,282.00'), findsOneWidget);
    expect(find.text('Total a pagar'), findsOneWidget);
    expect(find.text('Ver ticket'), findsOneWidget);
    expect(find.text('Revisar'), findsNothing);
    expect(find.text('Ver historial del vehículo'), findsNothing);
  });

  pruebaTaller('entregada lleva a su ticket y al historial (V2-M04.07)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        RepositorioTallerFake(
          ordenes: [ordenDeEjemplo(etapa: EtapaTaller.entregado)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ya recogiste tu auto'), findsOneWidget);
    expect(
      find.text('La orden quedó en el historial de tu vehículo con su ticket.'),
      findsOneWidget,
    );
    expect(find.text('Ver ticket'), findsOneWidget);
    expect(find.text('Ver historial del vehículo'), findsOneWidget);
    expect(find.text('Tu auto está listo'), findsNothing);
  });

  pruebaTaller('se actualiza sola cuando el taller la cambia (V2-M04.03)', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();
    expect(find.text('Tu auto está listo'), findsNothing);

    repo.actualizar(ordenDeEjemplo(etapa: EtapaTaller.listoParaEntrega));
    eventos.emitir('orden', {
      'ordenId': 41,
      'vehiculoId': 1,
      'estatus': 'TERMINADO',
      'etapa': 'LISTO_PARA_ENTREGA',
      'motivo': 'ETAPA',
    });
    await tester.pumpAndSettle();

    expect(find.text('Tu auto está listo'), findsOneWidget);
    final linea = tester.widget<LineaDeTiempo>(find.byType(LineaDeTiempo));
    expect(linea.pasos.last.titulo, 'Entregado');
    expect(linea.pasos[linea.pasos.length - 2].estado, EstadoPaso.actual);
  });

  pruebaTaller('un aviso de otra orden o de otra cosa no la vuelve a pedir', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();
    final consultas = repo.ordenesPedidas;

    eventos
      ..emitir('orden', {'ordenId': 99, 'vehiculoId': 1})
      ..emitir('asistencia.estado', {'solicitudId': 41});
    await tester.pumpAndSettle();

    expect(repo.ordenesPedidas, consultas);
  });

  pruebaTaller('al volver el canal tras una caida la vuelve a pedir', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();
    final consultas = repo.ordenesPedidas;

    eventos.emitir(eventoReconectado);
    await tester.pumpAndSettle();

    expect(repo.ordenesPedidas, consultas + 1);
  });

  pruebaTaller('si la recarga en vivo falla se queda la orden que se ve', (
    tester,
  ) async {
    final repo = RepositorioTallerFake();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(_app(repo, eventos: eventos));
    await tester.pumpAndSettle();
    final consultas = repo.ordenesPedidas;

    repo.falla = const SinConexion();
    eventos.emitir('orden', {'ordenId': 41, 'vehiculoId': 1});
    await tester.pumpAndSettle();

    expect(repo.ordenesPedidas, consultas + 1);
    expect(find.byType(EstadoError), findsNothing);
    expect(find.byType(LineaDeTiempo), findsOneWidget);
  });

  pruebaTaller('sin conexion ofrece reintentar', (tester) async {
    final repo = RepositorioTallerFake()..falla = const SinConexion();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byType(LineaDeTiempo), findsOneWidget);
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
