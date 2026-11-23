import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/repositorio_citas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/visor_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../ayudas/tema_pista.dart';

Widget _app(RepositorioCitas repo, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [repositorioCitasProvider.overrideWithValue(repo)],
      child: conTemaPista(
        const PantallaComprobanteCita(citaId: 7),
        escenario: escenario,
      ),
    );

void main() {
  testWidgets('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(find.bySemanticsLabel('Cargando tu comprobante'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  testWidgets('dibuja el QR con el codigo firmado y lo describe', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    // El QrImageView no expone su dato: la pantalla lo identifica con una
    // llave que lleva el codigo firmado.
    expect(
      find.byKey(const ValueKey('qr-comprobante:CC1.7.firma')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Código QR de tu cita para recepción'),
      findsOneWidget,
    );
  });

  testWidgets('muestra folio, horario e indicacion para recepcion', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(find.text('Folio 7'), findsOneWidget);
    expect(find.textContaining('de 09:00 a 10:00'), findsOneWidget);
    expect(
      find.text('Muestra este código en recepción para registrar tu llegada.'),
      findsOneWidget,
    );
  });

  testWidgets('el boton abre el PDF de la cita en el visor', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    // En la pantalla de prueba el boton queda bajo el pliegue.
    await tester.ensureVisible(find.text('Ver comprobante en PDF'));
    await tester.pump();
    await tester.tap(find.text('Ver comprobante en PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(VisorPdf), findsOneWidget);
  });

  testWidgets('un fallo muestra error con reintento', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake(error: StateError('x'))));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('sin conexion lo dice como tal', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioCitasFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    final estado = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(estado.causa, CausaError.sinConexion);
  });

  for (final escenario in Escenario.values) {
    testWidgets('cabe sin desbordar en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioCitasFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QrImageView), findsOneWidget);
    });
  }
}
