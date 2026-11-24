import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/dominio/orden_historial.dart';
import 'package:carecar_mobile/modulos/historial/dominio/ticket_servicio.dart';
import 'package:flutter_test/flutter_test.dart';

TicketServicio _conTotal(double total) => TicketServicio(
  id: ticketDeEjemplo.id,
  vehiculoId: ticketDeEjemplo.vehiculoId,
  fecha: ticketDeEjemplo.fecha,
  kilometraje: ticketDeEjemplo.kilometraje,
  estatus: ticketDeEjemplo.estatus,
  manoDeObra: ticketDeEjemplo.manoDeObra,
  refacciones: ticketDeEjemplo.refacciones,
  totalManoDeObra: ticketDeEjemplo.totalManoDeObra,
  totalRefacciones: ticketDeEjemplo.totalRefacciones,
  subtotal: ticketDeEjemplo.subtotal,
  iva: ticketDeEjemplo.iva,
  total: total,
);

void main() {
  test('lee los estatus del contrato y tolera uno desconocido', () {
    expect(EstatusOrden.desde('RECIBIDO'), EstatusOrden.recibido);
    expect(EstatusOrden.desde('EN_PROCESO'), EstatusOrden.enProceso);
    expect(EstatusOrden.desde('TERMINADO'), EstatusOrden.terminado);
    expect(EstatusOrden.desde('ENTREGADO'), EstatusOrden.entregado);
    expect(EstatusOrden.desde('CANCELADO'), EstatusOrden.desconocido);
    expect(EstatusOrden.desde(''), EstatusOrden.desconocido);
  });

  test('la mano de obra mas las refacciones dan el total del ticket', () {
    expect(ticketDeEjemplo.cuadra, isTrue);
    expect(
      ticketDeEjemplo.totalManoDeObra + ticketDeEjemplo.totalRefacciones,
      ticketDeEjemplo.total,
    );
  });

  test('un ticket cuyo total no es la suma no cuadra', () {
    expect(_conTotal(1300).cuadra, isFalse);
  });

  test('un renglon que no es cantidad por precio no cuadra', () {
    final ticket = TicketServicio(
      id: 1,
      vehiculoId: 1,
      fecha: DateTime(2026, 1, 1),
      kilometraje: 10,
      estatus: EstatusOrden.terminado,
      manoDeObra: const [
        RenglonTicketServicio(
          concepto: 'Afinación',
          cantidad: 2,
          precio: 100,
          importe: 150,
        ),
      ],
      refacciones: const [],
      totalManoDeObra: 150,
      totalRefacciones: 0,
      subtotal: 129.31,
      iva: 20.69,
      total: 150,
    );

    expect(ticket.cuadra, isFalse);
    expect(ticket.nombrePdf, 'ticket-1.pdf');
  });

  test('el repositorio falso pagina y filtra por año como la API', () async {
    final repo = RepositorioHistorialFake();

    final primera = await repo.ordenes(1, tamano: 2);
    final segunda = await repo.ordenes(1, pagina: 1, tamano: 2);
    final de2025 = await repo.ordenes(1, anio: 2025);

    expect(primera.ordenes.map((o) => o.id), [21, 20]);
    expect(primera.hayMas, isTrue);
    expect(segunda.ordenes.map((o) => o.id), [12]);
    expect(segunda.hayMas, isFalse);
    expect(de2025.ordenes.map((o) => o.id), [12]);
    expect(await repo.anios(1), [2026, 2025]);
  });
}
