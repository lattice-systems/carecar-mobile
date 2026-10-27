import 'dart:convert';

import '../api/modelos/comun.dart';
import '../api/modelos/sesion.dart';

/// Los dos tokens de la sesion, mas el momento en que vence el de acceso.
///
/// La v1.1 del contrato convirtio la sesion de un token a un par (RIC-1,
/// RIC-2):
///
/// - El **access token** vive lo que diga `expiresIn` en segundos. Hoy son
///   3600, pero es configurable en el backend: la app usa el valor que llega y
///   **no abre el JWT**, que era justo el acoplamiento que queriamos evitar.
/// - El **refresh token** dura 30 dias y **se usa una sola vez**. Cada refresco
///   devuelve un par nuevo, asi que hay que guardar siempre el ultimo.
///
/// Ojo con [expiraEn]: es un instante real en UTC, calculado en la app sumando
/// los segundos del servidor. **No es un dato del contrato**, asi que la regla
/// de RIC-13 —las fechas del contrato son hora local de la agencia y sin
/// zona— no aplica aqui.
class TokensSesion {
  const TokensSesion({
    required this.accessToken,
    required this.refreshToken,
    required this.expiraEn,
  });

  /// Arma el par a partir de los segundos de vida que devolvio el login.
  factory TokensSesion.conVida({
    required String accessToken,
    required String refreshToken,
    required int segundos,
  }) => TokensSesion(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiraEn: DateTime.now().toUtc().add(Duration(seconds: segundos)),
  );

  /// Arma el par con lo que devolvio `/auth/login` o `/auth/refrescar`.
  ///
  /// La conversion vive en esta capa, no en el modelo del contrato: el contrato
  /// habla de `expiresIn` en segundos y a la app le sirve un instante. Asi la
  /// capa de datos no tiene que conocer como se guarda la sesion.
  factory TokensSesion.deRespuesta(RespuestaLogin respuesta) =>
      TokensSesion.conVida(
        accessToken: respuesta.accessToken,
        refreshToken: respuesta.refreshToken,
        segundos: respuesta.expiresIn,
      );

  factory TokensSesion.fromJson(Map<String, Object?> json) => TokensSesion(
    accessToken: leerTexto(json['accessToken'], 'accessToken'),
    refreshToken: leerTexto(json['refreshToken'], 'refreshToken'),
    expiraEn: _leerInstante(json['expiraEn']),
  );

  final String accessToken;
  final String refreshToken;
  final DateTime expiraEn;

  /// `true` si el access token ya no sirve.
  bool get vencido => !DateTime.now().toUtc().isBefore(expiraEn);

  /// `true` si le quedan menos de [margen] de vida.
  ///
  /// Permite renovar antes de que el usuario vea un error, en lugar de esperar
  /// a que el servidor conteste 401.
  bool porVencer({Duration margen = const Duration(minutes: 1)}) =>
      DateTime.now().toUtc().add(margen).isAfter(expiraEn);

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiraEn': expiraEn.toIso8601String(),
  };

  static DateTime _leerInstante(Object? valor) {
    final texto = leerTexto(valor, 'expiraEn');
    final instante = DateTime.tryParse(texto);
    if (instante == null) {
      throw FormatException('El campo «expiraEn» no es una fecha: $texto');
    }
    return instante.toUtc();
  }
}

/// Donde vive la sesion.
///
/// Sigue siendo una abstraccion a proposito: la implementacion de verdad es
/// `AlmacenSeguro` (decision D-D), y [AlmacenEnMemoria] se queda para las
/// pruebas, que no deben depender del Keystore ni del Keychain.
abstract interface class AlmacenSesion {
  /// La sesion guardada, o `null` si no hay ninguna.
  Future<TokensSesion?> leer();

  /// Guarda el par. Reemplaza lo que hubiera, porque el refresh rota.
  Future<void> guardar(TokensSesion tokens);

  Future<void> borrar();
}

/// Guarda la sesion en memoria. Se pierde al cerrar la app.
///
/// Es lo que usan las pruebas. En la app corre [AlmacenSeguro].
class AlmacenEnMemoria implements AlmacenSesion {
  TokensSesion? _tokens;

  @override
  Future<TokensSesion?> leer() async => _tokens;

  @override
  Future<void> guardar(TokensSesion tokens) async => _tokens = tokens;

  @override
  Future<void> borrar() async => _tokens = null;
}

/// Serializa el par a texto. Lo usa [AlmacenSeguro] y se prueba aparte.
String serializarTokens(TokensSesion tokens) => jsonEncode(tokens.toJson());

/// Lee el par desde texto, o `null` si no se puede.
///
/// Devolver `null` en lugar de lanzar es deliberado: si el formato cambia entre
/// versiones de la app, lo peor aceptable es que el cliente vuelva a entrar.
/// Que la app no arranque no es aceptable.
TokensSesion? deserializarTokens(String? texto) {
  if (texto == null || texto.isEmpty) return null;
  try {
    final json = jsonDecode(texto);
    if (json is! Map<String, Object?>) return null;
    return TokensSesion.fromJson(json);
  } catch (_) {
    return null;
  }
}
