/// Codigos de error propios del contrato v1.1 (RIC-15).
///
/// Sirven para distinguir dos errores que comparten codigo HTTP sin leer el
/// texto: los dos 409 de cancelar una cita, o el codigo de recuperacion
/// invalido contra una contrasena que no cumple, que son los dos un 400.
///
/// La regla de RIC-15 es: **decidir por el codigo cuando venga; si no viene,
/// por el `status`**. Por eso [CodigoProblema.desconocido] existe y nunca se
/// trata como error: solo significa «el servidor no mando codigo».
enum CodigoProblema {
  credencialesInvalidas('CREDENCIALES_INVALIDAS'),
  cuentaDesactivada('CUENTA_DESACTIVADA'),
  demasiadosIntentos('DEMASIADOS_INTENTOS'),
  codigoInvalido('CODIGO_INVALIDO'),
  datosInvalidos('DATOS_INVALIDOS'),
  franjaSinCupo('FRANJA_SIN_CUPO'),
  fueraDePlazo('FUERA_DE_PLAZO'),
  citaNoCancelable('CITA_NO_CANCELABLE'),

  /// No vino `codigo`, o vino uno que el contrato todavia no declara.
  desconocido('');

  const CodigoProblema(this.enElContrato);

  final String enElContrato;

  static CodigoProblema desde(String? valor) {
    if (valor == null) return desconocido;
    for (final c in values) {
      if (c != desconocido && c.enElContrato == valor) return c;
    }
    return desconocido;
  }
}

/// Formato de error del backend (el `ApiError` de `shared/exception`).
///
/// **El [message] no siempre se puede mostrar** (RIC-14): si en 401, 403, 404,
/// 409 y 429; no en 400 ni en 5xx, donde trae nombres de campos o el detalle
/// tecnico de la excepcion. Quien decide es [mensajeMostrable].
class Problema {
  const Problema({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
    this.codigo = CodigoProblema.desconocido,
  });

  /// Tolerante a proposito: un cuerpo de error incompleto no debe provocar un
  /// segundo error mientras se intenta reportar el primero.
  factory Problema.fromJson(Map<String, Object?> json) => Problema(
    timestamp: json['timestamp'] as String? ?? '',
    status: (json['status'] as num?)?.toInt() ?? 0,
    error: json['error'] as String? ?? 'Error',
    message: (json['message'] as String?)?.trim().isNotEmpty == true
        ? json['message'] as String
        : 'Ocurrió un error inesperado. Intenta de nuevo.',
    path: json['path'] as String? ?? '',
    codigo: CodigoProblema.desde(json['codigo'] as String?),
  );

  final String timestamp;
  final int status;
  final String error;
  final String message;
  final String path;

  /// El codigo propio del contrato, o [CodigoProblema.desconocido] si no vino.
  final CodigoProblema codigo;

  /// `true` si el [message] del servidor se le puede enseñar al usuario.
  ///
  /// RIC-14: viene escrito para el usuario en 401, 403, 404, 409 y 429. En 400
  /// esta escrito para quien programa («contrasenaNueva: ...») y en 5xx trae
  /// el detalle tecnico de la excepcion, asi que en esos dos la app pone su
  /// propio texto.
  bool get mensajeEsParaElUsuario =>
      const {401, 403, 404, 409, 429}.contains(status);
}
