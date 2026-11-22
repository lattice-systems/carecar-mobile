/// Un vehiculo del cliente tal como se muestra en su garaje.
///
/// Dart puro: no sabe de Flutter ni de la red. Los datos opcionales (placas,
/// kilometraje) pueden faltar: la agencia los captura al entregar el auto.
class VehiculoGaraje {
  const VehiculoGaraje({
    required this.id,
    required this.modelo,
    required this.anio,
    this.marca,
    this.placas,
    this.kilometraje,
    this.vin,
    this.color,
    this.version,
    this.kilometrajeActualizadoEn,
  });

  final int id;
  final String modelo;
  final int anio;
  final String? marca;
  final String? placas;
  final int? kilometraje;

  /// Numero de serie; el detalle lo muestra y lo deja copiar.
  final String? vin;
  final String? color;
  final String? version;

  /// Fecha de cierre de la orden de servicio que dejo el kilometraje. Sin ella
  /// el detalle no dice quien ni cuando lo actualizo.
  final DateTime? kilometrajeActualizadoEn;

  /// Nombre completo para la tarjeta: "Mazda CX-5 2024". Si el modelo ya
  /// empieza con la marca ("Nissan March"), no la repite.
  String get titulo {
    final m = marca;
    final repetida =
        m != null && modelo.toLowerCase().startsWith(m.toLowerCase());
    return [if (m != null && !repetida) m, modelo, anio].join(' ');
  }
}
