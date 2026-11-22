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

  /// "Desde $450,000", o nulo si no hay precio publicado.
  String? get precioTexto {
    final p = precioDesde;
    if (p == null) return null;
    return 'Desde \$${conMiles(p.round())}';
  }

  /// Linea de apoyo de la tarjeta: version y precio, lo que haya.
  String? get detalle {
    final partes = [?version, ?precioTexto];
    return partes.isEmpty ? null : partes.join(' · ');
  }
}

/// Entero con comas de miles: 1234567 queda "1,234,567".
String conMiles(int n) {
  final digitos = n.abs().toString();
  final partes = <String>[];
  for (var fin = digitos.length; fin > 0; fin -= 3) {
    partes.insert(0, digitos.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
  }
  return '${n < 0 ? '-' : ''}${partes.join(',')}';
}
