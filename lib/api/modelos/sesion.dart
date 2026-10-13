import 'comun.dart';

/// Cuerpo de `POST /auth/login`.
class PeticionLogin {
  const PeticionLogin({required this.usuario, required this.contrasena});

  final String usuario;
  final String contrasena;

  Map<String, Object?> toJson() => {
    'usuario': usuario,
    'contrasena': contrasena,
  };
}

/// Respuesta de `POST /auth/login`.
class RespuestaLogin {
  const RespuestaLogin({
    required this.accessToken,
    required this.debeCambiarContrasena,
  });

  factory RespuestaLogin.fromJson(Map<String, Object?> json) => RespuestaLogin(
    accessToken: leerTexto(json['accessToken'], 'accessToken'),
    debeCambiarContrasena: leerBool(
      json['debeCambiarContrasena'],
      'debeCambiarContrasena',
    ),
  );

  final String accessToken;

  /// `true` si la contrasena es temporal y la app debe forzar el cambio
  /// (APP-2.3). El contrato no dice cuanto vive el token: pregunta RIC-1.
  final bool debeCambiarContrasena;
}
