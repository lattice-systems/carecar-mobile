import 'dart:async';

import '../dominio/push.dart';

/// Registra el token de push de este teléfono tras entrar y lo da de baja al
/// salir (V2-M06.02). Lo instancia `RegistradorDePush`, que le avisa cada vez
/// que cambian la sesión o el permiso de avisos.
///
/// - Se registra solo con sesión **y** avisos permitidos (V2-M06.01): sin
///   permiso el teléfono no mostraría nada, así que no tiene caso recibirlos.
/// - Cada token nuevo del proveedor (lo puede rotar) se vuelve a registrar.
/// - Al cerrar sesión ([alCerrarSesion]) da de baja la instalación **antes**
///   de que el servidor revoque la sesión (`registrarAntesDeCerrarSesion`).
///   Si la sesión se pierde sin cerrarla (403, refresh vencido) no llama: el
///   servidor ya no acepta esa cuenta.
/// - Negar los avisos con la sesión abierta también da de baja.
/// - Un fallo de red no lanza: se reintenta en el siguiente cambio o al volver
///   a primer plano. Nada de esto escribe en logs: el token es un dato
///   sensible.
///
/// Las operaciones van una tras otra para que un token nuevo y un cierre de
/// sesión no se crucen. Dejar de escuchar no se espera: el futuro de
/// `cancel()` puede no terminar nunca en pruebas con tiempo simulado.
class CoordinadorDePush {
  CoordinadorDePush({
    required this._servicio,
    required this._repositorio,
    required this._instalacion,
    required this._plataforma,
    required this._idioma,
  });

  final ServicioPush _servicio;

  /// Se arma hasta que hace falta: sin token (sin Firebase) la app nunca toca
  /// esta ruta.
  final RepositorioDispositivos Function() _repositorio;
  final Future<String> Function() _instalacion;
  final PlataformaPush _plataforma;
  final String? Function() _idioma;

  /// Hay sesión y avisos permitidos.
  var _activo = false;

  /// El token que el servidor ya tiene para esta instalación en esta sesión.
  String? _registrado;
  StreamSubscription<String>? _escucha;
  var _detenido = false;
  Future<void> _cola = Future.value();

  Future<void> _enCola(Future<void> Function() tarea) {
    final turno = _cola
        .then((_) => tarea())
        .then<void>((_) {}, onError: (Object _) {});
    _cola = turno;
    return turno;
  }

  /// Termina cuando ya no queda nada en la cola, incluidos los tokens que
  /// llegaron mientras tanto.
  Future<void> get pendiente async {
    Future<void> actual;
    do {
      actual = _cola;
      await actual;
    } while (!identical(actual, _cola));
  }

  /// Cambió la sesión o el permiso de avisos (o la app volvió a primer plano).
  Future<void> alCambiar({required bool haySesion, required bool permitidos}) =>
      _enCola(() async {
        if (_detenido) return;
        if (haySesion && permitidos) {
          _activo = true;
          _escucha ??= _servicio.tokensNuevos.listen(
            (token) => unawaited(_enCola(() => _registrar(token))),
          );
          if (_registrado == null) {
            final token = await _tokenActual();
            if (token != null) await _registrar(token);
          }
          return;
        }
        final estabaRegistrado = _registrado != null;
        _activo = false;
        _registrado = null;
        _dejarDeEscuchar();
        // Negó los avisos con la sesión abierta: deja de recibirlos.
        if (haySesion && estabaRegistrado) await _darDeBaja();
      });

  /// Cerrar sesión: corre antes de avisar al servidor, con la sesión viva
  /// (`ControladorSesion.registrarAntesDeCerrarSesion`).
  Future<void> alCerrarSesion() => _enCola(() async {
    final estabaRegistrado = _registrado != null;
    _activo = false;
    _registrado = null;
    _dejarDeEscuchar();
    // También si en esta ejecución no se registró (permiso negado ahora): una
    // ejecución anterior pudo dejarlo registrado. Sin token no hay nada.
    if (estabaRegistrado || await _tokenActual() != null) await _darDeBaja();
  });

  /// Deja de escuchar tokens para siempre (el widget se desmontó).
  void detener() {
    _detenido = true;
    _activo = false;
    _dejarDeEscuchar();
  }

  Future<void> _registrar(String token) async {
    if (!_activo || _detenido || token.isEmpty || token == _registrado) return;
    try {
      await _repositorio().registrar(
        instalacionId: await _instalacion(),
        tokenFcm: token,
        plataforma: _plataforma,
        idioma: _idioma(),
      );
      _registrado = token;
    } on Object {
      // Sin red o rechazado: se reintenta en el siguiente cambio.
    }
  }

  Future<void> _darDeBaja() async {
    try {
      await _repositorio().darDeBaja(await _instalacion());
    } on Object {
      // La sesión se cierra igual; el servidor descarta el token cuando FCM
      // le diga que ya no existe.
    }
  }

  Future<String?> _tokenActual() async {
    try {
      return await _servicio.tokenActual();
    } on Object {
      return null;
    }
  }

  void _dejarDeEscuchar() {
    unawaited(_escucha?.cancel());
    _escucha = null;
  }
}
