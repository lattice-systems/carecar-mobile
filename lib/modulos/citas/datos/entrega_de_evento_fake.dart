import '../dominio/evento_de_calendario.dart';

/// Entrega de eventos que solo anota lo recibido (pruebas y `desarrollo`).
class EntregaDeEventoFake implements EntregaDeEvento {
  EntregaDeEventoFake({this.fallo});

  /// Si no es nulo, [entregar] lo lanza.
  final Object? fallo;

  /// Cada `.ics` entregado con el id de su cita.
  final List<(String, int)> entregados = [];

  @override
  Future<void> entregar(String ics, {required int citaId}) async {
    final error = fallo;
    if (error != null) throw error;
    entregados.add((ics, citaId));
  }
}
