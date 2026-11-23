import 'dart:async';
import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/modulos/citas/datos/entrega_de_pase_fake.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_pase_wallet_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/pase_de_wallet.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/boton_agregar_a_wallet.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/proveedores_pase_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Problema _problema(CodigoProblema codigo, int status) => Problema(
  timestamp: '',
  status: status,
  error: 'Error',
  message: 'x',
  path: '/citas/7/pase',
  codigo: codigo,
);

Widget _app({
  required RepositorioPaseWalletFake repo,
  required EntregaDePaseFake entrega,
  PlataformaWallet? plataforma = PlataformaWallet.google,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioPaseWalletProvider.overrideWithValue(repo),
    entregaDePaseProvider.overrideWithValue(entrega),
    plataformaWalletProvider.overrideWithValue(plataforma),
  ],
  child: conTemaPista(
    const BotonAgregarAWallet(citaId: 7),
    escenario: escenario,
  ),
);

void main() {
  testWidgets('sin Wallet en la plataforma no muestra el boton', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repo: RepositorioPaseWalletFake(),
        entrega: EntregaDePaseFake(),
        plataforma: null,
      ),
    );

    expect(find.text('Agregar a Wallet'), findsNothing);
  });

  testWidgets('en Android pide el pase de Google y lo entrega', (tester) async {
    final repo = RepositorioPaseWalletFake();
    final entrega = EntregaDePaseFake();
    await tester.pumpWidget(_app(repo: repo, entrega: entrega));

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();

    expect(repo.pedidos, [(7, PlataformaWallet.google)]);
    expect(entrega.entregados.single.$1, isA<PaseGoogle>());
    expect(entrega.entregados.single.$2, 7);
  });

  testWidgets('en iPhone pide el pkpass de Apple', (tester) async {
    final repo = RepositorioPaseWalletFake(
      pase: PaseApple(Uint8List.fromList([1])),
    );
    final entrega = EntregaDePaseFake();
    await tester.pumpWidget(
      _app(repo: repo, entrega: entrega, plataforma: PlataformaWallet.apple),
    );

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();

    expect(repo.pedidos, [(7, PlataformaWallet.apple)]);
    expect(entrega.entregados.single.$1, isA<PaseApple>());
  });

  testWidgets('mientras pide el pase muestra carga y no deja tocar de nuevo', (
    tester,
  ) async {
    final espera = Completer<void>();
    final repo = RepositorioPaseWalletFake(espera: espera.future);
    await tester.pumpWidget(_app(repo: repo, entrega: EntregaDePaseFake()));

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pump();
    expect(find.bySemanticsLabel('Agregar a Wallet, cargando'), findsOneWidget);
    await tester.tap(find.text('Agregar a Wallet'), warnIfMissed: false);
    await tester.pump();
    expect(repo.pedidos, hasLength(1));

    espera.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('sin conexion avisa y deja reintentar', (tester) async {
    final repo = RepositorioPaseWalletFake(fallo: const SinConexion());
    await tester.pumpWidget(_app(repo: repo, entrega: EntregaDePaseFake()));

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sin conexión. Revisa tu red e intenta de nuevo.'),
      findsOneWidget,
    );

    repo.fallo = null;
    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sin conexión. Revisa tu red e intenta de nuevo.'),
      findsNothing,
    );
    expect(repo.pedidos, hasLength(2));
  });

  testWidgets('cita cancelada: explica que ya no tiene pase', (tester) async {
    final repo = RepositorioPaseWalletFake(
      fallo: Conflicto(
        'cancelada',
        problema: _problema(CodigoProblema.citaCancelada, 409),
      ),
    );
    await tester.pumpWidget(_app(repo: repo, entrega: EntregaDePaseFake()));

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tu cita está cancelada, así que ya no tiene pase.'),
      findsOneWidget,
    );
  });

  testWidgets('servidor sin certificados: manda al QR de recepcion', (
    tester,
  ) async {
    final repo = RepositorioPaseWalletFake(
      fallo: ErrorDelServidor(
        'x',
        status: 503,
        problema: _problema(CodigoProblema.walletNoConfigurado, 503),
      ),
    );
    await tester.pumpWidget(_app(repo: repo, entrega: EntregaDePaseFake()));

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'El pase de Wallet no está disponible por ahora. '
        'Muestra el código QR en recepción.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('si el sistema no puede abrir el pase muestra el error', (
    tester,
  ) async {
    final entrega = EntregaDePaseFake(fallo: StateError('sin Wallet'));
    await tester.pumpWidget(
      _app(repo: RepositorioPaseWalletFake(), entrega: entrega),
    );

    await tester.tap(find.text('Agregar a Wallet'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos preparar tu pase. Intenta de nuevo.'),
      findsOneWidget,
    );
  });

  for (final escenario in Escenario.values) {
    testWidgets('se ve completo en ${escenario.name}', (tester) async {
      final repo = RepositorioPaseWalletFake(fallo: const SinConexion());
      await tester.pumpWidget(
        _app(repo: repo, entrega: EntregaDePaseFake(), escenario: escenario),
      );
      await tester.tap(find.text('Agregar a Wallet'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BotonAgregarAWallet), findsOneWidget);
    });
  }

  testWidgets('el boton mide al menos 48 de alto', (tester) async {
    await tester.pumpWidget(
      _app(repo: RepositorioPaseWalletFake(), entrega: EntregaDePaseFake()),
    );

    final alto = tester.getSize(find.byType(OutlinedButton)).height;
    expect(alto, greaterThanOrEqualTo(48));
  });
}
