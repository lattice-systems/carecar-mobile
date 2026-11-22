/// Un modelo del catalogo que la agencia tiene vigente.
///
/// Dart puro: no sabe de Flutter ni de la red. El backend solo entrega los
/// modelos activos, asi que aqui no se vuelve a filtrar.
class ModeloVigente {
  const ModeloVigente({
    required this.nombre,
    this.id,
    this.marca,
    this.anio,
    this.version,
    this.precioDesde,
    this.imagenUrl,
    this.descripcion,
  });

  final int? id;
  final String nombre;
  final String? marca;
  final int? anio;
  final String? version;
  final double? precioDesde;
  final String? imagenUrl;
  final String? descripcion;

  /// Nombre completo para la tarjeta: "Mazda CX-5 2024".
  String get titulo => [?marca, nombre, ?anio].join(' ');
}
