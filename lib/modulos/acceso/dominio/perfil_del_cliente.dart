/// Los datos del cliente tal como los muestra su perfil · V2-M01.06.
///
/// Dart puro: no sabe de Flutter ni de la red. De solo lectura, como el
/// contrato; editarlos es V2-M01.07, con su verificación por código.
class PerfilDelCliente {
  PerfilDelCliente({
    required this.nombre,
    required this.correo,
    required this.clienteDesde,
    String? telefono,
  }) : telefono = _limpio(telefono);

  final String nombre;
  final String correo;

  /// Nulo cuando la agencia no lo capturó, que pasa seguido.
  ///
  /// Un teléfono con solo espacios se guarda como **nulo**: la columna del
  /// backend es `varchar(20)` sin exigir contenido, y pintar un renglón en
  /// blanco parecería un error de la app en vez de un dato que falta.
  final String? telefono;

  /// Desde cuándo es cliente de la agencia. Siempre viene.
  final DateTime clienteDesde;

  bool get tieneTelefono => telefono != null;

  static String? _limpio(String? valor) {
    final recortado = valor?.trim();
    return recortado == null || recortado.isEmpty ? null : recortado;
  }
}
