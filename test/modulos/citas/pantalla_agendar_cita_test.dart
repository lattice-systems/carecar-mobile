import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/cita_agendada.dart';
import 'package:carecar_mobile/modulos/citas/dominio/disponibilidad_taller.dart';
import 'package:carecar_mobile/modulos/citas/dominio/fallos_agenda.dart';
import 'package:carecar_mobile/modulos/citas/dominio/motivo_cita.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes. El fake deja sin cupo los dias que terminan en 0 o 5.
final _hoy = DateTime(2026, 11, 23);

Widget _app(
  RepositorioCitasFake citas, {
  RepositorioGaraje? garaje,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioCitasProvider.overrideWithValue(citas),
    repositorioGarajeProvider.overrideWithValue(
      garaje ?? RepositorioGarajeFake(),
    ),
    relojCitasProvider.overrideWithValue(() => _hoy),
  ],
  child: conTemaPista(const PantallaAgendarCita(), escenario: escenario),
);

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Elige vehiculo, el 26 de noviembre a las 09:00 y un motivo.
Future<void> _llenarFormulario(WidgetTester tester) async {
  await _tocar(tester, find.byType(DropdownButtonFormField<int>));
  await tester.tap(find.text('Mazda CX-5 2024').last);
  await tester.pumpAndSettle();
  await _tocar(tester, find.bySemanticsLabel('26 de noviembre'));
  await _tocar(tester, find.text('09:00 · 3 lugares'));
  await _tocar(tester, find.byType(DropdownButtonFormField<MotivoCita>));
  await tester.tap(find.text('Mantenimiento').last);
  await tester.pumpAndSettle();
}

Future<void> _irAlResumen(WidgetTester tester) async {
  await _llenarFormulario(tester);
  await _tocar(tester, find.text('Revisar y confirmar'));
}

void main() {
  testWidgets('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(
      find.bySemanticsLabel('Cargando tus vehículos y los horarios del taller'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  testWidgets('no deja continuar hasta elegir todo y dice que falta', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(
      find.text('Elige vehículo, día, horario y motivo para continuar.'),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Revisar y confirmar'));
    expect(find.text('Resumen de tu cita'), findsNothing);
  });

  testWidgets('con todo elegido muestra el resumen de la cita', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    expect(find.text('Resumen de tu cita'), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    expect(find.text('09:00 a 10:00'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.text('Confirmar cita'), findsOneWidget);
  });

  testWidgets('cambiar datos vuelve al formulario sin perder lo elegido', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    await _tocar(tester, find.text('Cambiar datos'));
    expect(find.text('Resumen de tu cita'), findsNothing);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
  });

  testWidgets('confirmar agenda y avisa que la cita quedo confirmada', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    await _tocar(tester, find.text('Confirmar cita'));
    expect(find.text('Cita confirmada'), findsOneWidget);
    expect(find.textContaining('09:00'), findsOneWidget);
  });

  testWidgets('sin cupo al confirmar ofrece franjas cercanas y las cambia', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_RepoQueSeLlena()));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    await _tocar(tester, find.text('Confirmar cita'));
    expect(find.text('Ese horario ya no tiene lugar'), findsOneWidget);
    expect(find.textContaining('· 11:00'), findsOneWidget);
    expect(find.textContaining('· 15:00'), findsOneWidget);

    await _tocar(tester, find.textContaining('· 11:00'));
    expect(find.text('Ese horario ya no tiene lugar'), findsNothing);
    expect(find.text('11:00 a 12:00'), findsOneWidget);

    await _tocar(tester, find.text('Confirmar cita'));
    expect(find.text('Cita confirmada'), findsOneWidget);
  });

  testWidgets('cita duplicada muestra la existente y no deja confirmar', (
    tester,
  ) async {
    final repo = _RepoQueFalla(
      CitaDuplicada(
        CitaAgendada(
          id: 3,
          vehiculoId: 1,
          fecha: DateTime(2026, 11, 26),
          horaInicio: '11:00',
          horaFin: '12:00',
        ),
      ),
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    await _tocar(tester, find.text('Confirmar cita'));
    expect(find.text('Ya tienes una cita ese día'), findsOneWidget);
    expect(find.textContaining('de 11:00 a 12:00'), findsOneWidget);
    expect(find.text('Confirmar cita'), findsNothing);
  });

  testWidgets('un error al agendar se explica y deja reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_RepoQueFalla(const SinConexion())));
    await tester.pumpAndSettle();
    await _irAlResumen(tester);
    await _tocar(tester, find.text('Confirmar cita'));
    expect(
      find.text('No pudimos agendar tu cita. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Confirmar cita'), findsOneWidget);
  });

  testWidgets('sin vehiculos explica por que no se puede agendar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioCitasFake(), garaje: RepositorioGarajeFake(datos: [])),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes vehículos'), findsOneWidget);
  });

  testWidgets('sin lugares en todo el rango explica por que no hay', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake(franjas: const [])));
    await tester.pumpAndSettle();
    expect(find.text('Sin lugares disponibles'), findsOneWidget);
  });

  testWidgets('si falla el garaje o la disponibilidad ofrece reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioCitasFake(), garaje: RepositorioGarajeFake(fallar: true)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
  });

  testWidgets('sin conexion lo dice distinto a un error generico', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioCitasFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    final estado = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(estado.causa, CausaError.sinConexion);
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    testWidgets('formulario y resumen sin desbordes en $escenario', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(RepositorioCitasFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await _irAlResumen(tester);
      expect(find.text('Resumen de tu cita'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

/// Se llena justo al confirmar la primera vez, como si otro cliente ganara.
class _RepoQueSeLlena extends RepositorioCitasFake {
  var _yaFallo = false;

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
  }) {
    if (!_yaFallo) {
      _yaFallo = true;
      return Future.error(const FranjaSinCupo());
    }
    return super.agendar(
      vehiculoId: vehiculoId,
      franja: franja,
      motivo: motivo,
    );
  }
}

class _RepoQueFalla extends RepositorioCitasFake {
  _RepoQueFalla(this._fallo);

  final Object _fallo;

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
  }) => Future.error(_fallo);
}
