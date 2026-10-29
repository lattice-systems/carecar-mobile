import 'comun.dart';

/// Vehiculo del cliente (el expediente de ERP-3.0).
class Vehiculo {
  const Vehiculo({
    required this.id,
    required this.vin,
    required this.modelo,
    required this.anio,
    this.placas,
    this.kilometraje,
    this.marca,
    this.tipo,
    this.version,
    this.color,
  });

  factory Vehiculo.fromJson(Map<String, Object?> json) => Vehiculo(
    id: leerEntero(json['id'], 'id'),
    vin: leerTexto(json['vin'], 'vin'),
    modelo: leerTexto(json['modelo'], 'modelo'),
    anio: leerEntero(json['anio'], 'anio'),
    marca: json['marca'] as String?,
    tipo: json['tipo'] as String?,
    version: json['version'] as String?,
    color: json['color'] as String?,
    // El contrato los marca opcionales: pueden llegar nulos o no llegar.
    placas: json['placas'] as String?,
    kilometraje: json['kilometraje'] == null
        ? null
        : leerEntero(json['kilometraje'], 'kilometraje'),
  );

  final int id;

  /// Va con tipografia monoespaciada en la interfaz (guia de estilos, §3).
  final String vin;
  final String modelo;
  final int anio;
  final String? placas;
  final int? kilometraje;

  // Extension opcional del mock; el backend v1.1 no garantiza estos campos.
  final String? marca;
  final String? tipo;
  final String? version;
  final String? color;
}
