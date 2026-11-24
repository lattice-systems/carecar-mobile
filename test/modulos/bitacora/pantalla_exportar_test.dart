import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/pantalla_exportar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'arnes_bitacora.dart';

class _Compartido {
  Uint8List? bytes;
  String? nombre;
  String? mime;
}

Widget _pantalla(
  RepositorioBitacoraFake repo,
  _Compartido compartido, {
  Escenario escenario = Escenario.claro,
}) => aplicacion(
  const PantallaExportar(vehiculoId: 4, nombre: 'Aveo 2022'),
  repo: repo,
  escenario: escenario,
  compartir: (bytes, nombre, mime) async {
    compartido
      ..bytes = bytes
      ..nombre = nombre
      ..mime = mime;
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  prueba('comparte el CSV de todos los meses con la hoja del sistema', (
    tester,
  ) async {
    final compartido = _Compartido();
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba()), compartido),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir CSV'));
    await tester.pumpAndSettle();
    expect(compartido.nombre, 'bitacora-aveo-2022-2026-10-a-2026-11.csv');
    expect(compartido.mime, 'text/csv');
    final csv = utf8.decode(compartido.bytes!);
    expect(csv, contains('2026-11-05,lavado,80.00,,,'));
    expect(csv, contains('2026-10-15,gasolina,840.00,40,10400,'));
  });

  prueba('comparte el PDF', (tester) async {
    final compartido = _Compartido();
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba()), compartido),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir PDF'));
    await tester.pumpAndSettle();
    expect(compartido.nombre, endsWith('.pdf'));
    expect(compartido.mime, 'application/pdf');
    expect(ascii.decode(compartido.bytes!.sublist(0, 5)), '%PDF-');
  });

  prueba('un rango de meses sin gastos lo avisa y no comparte', (tester) async {
    final compartido = _Compartido();
    // Hay gastos en septiembre y noviembre; se elige solo octubre.
    final repo = RepositorioBitacoraFake(
      gastos: [
        otroGasto(1, DateTime(2026, 9, 3), 80),
        otroGasto(2, DateTime(2026, 11, 5), 90),
      ],
    );
    await tester.pumpWidget(_pantalla(repo, compartido));
    await tester.pumpAndSettle();
    await tester.tap(find.text('septiembre de 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('octubre de 2026').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('noviembre de 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('octubre de 2026').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir CSV'));
    await tester.pumpAndSettle();
    expect(find.text('No hay gastos en esos meses.'), findsOneWidget);
    expect(compartido.bytes, isNull);
  });

  prueba('un rango al revés se avisa', (tester) async {
    final compartido = _Compartido();
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba()), compartido),
    );
    await tester.pumpAndSettle();
    // «Hasta» pasa a octubre y luego «Desde» a noviembre.
    await tester.tap(find.text('noviembre de 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('octubre de 2026').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('octubre de 2026').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('noviembre de 2026').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir CSV'));
    await tester.pumpAndSettle();
    expect(
      find.text('El mes inicial no puede ser posterior al final.'),
      findsOneWidget,
    );
    expect(compartido.bytes, isNull);
  });

  prueba('si la hoja del sistema falla, lo explica', (tester) async {
    await tester.pumpWidget(
      aplicacion(
        const PantallaExportar(vehiculoId: 4),
        repo: RepositorioBitacoraFake(gastos: gastosDePrueba()),
        compartir: (_, _, _) async => throw StateError('sin hoja'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir CSV'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo compartir el archivo. Intenta de nuevo.'),
      findsOneWidget,
    );
  });

  prueba('sin gastos no hay nada que exportar', (tester) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(), _Compartido()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay gastos'), findsOneWidget);
    expect(find.text('Compartir CSV'), findsNothing);
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('se ve completa con ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _pantalla(
          RepositorioBitacoraFake(gastos: gastosDePrueba()),
          _Compartido(),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Compartir CSV'), findsOneWidget);
    });
  }
}
