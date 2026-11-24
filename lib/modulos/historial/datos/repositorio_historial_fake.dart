import 'dart:typed_data';

import '../dominio/orden_historial.dart';
import '../dominio/repositorio_historial.dart';
import '../dominio/ticket_servicio.dart';

/// Historial en memoria para pruebas y desarrollo. Pagina y filtra como la API.
class RepositorioHistorialFake implements RepositorioHistorial {
  RepositorioHistorialFake({
    List<OrdenHistorial>? ordenes,
    Map<int, TicketServicio>? tickets,
    this.falla,
  }) : _ordenes = ordenes ?? ordenesDeEjemplo,
       _tickets = tickets ?? {ticketDeEjemplo.id: ticketDeEjemplo};

  final List<OrdenHistorial> _ordenes;
  final Map<int, TicketServicio> _tickets;

  /// Si no es nulo, toda lectura lanza esto.
  Object? falla;

  /// Paginas pedidas: (anio, pagina).
  final paginasPedidas = <(int?, int)>[];

  /// PDFs pedidos por id de servicio.
  final pdfsPedidos = <int>[];

  @override
  Future<PaginaHistorial> ordenes(
    int vehiculoId, {
    int? anio,
    int pagina = 0,
    int tamano = 20,
  }) async {
    if (falla != null) throw falla!;
    paginasPedidas.add((anio, pagina));
    final filtradas = [
      for (final o in _ordenes)
        if (anio == null || o.fecha.year == anio) o,
    ];
    final desde = pagina * tamano;
    final hasta = desde + tamano > filtradas.length
        ? filtradas.length
        : desde + tamano;
    return PaginaHistorial(
      ordenes: desde >= filtradas.length
          ? const []
          : filtradas.sublist(desde, hasta),
      pagina: pagina,
      hayMas: hasta < filtradas.length,
    );
  }

  @override
  Future<List<int>> anios(int vehiculoId) async {
    if (falla != null) throw falla!;
    final anios = {for (final o in _ordenes) o.fecha.year}.toList()
      ..sort((a, b) => b.compareTo(a));
    return anios;
  }

  @override
  Future<TicketServicio> ticket(int servicioId) async {
    if (falla != null) throw falla!;
    final ticket = _tickets[servicioId];
    if (ticket == null) throw StateError('Sin ticket $servicioId');
    return ticket;
  }

  @override
  Future<Uint8List> ticketPdf(int servicioId) async {
    if (falla != null) throw falla!;
    pdfsPedidos.add(servicioId);
    return Uint8List.fromList('%PDF-1.4'.codeUnits);
  }
}

/// Tres ordenes de dos años, la mas reciente primero.
final ordenesDeEjemplo = [
  OrdenHistorial(
    id: 21,
    fecha: DateTime(2026, 10, 20),
    fechaCierre: DateTime(2026, 10, 20, 13, 45),
    estatus: EstatusOrden.terminado,
    total: 1282,
  ),
  OrdenHistorial(
    id: 20,
    fecha: DateTime(2026, 5, 2),
    fechaCierre: DateTime(2026, 5, 2, 17, 10),
    estatus: EstatusOrden.entregado,
    total: 1200,
  ),
  OrdenHistorial(
    id: 12,
    fecha: DateTime(2025, 11, 8),
    fechaCierre: DateTime(2025, 11, 8, 12),
    estatus: EstatusOrden.terminado,
    total: 801,
  ),
];

/// Ticket de la orden 21: una mano de obra y dos refacciones.
final ticketDeEjemplo = TicketServicio(
  id: 21,
  vehiculoId: 1,
  fecha: DateTime(2026, 10, 20),
  fechaCierre: DateTime(2026, 10, 20, 13, 45),
  kilometraje: 15000,
  estatus: EstatusOrden.terminado,
  manoDeObra: const [
    RenglonTicketServicio(
      concepto: 'Cambio de aceite',
      cantidad: 1,
      precio: 450,
      importe: 450,
    ),
  ],
  refacciones: const [
    RenglonTicketServicio(
      concepto: 'Filtro de aceite',
      cantidad: 2,
      precio: 175.5,
      importe: 351,
    ),
    RenglonTicketServicio(
      concepto: 'Aceite sintético',
      cantidad: 4,
      precio: 120.25,
      importe: 481,
    ),
  ],
  totalManoDeObra: 450,
  totalRefacciones: 832,
  subtotal: 1105.17,
  iva: 176.83,
  total: 1282,
);
