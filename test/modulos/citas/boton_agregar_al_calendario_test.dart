import 'dart:typed_data';

import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/entrega_de_evento_fake.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/boton_agregar_al_calendario.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/proveedores_calendario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Widget _visorFalso(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
  int paginaInicial,
) => const SizedBox();

Future<void> _montar(WidgetTester tester, EntregaDeEventoFake entrega) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioCitasProvider.overrideWithValue(RepositorioCitasFake()),
        entregaDeEventoProvider.overrideWithValue(entrega),
      ],
      child: conTemaPista(
        const PantallaComprobanteCita(citaId: 7, fabricaVisorPdf: _visorFalso),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el comprobante ofrece agregar la cita al calendario', (
    tester,
  ) async {
    await _montar(tester, EntregaDeEventoFake());
    expect(find.byType(BotonAgregarAlCalendario), findsOneWidget);
    expect(find.text('Agregar al calendario'), findsOneWidget);
  });

  testWidgets('al tocar entrega un .ics con la direccion y el recordatorio', (
    tester,
  ) async {
    final entrega = EntregaDeEventoFake();
    await _montar(tester, entrega);
    await tester.ensureVisible(find.text('Agregar al calendario'));
    await tester.pump();
    await tester.tap(find.text('Agregar al calendario'));
    await tester.pumpAndSettle();

    expect(entrega.entregados, hasLength(1));
    final (ics, citaId) = entrega.entregados.single;
    expect(citaId, 7);
    expect(ics, contains('UID:cita-7@carecar'));
    // La direccion sale de la config de la agencia hasta que existan las
    // sucursales de V2-M27.02.
    expect(ics, contains('LOCATION:'));
    expect(ics, contains(Agencia.direccion.split(',').first));
    expect(ics, contains('TRIGGER:-PT60M'));
  });

  testWidgets('si el sistema falla avisa en linea y deja reintentar', (
    tester,
  ) async {
    await _montar(tester, EntregaDeEventoFake(fallo: StateError('x')));
    await tester.ensureVisible(find.text('Agregar al calendario'));
    await tester.pump();
    await tester.tap(find.text('Agregar al calendario'));
    await tester.pumpAndSettle();
    expect(
      find.text('No pudimos abrir tu calendario. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Agregar al calendario'), findsOneWidget);
  });
}
