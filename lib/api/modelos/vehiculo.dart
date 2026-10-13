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
  });

  factory Vehiculo.fromJson(Map<String, Object?> json) => Vehiculo(
    id: leerEntero(json['id'], 'id'),
    vin: leerTexto(json['vin'], 'vin'),
    modelo: leerTexto(json['modelo'], 'modelo'),
    anio: leerEntero(json['anio'], 'anio'),
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
}
