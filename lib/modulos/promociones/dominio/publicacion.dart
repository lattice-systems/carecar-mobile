class Publicacion {
  const Publicacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.imagen,
    required this.fecha,
    this.hasta,
    this.cta,
    this.cupon,
    this.vehiculos = const [],
  });

  factory Publicacion.novedad(Map<String, Object?> json) => Publicacion(
    id: (json['id'] as num).toInt(),
    titulo: json['titulo'] as String,
    cuerpo: json['cuerpo'] as String,
    imagen: json['imagenUrl'] as String?,
    fecha: DateTime.parse(json['publicadaEn'] as String),
  );

  factory Publicacion.promocion(Map<String, Object?> json) => Publicacion(
    id: (json['id'] as num).toInt(),
    titulo: json['titulo'] as String,
    cuerpo: json['cuerpo'] as String,
    imagen: json['imagenUrl'] as String?,
    fecha: DateTime.parse(json['iniciaEn'] as String),
    hasta: DateTime.parse(json['terminaEn'] as String),
    cta: json['cta'] as String,
    cupon: json['cupon'] as String?,
    vehiculos: (json['vehiculosIds'] as List<Object?>)
        .cast<num>()
        .map((id) => id.toInt())
        .toList(),
  );

  final int id;
  final String titulo;
  final String cuerpo;
  final String? imagen;
  final DateTime fecha;
  final DateTime? hasta;
  final String? cta;
  final String? cupon;
  final List<int> vehiculos;
}
