import 'dart:typed_data';

import '../../../api/carecar_api.dart';
import '../../../api/modelos/servicio_detalle.dart';
import '../dominio/orden_historial.dart';
import '../dominio/repositorio_historial.dart';
import '../dominio/ticket_servicio.dart';

/// Lee el historial y los tickets de la API y los traduce a modelos de
/// dominio. Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal
/// cual: la presentacion decide como mostrarlas.
class RepositorioHistorialApi implements RepositorioHistorial {
  const RepositorioHistorialApi(this._api);

  final CarecarApi _api;

  @override
  Future<PaginaHistorial> ordenes(
    int vehiculoId, {
    int? anio,
    int pagina = 0,
    int tamano = 20,
  }) async {
    final respuesta = await _api.paginaDeServicios(
      vehiculoId,
      pagina: pagina,
      tamano: tamano,
      anio: anio,
    );
    return PaginaHistorial(
      ordenes: [
        for (final s in respuesta.contenido)
          OrdenHistorial(
            id: s.id,
            fecha: s.fecha,
            fechaCierre: s.fechaCierre,
            estatus: EstatusOrden.desde(s.estatus),
            total: s.total,
          ),
      ],
      pagina: respuesta.pagina,
      hayMas: respuesta.hayMas,
    );
  }

  @override
  Future<List<int>> anios(int vehiculoId) => _api.aniosDeServicios(vehiculoId);

  @override
  Future<TicketServicio> ticket(int servicioId) async {
    final d = await _api.detalleDeServicio(servicioId);
    return TicketServicio(
      id: d.id,
      vehiculoId: d.vehiculoId,
      fecha: d.fecha,
      fechaCierre: d.fechaCierre,
      kilometraje: d.kilometraje,
      estatus: EstatusOrden.desde(d.estatus),
      manoDeObra: [for (final r in d.manoDeObra) _renglon(r)],
      refacciones: [for (final r in d.refacciones) _renglon(r)],
      totalManoDeObra: d.totalManoDeObra,
      totalRefacciones: d.totalRefacciones,
      subtotal: d.subtotal,
      iva: d.iva,
      total: d.total,
    );
  }

  @override
  Future<Uint8List> ticketPdf(int servicioId) => _api.ticketDe(servicioId);

  static RenglonTicketServicio _renglon(RenglonTicket r) =>
      RenglonTicketServicio(
        concepto: r.concepto,
        cantidad: r.cantidad,
        precio: r.precio,
        importe: r.importe,
      );
}
