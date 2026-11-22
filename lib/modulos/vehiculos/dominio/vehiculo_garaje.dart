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
  });

  final int id;
  final String modelo;
  final int anio;
  final String? marca;
  final String? placas;
  final int? kilometraje;

  /// Nombre completo para la tarjeta: "Mazda CX-5 2024".
  String get titulo => [?marca, modelo, anio].join(' ');
}
