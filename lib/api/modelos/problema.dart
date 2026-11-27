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
  sinParametrosDeValuacion('SIN_PARAMETROS_DE_VALUACION'),
  citaDuplicada('CITA_DUPLICADA'),
  citaNoReprogramable('CITA_NO_REPROGRAMABLE'),
  citaCancelada('CITA_CANCELADA'),
  walletNoConfigurado('WALLET_NO_CONFIGURADO'),
  asistenteSinManual('ASISTENTE_SIN_MANUAL'),
  asistenteLimite('ASISTENTE_LIMITE'),
  asistenteNoDisponible('ASISTENTE_NO_DISPONIBLE'),
  solicitudAbierta('SOLICITUD_ABIERTA'),
  fueraDeCobertura('FUERA_DE_COBERTURA'),
  direccionEnUso('DIRECCION_EN_USO'),
  ordenCerrada('ORDEN_CERRADA'),
  adicionalYaRespondido('ADICIONAL_YA_RESPONDIDO'),
  kmInvalido('KM_INVALIDO'),

  /// Solo la devuelven los endpoints internos del backend al mover una
  /// solicitud o un traslado a un estado que no corresponde; la app no los
  /// llama, pero reconoce el codigo si algun dia llega.
  transicionInvalida('TRANSICION_INVALIDA'),
  estrenoSinPrecio('ESTRENO_SIN_PRECIO'),
  estrenoDuplicada('ESTRENO_DUPLICADA'),

  /// V2-M22.01: se quiso aceptar un aviso de privacidad que ya no es el
  /// vigente; hay que leer el nuevo.
  avisoNoVigente('AVISO_NO_VIGENTE'),

  /// V2-M10.03: la campana de seguridad ya esta agendada o atendida.
  campanaNoAgendable('CAMPANA_NO_AGENDABLE'),

  /// V2-M26.01: la estimacion se capturo a mano, sin un vehiculo registrado.
  valuacionSinVehiculo('VALUACION_SIN_VEHICULO'),

  /// V2-M26.02: la valuacion ya no admite fotos.
  valuacionCerrada('VALUACION_CERRADA'),

  /// V2-M26.03: la valuacion ya tiene cita o ya no se puede agendar.
  valuacionNoAgendable('VALUACION_NO_AGENDABLE'),

  /// V2-M26.04: la vigencia de la oferta ya paso.
  ofertaVencida('OFERTA_VENCIDA'),

  /// V2-M26.04: no hay una oferta que responder con ese monto o ya se
  /// respondio lo contrario.
  ofertaNoDisponible('OFERTA_NO_DISPONIBLE'),

  /// V2-M12.03: no alcanzan los puntos para la recompensa.
  saldoInsuficiente('SALDO_INSUFICIENTE'),

  /// V2-M12.03: la recompensa se agoto.
  recompensaAgotada('RECOMPENSA_AGOTADA'),

  /// V2-M12.04: esa persona ya es cliente o ya la refirieron.
  referidoDuplicado('REFERIDO_DUPLICADO'),

  /// V2-M12.04: el cliente ya tiene el maximo de referidos en seguimiento.
  limiteReferidos('LIMITE_REFERIDOS'),

  /// V2-M14.02: no alcanzan las piezas para apartar.
  sinExistencia('SIN_EXISTENCIA'),

  /// V2-M14.03: la cita esta cancelada o ya paso.
  citaNoDisponible('CITA_NO_DISPONIBLE'),

  /// V2-M14.02: ya hay el maximo de pedidos sin entregar.
  limiteApartados('LIMITE_APARTADOS'),

  /// V2-M14.02: el pedido ya se entrego.
  pedidoNoCancelable('PEDIDO_NO_CANCELABLE'),

  /// V2-M14.03: el pedido ya se entrego o se cancelo.
  pedidoNoModificable('PEDIDO_NO_MODIFICABLE'),

  /// V2-M14.03: algun producto no le queda al vehiculo de la cita.
  productoIncompatible('PRODUCTO_INCOMPATIBLE'),

  /// V2-M08.05: un dato fiscal no cumple las reglas del SAT; [Problema.campos]
  /// dice que corregir en cada uno.
  datosFiscalesInvalidos('DATOS_FISCALES_INVALIDOS'),

  /// V2-M08.02: la orden no se puede pagar en la app (aun no esta lista, no
  /// viene del taller, no tiene total o ya esta pagada, tambien en caja).
  ordenNoPagable('ORDEN_NO_PAGABLE'),

  /// V2-M08.02: otro intento de pago de la orden espera el 3-D Secure.
  pagoEnCurso('PAGO_EN_CURSO'),

  /// V2-M08.02: el pago ya no espera el 3-D Secure.
  pagoNoPendiente('PAGO_NO_PENDIENTE'),

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
    this.campos = const {},
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
    campos: _campos(json['campos']),
  );

  static Map<String, String> _campos(Object? valor) => valor is Map
      ? {
          for (final MapEntry(:key, :value) in valor.entries)
            if (key is String && value is String) key: value,
        }
      : const {};

  final String timestamp;
  final int status;
  final String error;
  final String message;
  final String path;

  /// El codigo propio del contrato, o [CodigoProblema.desconocido] si no vino.
  final CodigoProblema codigo;

  /// Que esta mal en cada campo de la peticion (nombre del campo → por que),
  /// escrito para la persona. Vacio si el error no lo explica por campo
  /// (V2-M08.05, `DATOS_FISCALES_INVALIDOS`).
  final Map<String, String> campos;

  /// `true` si el [message] del servidor se le puede enseñar al usuario.
  ///
  /// RIC-14: viene escrito para el usuario en 401, 403, 404, 409 y 429. En 400
  /// esta escrito para quien programa («contrasenaNueva: ...») y en 5xx trae
  /// el detalle tecnico de la excepcion, asi que en esos dos la app pone su
  /// propio texto.
  bool get mensajeEsParaElUsuario =>
      const {401, 403, 404, 409, 429}.contains(status);
}
