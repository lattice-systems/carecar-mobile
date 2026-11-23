import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/repositorio_citas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/calendario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector_franja.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes. El fake deja sin cupo los dias que terminan en 0 o 5: el 25 y el 30.
final _hoy = DateTime(2026, 11, 23);

Widget _app(RepositorioCitas repo, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [
        repositorioCitasProvider.overrideWithValue(repo),
        relojCitasProvider.overrideWithValue(() => _hoy),
      ],
      child: conTemaPista(const PantallaDisponibilidad(), escenario: escenario),
    );

void main() {
  testWidgets('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(
      find.bySemanticsLabel('Cargando disponibilidad del taller'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  testWidgets('muestra el calendario del mes de hoy', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(find.byType(Calendario), findsOneWidget);
    expect(find.text('noviembre de 2026'), findsOneWidget);
  });

  testWidgets('el dia sin cupo se anuncia y no se puede elegir', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    final sinCupo = find.bySemanticsLabel('25 de noviembre, sin cupo');
    expect(sinCupo, findsOneWidget);
    await tester.tap(sinCupo);
    await tester.pumpAndSettle();
    expect(find.byType(SelectorFranja), findsNothing);
  });

  testWidgets('el sabado y los dias pasados tampoco tienen cupo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('28 de noviembre, sin cupo'), findsOneWidget);
    expect(find.bySemanticsLabel('22 de noviembre, sin cupo'), findsOneWidget);
  });

  testWidgets('al elegir un dia con cupo muestra sus franjas con el cupo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(find.text('Elige un día para ver sus horarios.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('26 de noviembre'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectorFranja), findsOneWidget);
    expect(find.text('09:00 · 3 lugares'), findsOneWidget);
    expect(find.text('11:00 · 1 lugar'), findsOneWidget);
    expect(find.text('15:00 · 2 lugares'), findsOneWidget);
    expect(find.textContaining('Horarios del'), findsOneWidget);
  });

  testWidgets('se puede cambiar de mes y ver su disponibilidad', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('diciembre de 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('1 de diciembre'), findsOneWidget);
  });

  testWidgets('sin lugares en todo el rango explica por que no hay', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake(franjas: const [])));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Sin lugares disponibles'), findsOneWidget);
    expect(find.byType(Calendario), findsNothing);
  });

  testWidgets('un error generico ofrece reintentar y recarga', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(_RepoQueFallaLaPrimeraVez(() => llamadas++)));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(llamadas, 2);
    expect(find.byType(Calendario), findsOneWidget);
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
    testWidgets('se ve sin desbordes en $escenario', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioCitasFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('26 de noviembre'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

class _RepoQueFallaLaPrimeraVez extends RepositorioCitasFake {
  _RepoQueFallaLaPrimeraVez(this._alPedir);
  final void Function() _alPedir;
  int _n = 0;

  @override
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) {
    _alPedir();
    if (_n++ == 0) throw Exception('falla');
    return super.disponibilidad(desde: desde, hasta: hasta);
  }
}
