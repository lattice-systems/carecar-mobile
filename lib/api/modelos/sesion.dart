import 'comun.dart';

/// Cuerpo de `POST /auth/login`.
///
/// En la v1.1 el campo es `correo`, no `usuario` (RIC-8, decision del PO). El
/// backend ignora mayusculas y espacios al inicio y al final, pero la app
/// recorta de todos modos para no mandar lo que el usuario pego sin querer.
class PeticionLogin {
  const PeticionLogin({
    required this.correo,
    required this.contrasena,
    this.dispositivo,
  });

  final String correo;
  final String contrasena;

  /// Nombre del celular, para que «mis sesiones abiertas» diga algo util
  /// (V2-M01.09). Es **opcional** en el contrato: sin el, la sesion queda sin
  /// nombre y la lista la muestra como un dispositivo desconocido.
  final String? dispositivo;

  /// Lo que el contrato declara en `maxLength` para `dispositivo`.
  static const maximoDispositivo = 80;

  Map<String, Object?> toJson() => {
    'correo': correo.trim(),
    'contrasena': contrasena,
    // Se recorta y se corta aqui, no en la pantalla: el nombre lo arma el
    // sistema operativo y puede ser largo. Si se mandara mas de lo que el
    // contrato acepta, el backend responderia 400 y el cliente no podria
    // entrar por el nombre de su celular.
    if (dispositivo != null) 'dispositivo': _nombreDelDispositivo(dispositivo!),
  };

  static String _nombreDelDispositivo(String valor) {
    final limpio = valor.trim();
    return limpio.length <= maximoDispositivo
        ? limpio
        : limpio.substring(0, maximoDispositivo);
  }
}

/// Cuerpo de `POST /auth/restablecer-contrasena`.
///
/// El contrato v2 (2.1.0) declara solo `contrasenaNueva` como obligatoria:
/// «Con `token`, o con `correo` y `codigo` (app v1). Si llega `token`, se usa
/// ese». Por eso hay **dos formas** y no una:
///
/// - [PeticionRestablecer.conEnlace] para el enlace de un solo uso que abre
///   la app (V2-M01.04 y V2-T05.04). Es la que pide la ficha.
/// - El constructor normal, con el codigo de 6 digitos de la v1.1 (RIC-18),
///   que la pantalla v1 sigue usando sin cambios.
///
/// Cada forma manda **solo sus campos**. Mandar un `correo` vacio junto al
/// token haria que el backend intentara la forma v1 y respondiera 400 por
/// datos invalidos en vez de usar el token.
class PeticionRestablecer {
  const PeticionRestablecer({
    required this.correo,
    required this.codigo,
    required this.contrasenaNueva,
  }) : token = null;

  /// Restablecer con el token del enlace que llego al correo.
  const PeticionRestablecer.conEnlace({
    required this.token,
    required this.contrasenaNueva,
  }) : correo = null,
       codigo = null;

  /// Token del enlace de un solo uso, cuando se restablece por enlace.
  final String? token;

  final String? correo;
  final String? codigo;
  final String contrasenaNueva;

  Map<String, Object?> toJson() => {
    // La contrasena no se recorta: un espacio puede ser parte de ella.
    if (token != null) 'token': token!.trim(),
    if (correo != null) 'correo': correo!.trim(),
    if (codigo != null) 'codigo': codigo!.trim(),
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

/// Una sesion abierta de la cuenta · `GET /sesiones` (V2-M01.09).
///
/// **Tres de los cinco campos pueden faltar**, y no es un caso raro: toda
/// sesion abierta antes de esta historia tiene `dispositivo`, `ultimoUso` e
/// `iniciadaEn` en nulo y sigue siendo valida. Si el modelo los exigiera, la
/// lista reventaria justo para quien ya estaba dentro.
///
/// Aqui **nunca** llega nada derivado del refresh token: con el hash se podria
/// revocar la sesion de otro, asi que el contrato no lo expone.
class SesionActiva {
  const SesionActiva({
    required this.id,
    required this.expiraEn,
    this.dispositivo,
    this.ultimoUso,
    this.iniciadaEn,
  });

  factory SesionActiva.fromJson(Map<String, Object?> json) => SesionActiva(
    id: leerEntero(json['id'], 'id'),
    expiraEn: leerMomentoUtc(json['expiraEn'], 'expiraEn'),
    dispositivo: json['dispositivo'] == null
        ? null
        : leerTexto(json['dispositivo'], 'dispositivo'),
    ultimoUso: json['ultimoUso'] == null
        ? null
        : leerMomentoUtc(json['ultimoUso'], 'ultimoUso'),
    iniciadaEn: json['iniciadaEn'] == null
        ? null
        : leerMomentoUtc(json['iniciadaEn'], 'iniciadaEn'),
  );

  final int id;

  /// Nombre que mando la app al entrar. Nulo en las sesiones de antes de
  /// V2-M01.09 y en las de un cliente que no lo manda.
  final String? dispositivo;

  /// Cuando se refresco por ultima vez. Nulo si nunca se ha refrescado, que es
  /// lo normal en una sesion que se acaba de abrir.
  final DateTime? ultimoUso;

  /// Cuando empezo la sesion de verdad: se conserva entre refrescos.
  final DateTime? iniciadaEn;

  /// A los 30 dias del **ultimo refresco**, no del inicio: usar la app la
  /// mantiene viva. Decirle al cliente «vence el 24 de diciembre» sin esa
  /// aclaracion seria mentirle.
  final DateTime expiraEn;
}
