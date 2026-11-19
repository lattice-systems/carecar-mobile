import 'comun.dart';

/// Datos de solo lectura del cliente autenticado, segun el contrato v1.1.
class Perfil {
  const Perfil({required this.id, required this.nombre, required this.correo});

  factory Perfil.fromJson(Map<String, Object?> json) => Perfil(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    correo: leerTexto(json['correo'], 'correo'),
  );

  final int id;
  final String nombre;
  final String correo;
}
