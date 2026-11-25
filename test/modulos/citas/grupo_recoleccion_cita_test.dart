import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/componentes/grupo_recoleccion_cita.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _recoleccion = RecoleccionAgendada(
  direccionId: 1,
  costoTotal: 300,
  traslados: [
    TrasladoAgendado(
      id: 5,
      tipo: TipoTraslado.recoger,
      costo: 150,
      fecha: DateTime(2026, 12, 1),
      ventanaInicio: '07:00',
      ventanaFin: '09:00',
    ),
    TrasladoAgendado(
      id: 6,
      tipo: TipoTraslado.entregar,
      costo: 150,
      fecha: DateTime(2026, 12, 1),
      ventanaInicio: '17:00',
      ventanaFin: '19:00',
    ),
  ],
);

Future<GoRouter> _montar(WidgetTester tester) async {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: GrupoRecoleccionCita(recoleccion: _recoleccion),
          ),
        ),
      ),
      GoRoute(
        path: '/recoleccion/traslados/:id',
        builder: (_, estado) =>
            Scaffold(body: Text('seguimiento ${estado.pathParameters['id']}')),
      ),
    ],
  );
  addTearDown(enrutador.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: enrutador,
      theme: TemaPista.claro(),
      locale: const Locale('es'),
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
    ),
  );
  await tester.pumpAndSettle();
  return enrutador;
}

void main() {
  testWidgets('tocar recogemos abre el seguimiento de ese traslado', (
    tester,
  ) async {
    await _montar(tester);

    await tester.tap(find.text('Recogemos tu auto'));
    await tester.pumpAndSettle();

    expect(find.text('seguimiento 5'), findsOneWidget);
  });

  testWidgets('tocar entregamos abre el seguimiento del otro traslado', (
    tester,
  ) async {
    await _montar(tester);

    await tester.tap(find.text('Te lo entregamos'));
    await tester.pumpAndSettle();

    expect(find.text('seguimiento 6'), findsOneWidget);
  });

  testWidgets('invita a seguir el traslado y el costo no es tocable', (
    tester,
  ) async {
    await _montar(tester);

    expect(
      find.text('Toca un traslado para seguirlo en vivo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Costo de la recolección'));
    await tester.pumpAndSettle();
    expect(find.textContaining('seguimiento'), findsNothing);
  });
}
