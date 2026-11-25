import 'package:carecar_mobile/api/modelos/traslado.dart';
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

RecoleccionAgendada _con(EstadoTraslado recoger, EstadoTraslado entregar) =>
    RecoleccionAgendada(
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
          estado: recoger,
        ),
        TrasladoAgendado(
          id: 6,
          tipo: TipoTraslado.entregar,
          costo: 150,
          fecha: DateTime(2026, 12, 1),
          ventanaInicio: '17:00',
          ventanaFin: '19:00',
          estado: entregar,
        ),
      ],
    );

Future<GoRouter> _montar(
  WidgetTester tester, {
  RecoleccionAgendada? recoleccion,
  String? encabezado,
}) async {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: GrupoRecoleccionCita(
              recoleccion: recoleccion ?? _recoleccion,
              encabezado: encabezado,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/recoleccion/traslados/:id/checklist',
        builder: (_, estado) => Scaffold(
          body: Text(
            'checklist ${estado.pathParameters['id']} ${estado.uri.query}',
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

  testWidgets('sin checklist del chofer no ofrece filas de checklist', (
    tester,
  ) async {
    await _montar(
      tester,
      recoleccion: _con(EstadoTraslado.enCamino, EstadoTraslado.programado),
    );

    expect(find.text('Checklist al recoger'), findsNothing);
    expect(find.text('Checklist al entregar'), findsNothing);
    expect(find.text('Comparar recoger y entregar'), findsNothing);
  });

  testWidgets('recogido ofrece el checklist de recoger con el contrario', (
    tester,
  ) async {
    await _montar(
      tester,
      recoleccion: _con(EstadoTraslado.recogido, EstadoTraslado.programado),
    );

    expect(find.text('Checklist al entregar'), findsNothing);
    await tester.tap(find.text('Checklist al recoger'));
    await tester.pumpAndSettle();

    expect(find.text('checklist 5 contrario=6'), findsOneWidget);
  });

  testWidgets('entregado ofrece los dos checklists y la comparacion', (
    tester,
  ) async {
    await _montar(
      tester,
      recoleccion: _con(EstadoTraslado.entregado, EstadoTraslado.entregado),
    );

    expect(find.text('Checklist al recoger'), findsOneWidget);
    expect(find.text('Checklist al entregar'), findsOneWidget);

    await tester.tap(find.text('Checklist al entregar'));
    await tester.pumpAndSettle();
    expect(find.text('checklist 6 contrario=5&tipo=entregar'), findsOneWidget);
  });

  testWidgets('Comparar abre el checklist directo en la comparacion', (
    tester,
  ) async {
    await _montar(
      tester,
      recoleccion: _con(EstadoTraslado.entregado, EstadoTraslado.entregado),
    );

    await tester.tap(find.text('Comparar recoger y entregar'));
    await tester.pumpAndSettle();

    expect(find.text('checklist 5 contrario=6&ver=comparar'), findsOneWidget);
  });

  testWidgets('acepta un encabezado propio para distinguir cada cita', (
    tester,
  ) async {
    await _montar(tester, encabezado: 'Recolección · lun, 1 dic · 09:00');

    expect(find.text('Recolección · lun, 1 dic · 09:00'), findsOneWidget);
    expect(find.text('Recolección a domicilio'), findsNothing);
  });

  testWidgets('las filas de checklist se anuncian como botones', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    await _montar(
      tester,
      recoleccion: _con(EstadoTraslado.entregado, EstadoTraslado.entregado),
    );

    expect(find.bySemanticsLabel(RegExp('Checklist al recoger')), findsWidgets);
    manejador.dispose();
  });
}
