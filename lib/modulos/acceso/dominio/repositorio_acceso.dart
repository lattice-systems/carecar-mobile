import 'fallos_acceso.dart';

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

  /// `POST /auth/recuperar-contrasena`.
  ///
  /// Manda al correo un enlace de un solo uso (V2-T05.04). **Termina bien
  /// exista o no la cuenta**: el contrato responde igual para no revelar que
  /// correos hay registrados, asi que quien llame no puede saberlo y la
  /// pantalla dice lo mismo en los dos casos.
  Future<void> pedirEnlaceDeRecuperacion(String correo);

  /// `POST /auth/restablecer-contrasena` con el token del enlace.
  ///
  /// Lanza [EnlaceNoValido] si el enlace vencio o ya se uso. Cualquier otro
  /// 400 -una contrasena que no cumple, por ejemplo- sale tal cual: los dos
  /// comparten codigo HTTP y solo los separa `Problema.codigo`.
  Future<void> restablecerConEnlace({
    required String token,
    required String contrasenaNueva,
  });
}
