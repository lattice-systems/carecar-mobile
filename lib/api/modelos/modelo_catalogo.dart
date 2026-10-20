import 'comun.dart';

/// Modelo vigente del catalogo (APP-4.1, fuera del MVP).
///
/// El contrato deja pendientes los demas atributos (versiones, precio,
/// imagenes): es la pregunta PO-13 del catalogo.
class ModeloCatalogo {
  const ModeloCatalogo({required this.id, required this.modelo});

  factory ModeloCatalogo.fromJson(Map<String, Object?> json) => ModeloCatalogo(
    id: leerEntero(json['id'], 'id'),
    modelo: leerTexto(json['modelo'], 'modelo'),
  );

  final int id;
  final String modelo;
}
