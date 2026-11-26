import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/calendario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/chip_pista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/resultado_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_valuacion.dart';

const _pantalla = PantallaAgendarInspeccion(valuacionId: 1);

Widget _app(
  RepositorioValuacionFake repo, {
  RepositorioCitasFake? citas,
  Escenario escenario = Escenario.claro,
}) => app(
  _pantalla,
  repositorio: repo,
  escenario: escenario,
  extra: [
    repositorioCitasProvider.overrideWithValue(citas ?? citasConCupo()),
    relojCitasProvider.overrideWithValue(() => lunes),
  ],
);

Future<void> _elegirDiaYHora(WidgetTester tester) async {
  await tester.tap(
    find.descendant(of: find.byType(Calendario), matching: find.text('27')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ChipPista));
  await tester.pumpAndSettle();
}

BotonPildora _confirmar(WidgetTester tester) => tester.widget<BotonPildora>(
  find.widgetWithText(BotonPildora, 'Confirmar inspección'),
);

void main() {
  testWidgets('elegir dia y horario y confirmar agenda la inspeccion', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(_confirmar(tester).alPresionar, isNull);

    await _elegirDiaYHora(tester);
    await tester.tap(find.text('Confirmar inspección'));
    await tester.pumpAndSettle();

    expect(repo.agendadas, [(1, 3, DateTime(2026, 11, 27))]);
    expect(find.byType(ResultadoPantalla), findsOneWidget);
    expect(find.text('Inspección agendada'), findsOneWidget);
    expect(find.textContaining('a las 09:00'), findsOneWidget);
    expect(find.text('Ver mis citas'), findsOneWidget);
    expect(repo.valuaciones.single.estado, EstadoValuacion.citaAgendada);
  });

  for (final (motivo, texto) in [
    (MotivoRechazoValuacion.citaDuplicada, 'ya tiene una cita ese día'),
    (MotivoRechazoValuacion.noAgendable, 'ya no se puede agendar'),
  ]) {
    testWidgets('${motivo.name} se explica sin perder lo elegido', (
      tester,
    ) async {
      pantallaAlta(tester);
      final repo = RepositorioValuacionFake(
        valuaciones: [valuacion()],
        rechazo: motivo,
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await _elegirDiaYHora(tester);
      await tester.tap(find.text('Confirmar inspección'));
      await tester.pumpAndSettle();

      expect(find.textContaining(texto), findsOneWidget);
      expect(
        tester.widget<ChipPista>(find.byType(ChipPista)).seleccionado,
        isTrue,
      );
      expect(_confirmar(tester).alPresionar, isNotNull);
    });
  }

  testWidgets('sin cupo se explica, conserva el dia y pide otra hora', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = RepositorioValuacionFake(
      valuaciones: [valuacion()],
      rechazo: MotivoRechazoValuacion.sinCupo,
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _elegirDiaYHora(tester);
    await tester.tap(find.text('Confirmar inspección'));
    await tester.pumpAndSettle();

    expect(find.textContaining('se acaba de llenar'), findsOneWidget);
    expect(
      tester.widget<Calendario>(find.byType(Calendario)).seleccionado,
      DateTime(2026, 11, 27),
    );
    expect(_confirmar(tester).alPresionar, isNull);
  });

  testWidgets('sin red al confirmar lo dice sin perder lo elegido', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _elegirDiaYHora(tester);
    repo.falla = const SinConexion();
    await tester.tap(find.text('Confirmar inspección'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin conexión.'), findsOneWidget);
    expect(_confirmar(tester).alPresionar, isNotNull);
  });

  testWidgets('sin cupo en todo el rango lo dice', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioValuacionFake(valuaciones: [valuacion()]),
        citas: RepositorioCitasFake(franjas: const []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin horarios disponibles'), findsOneWidget);
  });

  testWidgets('carga y sin conexion', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioValuacionFake(valuaciones: [valuacion()]),
        citas: RepositorioCitasFake(error: const SinConexion()),
      ),
    );
    expect(find.bySemanticsLabel('Cargando la valuación'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('claro, oscuro y letra al 200 % con las guias', (tester) async {
    pantallaAlta(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(
          RepositorioValuacionFake(valuaciones: [valuacion()]),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      await _elegirDiaYHora(tester);
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });
}
