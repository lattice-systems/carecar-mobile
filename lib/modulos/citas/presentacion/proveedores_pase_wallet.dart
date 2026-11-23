import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/entrega_de_pase_del_sistema.dart';
import '../datos/repositorio_pase_wallet_api.dart';
import '../dominio/pase_de_wallet.dart';

/// Pide el pase al backend. En pruebas:
/// `repositorioPaseWalletProvider.overrideWithValue(RepositorioPaseWalletFake())`.
final repositorioPaseWalletProvider = Provider<RepositorioPaseWallet>(
  (ref) => RepositorioPaseWalletApi(ref.watch(apiClienteProvider)),
  name: 'repositorioPaseWalletProvider',
);

/// Como se entrega el pase al sistema (abrir Google Wallet o compartir el
/// pkpass). Se sustituye en pruebas por `EntregaDePaseFake`.
final entregaDePaseProvider = Provider<EntregaDePase>(
  (ref) => const EntregaDePaseDelSistema(),
  name: 'entregaDePaseProvider',
);

/// Wallet de esta plataforma: Google en Android, Apple en iOS y nulo donde no
/// hay (escritorio, web), que es cuando el boton no se muestra.
final plataformaWalletProvider = Provider<PlataformaWallet?>(
  (ref) => switch (defaultTargetPlatform) {
    TargetPlatform.android => PlataformaWallet.google,
    TargetPlatform.iOS => PlataformaWallet.apple,
    _ => null,
  },
  name: 'plataformaWalletProvider',
);
