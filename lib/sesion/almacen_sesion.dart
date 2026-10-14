/// Donde vive el token de la sesion.
///
/// Es una abstraccion a proposito: **donde se guarda de verdad todavia no esta
/// decidido** (pregunta EQ-9, sobre que datos puede guardar la app en el
/// celular). Lo razonable es el almacenamiento seguro del sistema operativo,
/// que implica una dependencia nueva y por eso espera respuesta.
///
/// Mientras tanto se usa [AlmacenEnMemoria]: la sesion no sobrevive a cerrar la
/// app. Para APP-2.1, cuyo criterio solo pide entrar con las credenciales que
/// entrega la agencia, alcanza. Cambiar de implementacion no toca ni las
/// pantallas ni la capa de datos.
abstract interface class AlmacenSesion {
  Future<String?> leerToken();
  Future<void> guardarToken(String token);
  Future<void> borrarToken();
}

/// Guarda el token en memoria. Se pierde al cerrar la app.
class AlmacenEnMemoria implements AlmacenSesion {
  String? _token;

  @override
  Future<String?> leerToken() async => _token;

  @override
  Future<void> guardarToken(String token) async => _token = token;

  @override
  Future<void> borrarToken() async => _token = null;
}
