/// Lo que el modulo `acceso` necesita del servidor · M01.
///
/// La presentacion depende de esta interfaz y no de `CarecarApi`, asi que una
/// prueba la sustituye sin levantar red y el dia que el contrato cambie se
/// toca `datos/`, no las pantallas.
abstract interface class RepositorioAcceso {
  /// `POST /auth/cambiar-contrasena`.
  ///
  /// Termina sin devolver nada: el contrato **no entrega una sesion nueva**,
  /// asi que `debeCambiarContrasena` sigue en `true` y quien llama tiene que
  /// marcar que ya se cambio (`contrasenaCambiadaProvider`).
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  });
}
