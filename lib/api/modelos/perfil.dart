import 'comun.dart';

/// Datos de solo lectura del cliente autenticado.
///
/// Editarlos es V2-M01.07, con su verificación por código; aquí solo se leen.
class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.clienteDesde,
    this.telefono,
  });

  factory Perfil.fromJson(Map<String, Object?> json) => Perfil(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    correo: leerTexto(json['correo'], 'correo'),
    clienteDesde: leerFecha(json['clienteDesde'], 'clienteDesde'),
    telefono: json['telefono'] == null
        ? null
        : leerTexto(json['telefono'], 'telefono'),
  );

  final int id;
  final String nombre;
  final String correo;

  /// Nulo cuando la agencia no lo capturó al dar de alta al cliente, que pasa
  /// seguido. La pantalla lo muestra como un dato que falta, no como un error.
  final String? telefono;

  /// Desde cuándo es cliente de la agencia (V2-M01.06).
  ///
  /// **Siempre viene**: `cliente.created_at` es `not null` en el backend. Es
  /// una fecha y no un instante, ya resuelta en la zona de la agencia, así que
  /// aquí no se convierte nada: hacerlo correría el día.
  final DateTime clienteDesde;
}
