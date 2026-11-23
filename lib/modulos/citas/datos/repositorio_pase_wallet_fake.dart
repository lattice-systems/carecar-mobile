import 'dart:typed_data';

import '../dominio/pase_de_wallet.dart';

/// Repositorio del pase en memoria para pruebas y el flavor `desarrollo`.
///
/// Guarda cada pedido en [pedidos]; con [fallo] responde con ese error y con
/// [espera] no contesta hasta que se complete, para ver el estado de carga.
class RepositorioPaseWalletFake implements RepositorioPaseWallet {
  RepositorioPaseWalletFake({this.pase, this.fallo, this.espera});

  /// Pase que devuelve; si es nulo, uno de ejemplo segun la plataforma.
  final PaseDeWallet? pase;
  Object? fallo;
  final Future<void>? espera;

  final List<(int, PlataformaWallet)> pedidos = [];

  @override
  Future<PaseDeWallet> obtener(int citaId, PlataformaWallet plataforma) async {
    pedidos.add((citaId, plataforma));
    await espera;
    final error = fallo;
    if (error != null) throw error;
    return pase ??
        switch (plataforma) {
          PlataformaWallet.apple => PaseApple(Uint8List.fromList([0])),
          PlataformaWallet.google => PaseGoogle(
            Uri.parse('https://pay.google.com/gp/v/save/ejemplo'),
          ),
        };
  }
}
