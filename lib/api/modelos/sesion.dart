import 'comun.dart';

/// Cuerpo de `POST /auth/login`.
///
/// En la v1.1 el campo es `correo`, no `usuario` (RIC-8, decision del PO). El
/// backend ignora mayusculas y espacios al inicio y al final, pero la app
/// recorta de todos modos para no mandar lo que el usuario pego sin querer.
class PeticionLogin {
  const PeticionLogin({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;

  Map<String, Object?> toJson() => {
    'correo': correo.trim(),
    'contrasena': contrasena,
  };
}

/// Cuerpo de `POST /auth/restablecer-contrasena`.
///
/// En la v1.1 ya no hay enlace: llega un codigo de 6 digitos al correo y se
/// captura en la app (RIC-18).
class PeticionRestablecer {
  const PeticionRestablecer({
    required this.correo,
    required this.codigo,
    required this.contrasenaNueva,
  });

  final String correo;
  final String codigo;
  final String contrasenaNueva;

  Map<String, Object?> toJson() => {
    'correo': correo.trim(),
    'codigo': codigo.trim(),
    'contrasenaNueva': contrasenaNueva,
  };
}

/// Reglas de la contrasena del contrato (RIC-9), para validar antes de enviar.
///
/// El backend valida lo mismo y responde 400, pero validar en la app evita un
/// viaje y da un mensaje mas util.
abstract final class ReglasContrasena {
  static const minimo = 8;
  static const maximo = 72;

  /// `null` si es valida; si no, el texto que se le muestra al usuario.
  static String? revisar(String contrasena, {String? actual}) {
    if (contrasena.length < minimo) {
      return 'La contraseña debe tener al menos $minimo caracteres.';
    }
    if (contrasena.length > maximo) {
      return 'La contraseña no puede pasar de $maximo caracteres.';
    }
    if (!contrasena.contains(RegExp('[A-Za-zÁÉÍÓÚáéíóúÑñ]'))) {
      return 'La contraseña debe tener al menos una letra.';
    }
    if (!contrasena.contains(RegExp('[0-9]'))) {
      return 'La contraseña debe tener al menos un número.';
    }
    if (actual != null && contrasena == actual) {
      return 'La contraseña nueva debe ser distinta de la actual.';
    }
    return null;
  }
}

/// Respuesta de `POST /auth/login` y de `POST /auth/refrescar`.
///
/// Las dos devuelven la misma forma, por eso un solo modelo. En la v1.1 trae
/// cuatro campos y **los cuatro son obligatorios** en el contrato.
class RespuestaLogin {
  const RespuestaLogin({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.debeCambiarContrasena,
  });

  factory RespuestaLogin.fromJson(Map<String, Object?> json) => RespuestaLogin(
    accessToken: leerTexto(json['accessToken'], 'accessToken'),
    expiresIn: leerEntero(json['expiresIn'], 'expiresIn'),
    refreshToken: leerTexto(json['refreshToken'], 'refreshToken'),
    debeCambiarContrasena: leerBool(
      json['debeCambiarContrasena'],
      'debeCambiarContrasena',
    ),
  );

  final String accessToken;

  /// Cuanto vive el access token, **en segundos** (RIC-1).
  ///
  /// Hoy son 3600, pero es configurable en el backend: la app usa el valor que
  /// llega y **no abre el JWT** para averiguarlo.
  final int expiresIn;

  /// Dura 30 dias y **se usa una sola vez** (RIC-2).
  ///
  /// Cada refresco devuelve uno nuevo, asi que hay que guardar siempre el
  /// ultimo. Si `POST /auth/refrescar` responde 401, la sesion termino.
  final String refreshToken;

  /// `true` si la contrasena es temporal y la app debe forzar el cambio
  /// (APP-2.3).
  final bool debeCambiarContrasena;
}
