/// Rango de horas `HH:mm` en que el chofer llega.
class VentanaHoraria {
  const VentanaHoraria({required this.inicio, required this.fin});

  final String inicio;
  final String fin;
}

/// Costo y franjas de recoger y entregar el auto en una dirección y un día
/// (`GET /recoleccion/cotizacion`, V2-M17.02).
///
/// El costo lo calcula solo el backend: la app lo muestra, nunca lo recalcula.
class CotizacionRecoleccion {
  const CotizacionRecoleccion({
    required this.direccionId,
    required this.fecha,
    required this.costoPorTraslado,
    required this.costoTotal,
    required this.recoleccion,
    required this.entrega,
  });

  final int direccionId;
  final DateTime fecha;

  /// Pesos de cada traslado.
  final double costoPorTraslado;

  /// Pesos de los dos traslados juntos (recoger y entregar).
  final double costoTotal;

  /// Cuándo llega el chofer por el auto.
  final VentanaHoraria recoleccion;

  /// Cuándo lo devuelve.
  final VentanaHoraria entrega;
}
