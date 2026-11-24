import 'dart:typed_data';

import 'orden_historial.dart';
import 'ticket_servicio.dart';

/// Contrato que la presentacion usa para leer el historial y los tickets.
abstract interface class RepositorioHistorial {
  /// Una pagina de las ordenes del vehiculo, de la mas reciente a la mas
  /// antigua. `anio` nulo trae todos los años.
  Future<PaginaHistorial> ordenes(
    int vehiculoId, {
    int? anio,
    int pagina = 0,
    int tamano = 20,
  });

  /// Años con servicios del vehiculo, del mas reciente al mas antiguo.
  Future<List<int>> anios(int vehiculoId);

  /// El ticket de la orden `servicioId`.
  Future<TicketServicio> ticket(int servicioId);

  /// Bytes del PDF del ticket.
  Future<Uint8List> ticketPdf(int servicioId);
}
