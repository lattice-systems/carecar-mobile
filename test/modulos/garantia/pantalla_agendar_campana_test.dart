import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/repositorio_garantia.dart';
import 'package:carecar_mobile/modulos/garantia/presentacion/pantalla_agendar_campana.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector_franja.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_garantia.dart';

const _pantalla = PantallaAgendarCampana(vehiculoId: 5, campanaId: 7);

Finder get _confirmar => find.widgetWithText(BotonPildora, 'Agendar');

BotonPildora _botonConfirmar(WidgetTester tester) =>
    tester.widget<BotonPildora>(_confirmar);

Future<RepositorioGarantiaFake> _montar(
  WidgetTester tester, {
  RepositorioGarantiaFake? repo,
  RepositorioCitasFake? citas,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) async {
  final garantia =
      repo ?? RepositorioGarantiaFake(campanas: campanasDeEjemplo());
  await tester.pumpWidget(
    appGarantia(
      _pantalla,
      garantia,
      citas: citas,
      escenario: escenario,
      ancho: ancho,
    ),
  );
  await tester.pumpAndSettle();
  return garantia;
}

Future<void> _elegir(WidgetTester tester) async {
  await tester.ensureVisible(find.bySemanticsLabel('26 de noviembre'));
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsLabel('26 de noviembre'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('15:00 · 2 lugares'));
  await tester.pumpAndSettle();
}

Future<void> _confirmarCita(WidgetTester tester) async {
  await tester.ensureVisible(_confirmar);
  await tester.pumpAndSettle();
  await tester.tap(_confirmar);
  await tester.pumpAndSettle();
}

void main() {
  pruebaGarantia('dice que campana se agenda', (tester) async {
    await _montar(tester);
    expect(find.text('Agendar campaña'), findsWidgets);
    expect(find.text('Bolsa de aire del conductor'), findsWidgets);
  });

  pruebaGarantia('sin dia elegido no hay horarios ni se puede agendar', (
    tester,
  ) async {
    await _montar(tester);
    expect(find.text('Elige un día para ver sus horarios.'), findsOneWidget);
    expect(find.byType(SelectorFranja), findsNothing);
    expect(_botonConfirmar(tester).alPresionar, isNull);
  });

  pruebaGarantia('el dia sin cupo no se puede elegir', (tester) async {
    await _montar(tester);
    final sinCupo = find.bySemanticsLabel('25 de noviembre, sin cupo');
    expect(sinCupo, findsOneWidget);
    await tester.tap(sinCupo);
    await tester.pumpAndSettle();
    expect(find.byType(SelectorFranja), findsNothing);
  });

  pruebaGarantia('elegido dia y hora agenda la campana (V2-M10.03)', (
    tester,
  ) async {
    final repo = await _montar(tester);
    await _elegir(tester);
    expect(_botonConfirmar(tester).alPresionar, isNotNull);

    await _confirmarCita(tester);

    expect(repo.agendadas, hasLength(1));
    final (vehiculoId, campanaId, _, fecha) = repo.agendadas.single;
    expect(vehiculoId, 5);
    expect(campanaId, 7);
    expect(fecha, DateTime(2026, 11, 26));
    expect(find.text('Listo, tu cita quedó agendada'), findsOneWidget);
    expect(find.textContaining('Te esperamos el'), findsOneWidget);
    expect(find.text('Ver comprobante'), findsOneWidget);
    expect(find.text('Volver a la campaña'), findsOneWidget);
    expect(
      repo.campanasActuales.firstWhere((c) => c.id == 7).estado,
      EstadoCampana.agendada,
    );
  });

  for (final (motivo, mensaje) in [
    (MotivoRechazoCampana.sinCupo, 'Ese horario se llenó. Elige otro.'),
    (
      MotivoRechazoCampana.citaDuplicada,
      'Tu auto ya tiene una cita ese día. Elige otro día.',
    ),
    (MotivoRechazoCampana.yaAgendada, 'Esta campaña ya está agendada.'),
  ]) {
    pruebaGarantia('si se rechaza por $motivo lo explica', (tester) async {
      final repo = await _montar(
        tester,
        repo: RepositorioGarantiaFake(
          campanas: campanasDeEjemplo(),
          rechazo: motivo,
        ),
      );
      await _elegir(tester);
      await _confirmarCita(tester);

      expect(find.widgetWithText(Aviso, mensaje), findsOneWidget);
      expect(find.text('Listo, tu cita quedó agendada'), findsNothing);
      expect(repo.agendadas, isEmpty);
    });
  }

  pruebaGarantia('si el horario se lleno hay que elegir otro', (tester) async {
    await _montar(
      tester,
      repo: RepositorioGarantiaFake(
        campanas: campanasDeEjemplo(),
        rechazo: MotivoRechazoCampana.sinCupo,
      ),
    );
    await _elegir(tester);
    await _confirmarCita(tester);
    expect(_botonConfirmar(tester).alPresionar, isNull);
  });

  pruebaGarantia('un error inesperado se explica sin perder lo elegido', (
    tester,
  ) async {
    final repo = await _montar(tester);
    await _elegir(tester);
    repo.campanasActuales = [];
    await _confirmarCita(tester);

    expect(
      find.widgetWithText(Aviso, 'No pudimos agendar. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(_botonConfirmar(tester).alPresionar, isNotNull);
  });

  pruebaGarantia('si el taller no tiene cupo en todo el rango lo dice', (
    tester,
  ) async {
    await _montar(
      tester,
      citas: RepositorioCitasFake(franjas: const [], reloj: () => hoyGarantia),
    );
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(
      find.text(
        'El taller no tiene horarios libres por ahora. Intenta más tarde.',
      ),
      findsOneWidget,
    );
  });

  pruebaGarantia('si no carga la agenda deja reintentar', (tester) async {
    await _montar(
      tester,
      citas: RepositorioCitasFake(
        error: const SinConexion('sin red'),
        reloj: () => hoyGarantia,
      ),
    );
    expect(find.byType(EstadoError), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    pruebaGarantia('se ve sin desbordes en $escenario', (tester) async {
      await _montar(tester, escenario: escenario);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('en 320 pasa la auditoria con la excepcion aceptada del '
      'calendario: dias de 40 x 48 (V2-M20.02, V2-M20.03 y V2-M20.08)', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await _montar(tester, escenario: escenario, ancho: anchoTelefonoChico);
      expect(tester.takeException(), isNull, reason: escenario.name);
      if (escenario == Escenario.letraGrande) continue;
      final semantica = tester.ensureSemantics();
      await expectLater(
        tester,
        meetsGuideline(
          const MinimumTapTargetGuideline(
            size: Size(40, 48),
            link: 'https://www.w3.org/TR/WCAG22/#target-size-minimum',
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantica.dispose();
    }
  });
}
