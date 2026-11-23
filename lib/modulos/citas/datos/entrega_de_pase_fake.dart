import '../dominio/pase_de_wallet.dart';

/// Entrega de pases que solo anota lo recibido (pruebas y `desarrollo`).
class EntregaDePaseFake implements EntregaDePase {
  EntregaDePaseFake({this.fallo});

  /// Si no es nulo, [entregar] lo lanza.
  final Object? fallo;

  /// Cada pase entregado con el id de su cita.
  final List<(PaseDeWallet, int)> entregados = [];

  @override
  Future<void> entregar(PaseDeWallet pase, {required int citaId}) async {
    final error = fallo;
    if (error != null) throw error;
    entregados.add((pase, citaId));
  }
}
