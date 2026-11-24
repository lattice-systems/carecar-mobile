import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/pantalla_ticket.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/proveedores_historial.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Widget _app(
  RepositorioHistorialFake repo, {
  Future<void> Function(Uint8List, String)? compartir,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioHistorialProvider.overrideWithValue(repo),
    compartirTicketProvider.overrideWithValue(
      compartir ?? (bytes, nombre) async {},
    ),
  ],
  child: conTemaPista(
    const PantallaTicket(servicioId: 21),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('muestra mano de obra y refacciones con cantidad por precio', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.text('Ticket'), findsOneWidget);
    expect(find.text('Cambio de aceite'), findsOneWidget);
    expect(find.text(r'1 × $450.00'), findsOneWidget);
    expect(find.text('Filtro de aceite'), findsOneWidget);
    expect(find.text(r'2 × $175.50'), findsOneWidget);
    expect(find.text(r'$351.00'), findsOneWidget);
    expect(find.text(r'4 × $120.25'), findsOneWidget);
    expect(find.text(r'$481.00'), findsOneWidget);
  });

  _prueba('la mano de obra mas las refacciones dan el total', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.text(r'$832.00'), findsOneWidget);
    expect(find.text(r'$1,105.17'), findsOneWidget);
    expect(find.text(r'$176.83'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsOneWidget);
    expect(find.text('Los precios incluyen IVA.'), findsOneWidget);
    expect(find.textContaining('no cuadran'), findsNothing);
  });

  _prueba('comparte el PDF del ticket con su nombre', (tester) async {
    final repo = RepositorioHistorialFake();
    Uint8List? compartido;
    String? nombre;
    await tester.pumpWidget(
      _app(
        repo,
        compartir: (bytes, archivo) async {
          compartido = bytes;
          nombre = archivo;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartir PDF'));
    await tester.pumpAndSettle();

    expect(repo.pdfsPedidos, [21]);
    expect(nombre, 'ticket-21.pdf');
    expect(String.fromCharCodes(compartido!.take(5)), '%PDF-');
  });

  _prueba('si no se puede compartir lo avisa', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioHistorialFake(),
        compartir: (bytes, archivo) async => throw const SinConexion(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartir PDF'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos descargar el PDF. Intenta de nuevo.'),
      findsOneWidget,
    );
  });

  _prueba('sin conexion ofrece reintentar', (tester) async {
    final repo = RepositorioHistorialFake()..falla = const SinConexion();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Cambio de aceite'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    _prueba('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioHistorialFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });
  }
}
