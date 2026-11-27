import 'dart:typed_data';

import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/ayuda/ayuda.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/repositorio_sucursales.dart';
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

class _RepoQueFalla implements RepositorioSucursales {
  @override
  Future<List<Sucursal>> sucursales() async => throw Exception('caido');
}

Future<void> _montar(
  WidgetTester tester,
  EntregaDeEventoFake entrega, {
  RepositorioSucursales? sucursales,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioCitasProvider.overrideWithValue(RepositorioCitasFake()),
        entregaDeEventoProvider.overrideWithValue(entrega),
        repositorioSucursalesProvider.overrideWithValue(
          sucursales ?? RepositorioSucursalesFake(),
        ),
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

  Future<String> tocarYLeerIcs(
    WidgetTester tester,
    EntregaDeEventoFake entrega,
  ) async {
    await tester.ensureVisible(find.text('Agregar al calendario'));
    await tester.pump();
    await tester.tap(find.text('Agregar al calendario'));
    await tester.pumpAndSettle();
    expect(entrega.entregados, hasLength(1));
    final (ics, citaId) = entrega.entregados.single;
    expect(citaId, 7);
    // Los renglones largos del .ics se parten; se juntan para leerlos.
    return ics.replaceAll('\r\n ', '');
  }

  testWidgets('al tocar entrega un .ics con la sucursal principal y el '
      'recordatorio', (tester) async {
    final entrega = EntregaDeEventoFake();
    await _montar(tester, entrega);
    final ics = await tocarYLeerIcs(tester, entrega);

    expect(ics, contains('UID:cita-7@carecar'));
    // V2-M02.12 con V2-M27.02: el lugar es «nombre, direccion» de la sucursal.
    expect(
      ics,
      contains(
        'LOCATION:CareCar León\\, Blvd. Ejemplo 100\\, Col. Centro\\, '
        '37000 León\\, Gto.',
      ),
    );
    expect(ics, isNot(contains(Agencia.direccion.split(',').first)));
    expect(ics, contains('TRIGGER:-PT60M'));
  });

  testWidgets('sin sucursales la direccion es la de la config de la agencia', (
    tester,
  ) async {
    final entrega = EntregaDeEventoFake();
    await _montar(
      tester,
      entrega,
      sucursales: RepositorioSucursalesFake(sucursales: []),
    );
    final ics = await tocarYLeerIcs(tester, entrega);

    expect(ics, contains('LOCATION:${Agencia.direccion.split(',').first}'));
    expect(ics, isNot(contains('CareCar León')));
  });

  testWidgets('si las sucursales fallan la direccion es la de la config', (
    tester,
  ) async {
    final entrega = EntregaDeEventoFake();
    await _montar(tester, entrega, sucursales: _RepoQueFalla());
    final ics = await tocarYLeerIcs(tester, entrega);

    expect(ics, contains('LOCATION:${Agencia.direccion.split(',').first}'));
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
