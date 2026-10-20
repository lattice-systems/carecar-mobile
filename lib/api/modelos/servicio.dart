import 'comun.dart';

/// Orden de servicio vista por el cliente (ERP-3.1).
class Servicio {
  const Servicio({
    required this.id,
    required this.fecha,
    required this.estatus,
    required this.total,
  });

  factory Servicio.fromJson(Map<String, Object?> json) => Servicio(
    id: leerEntero(json['id'], 'id'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    estatus: leerTexto(json['estatus'], 'estatus'),
    total: leerDecimal(json['total'], 'total'),
  );

  final int id;
  final DateTime fecha;

  /// Texto libre: el contrato deja sus valores «pendientes de definir en
  /// ERP-3.1». Mientras no haya lista cerrada no se puede mapear a un enum ni
  /// asignarle colores fijos. Es la pregunta PO-5.
  final String estatus;

  /// Mano de obra mas refacciones.
  final double total;
}
