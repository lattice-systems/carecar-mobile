/// Estatus de una orden de servicio (PO-5). `desconocido` cubre un valor que la
/// app aun no conoce: se muestra sin romper la lista.
enum EstatusOrden {
  recibido('RECIBIDO'),
  enProceso('EN_PROCESO'),
  terminado('TERMINADO'),
  entregado('ENTREGADO'),
  desconocido('');

  const EstatusOrden(this.codigo);

  final String codigo;

  static EstatusOrden desde(String codigo) => EstatusOrden.values.firstWhere(
    (e) => e.codigo == codigo && e != EstatusOrden.desconocido,
    orElse: () => EstatusOrden.desconocido,
  );
}

/// Una orden del historial de un vehiculo (V2-M02.05).
class OrdenHistorial {
  const OrdenHistorial({
    required this.id,
    required this.fecha,
    required this.estatus,
    required this.total,
    this.fechaCierre,
  });

  final int id;

  /// Dia del servicio.
  final DateTime fecha;

  /// Cuando se cerro la orden; nula si sigue abierta.
  final DateTime? fechaCierre;
  final EstatusOrden estatus;

  /// Mano de obra mas refacciones, con IVA.
  final double total;
}

/// Una pagina del historial. `pagina` empieza en 0.
class PaginaHistorial {
  const PaginaHistorial({
    required this.ordenes,
    required this.pagina,
    required this.hayMas,
  });

  final List<OrdenHistorial> ordenes;
  final int pagina;
  final bool hayMas;
}
