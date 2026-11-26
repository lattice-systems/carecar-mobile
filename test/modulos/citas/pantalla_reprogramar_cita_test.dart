import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/fallos_agenda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes 23 de noviembre de 2026. El fake deja sin cupo los dias que terminan
/// en 0 o 5.
final _ahora = DateTime(2026, 11, 23, 12);

CitaCliente _cita(
  int id, {
  EstadoDeCita estado = EstadoDeCita.confirmada,
  int dia = 26,
}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  franjaId: 10,
  fecha: DateTime(2026, 11, dia),
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: estado,
);

RepositorioCitasFake _repo([List<CitaCliente>? citas]) =>
    RepositorioCitasFake(citas: citas ?? [_cita(1)], reloj: () => _ahora);

Widget _app(
  RepositorioCitasFake repo, {
  int citaId = 1,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioCitasProvider.overrideWithValue(repo),
    relojCitasProvider.overrideWithValue(() => _ahora),
  ],
  child: conTemaPista(
    PantallaReprogramarCita(citaId: citaId),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Elige el 27 de noviembre a las 11:00 (queda un lugar).
Future<void> _elegirNuevaFranja(WidgetTester tester) async {
  await _tocar(tester, find.bySemanticsLabel('27 de noviembre'));
  await _tocar(tester, find.text('11:00 · 1 lugar'));
}

void main() {
  _prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(_repo()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(
      find.bySemanticsLabel('Cargando tu cita y los horarios del taller'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  _prueba('muestra la cita actual y pide elegir una franja nueva', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_repo()));
    await tester.pumpAndSettle();
    expect(find.text('Reprogramar cita'), findsWidgets);
    expect(find.textContaining('Tu cita actual: jue, 26 nov'), findsOneWidget);
    expect(
      find.text('Elige un día y un horario nuevos para continuar.'),
      findsOneWidget,
    );
    final boton = find.text('Cambiar a este horario');
    expect(boton, findsOneWidget);
  });

  _prueba('V2-M02.13: reprograma y libera el horario anterior', (tester) async {
    final repo = _repo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _elegirNuevaFranja(tester);
    await _tocar(tester, find.text('Cambiar a este horario'));

    expect(find.textContaining('Cita reprogramada'), findsOneWidget);
    expect(
      find.textContaining('El horario anterior quedó libre'),
      findsOneWidget,
    );
    final movida = (await repo.misCitas()).citas.single;
    expect(movida.fecha, DateTime(2026, 11, 27));
    expect(movida.horaInicio, '11:00');
    expect(movida.estado, EstadoDeCita.confirmada);
  });

  _prueba('sin franja elegida no deja confirmar', (tester) async {
    final repo = _repo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Cambiar a este horario'));
    expect(find.textContaining('Cita reprogramada'), findsNothing);
    expect((await repo.misCitas()).citas.single.fecha, DateTime(2026, 11, 26));
  });

  _prueba('si la franja se llena ofrece las cercanas y las cambia', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_RepoQueSeLlena()));
    await tester.pumpAndSettle();
    await _elegirNuevaFranja(tester);
    await _tocar(tester, find.text('Cambiar a este horario'));
    expect(find.text('Ese horario ya no tiene lugar'), findsOneWidget);
    expect(find.textContaining('· 15:00'), findsOneWidget);

    await _tocar(tester, find.textContaining('· 15:00'));
    expect(find.text('Ese horario ya no tiene lugar'), findsNothing);
    await _tocar(tester, find.text('Cambiar a este horario'));
    expect(find.textContaining('Cita reprogramada'), findsOneWidget);
  });

  _prueba('si la cita ya no se puede cambiar lo explica', (tester) async {
    await tester.pumpWidget(_app(_RepoQueRechaza()));
    await tester.pumpAndSettle();
    await _elegirNuevaFranja(tester);
    await _tocar(tester, find.text('Cambiar a este horario'));
    expect(find.text('Esta cita ya no se puede cambiar.'), findsOneWidget);
  });

  _prueba('un error de red al reprogramar se explica y deja reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_RepoQueFalla()));
    await tester.pumpAndSettle();
    await _elegirNuevaFranja(tester);
    await _tocar(tester, find.text('Cambiar a este horario'));
    expect(
      find.text('No pudimos reprogramar tu cita. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Cambiar a este horario'), findsOneWidget);
  });

  _prueba('una cita que no existe o no se puede cambiar se explica', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_repo(), citaId: 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('No encontramos esta cita'), findsOneWidget);

    await tester.pumpWidget(
      _app(_repo([_cita(1, estado: EstadoDeCita.cancelada)])),
    );
    await tester.pumpAndSettle();
    expect(find.text('No encontramos esta cita'), findsOneWidget);
  });

  _prueba('si falla la carga ofrece reintentar y distingue sin conexion', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake(error: Exception('x'))));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.pumpWidget(
      _app(RepositorioCitasFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin conexion'), findsOneWidget);
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    _prueba('se arma sin desbordes en $escenario', (tester) async {
      await tester.pumpWidget(_app(_repo(), escenario: escenario));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Cambiar a este horario'), findsOneWidget);
    });
  }
}

/// El 27 a las 11:00 se llena justo al confirmar; las demas franjas siguen.
class _RepoQueSeLlena extends RepositorioCitasFake {
  _RepoQueSeLlena() : super(citas: [_cita(1)], reloj: () => _ahora);

  bool _llena = false;

  @override
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  }) async {
    if (franja.horaInicio == '11:00' && !_llena) {
      _llena = true;
      throw const FranjaSinCupo();
    }
    return super.reprogramar(citaId: citaId, franja: franja);
  }
}

class _RepoQueRechaza extends RepositorioCitasFake {
  _RepoQueRechaza() : super(citas: [_cita(1)], reloj: () => _ahora);

  @override
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  }) async => throw const CitaNoModificable();
}

class _RepoQueFalla extends RepositorioCitasFake {
  _RepoQueFalla() : super(citas: [_cita(1)], reloj: () => _ahora);

  @override
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  }) async => throw const SinConexion();
}
