import 'dart:async';

import '../../taller/taller.dart';
import '../dominio/actividad_en_vivo.dart';

/// Lleva la Live Activity del taller (V2-M25.05) al ritmo de las ordenes en
/// curso. Lo instancia `SincronizadorDeWidgets`, que le pasa cada lista nueva
/// de `GET /ordenes/activas` (se refresca con el evento `orden` del canal en
/// vivo, al reconectar y al volver a primer plano).
///
/// - Cada orden abierta tiene su actividad: se inicia al aparecer y se
///   repinta cuando cambia su [EstadoDeActividad].
/// - Cada push token que da ActivityKit (puede rotarlo) va al backend con
///   `PUT /ordenes/{id}/actividad-en-vivo`, que la sigue por APNs. Sin red se
///   reintenta en el siguiente cambio de ordenes; un 409 `ORDEN_CERRADA`
///   termina la actividad y no se reintenta.
/// - Cuando la orden deja de estar abierta (se entrego) la actividad termina
///   con el estado final y se queda un rato en la pantalla bloqueada.
/// - Al cerrar sesion ([alCerrarSesion]) da de baja en el backend cada
///   actividad y las termina; si la sesion se pierde sin cerrarla
///   ([alPerderLaSesion]) solo las termina.
///
/// Las operaciones con ActivityKit van una tras otra para que dos listas
/// seguidas no inicien dos actividades de la misma orden. Dejar de escuchar
/// los tokens no se espera: cancelar devuelve un futuro de la zona raíz que en
/// las pruebas con tiempo simulado nunca termina, y la fila se quedaría
/// atorada. Nada de esto lanza ni escribe en logs: el token identifica la
/// actividad.
class CoordinadorDeActividadEnVivo {
  CoordinadorDeActividadEnVivo({
    required this._servicio,
    required this._repositorio,
  });

  final ServicioActividadEnVivo _servicio;

  /// Se pide hasta que hace falta: donde no hay Live Activities la app nunca
  /// arma el cliente de esta ruta.
  final RepositorioActividadEnVivo Function() _repositorio;

  final _vivas = <int, _Actividad>{};

  /// Ordenes que el backend dijo que ya se entregaron (409): no se vuelven a
  /// iniciar en esta sesion aunque una lista vieja todavia las traiga.
  final _cerradas = <int>{};

  /// Si ya se terminaron las actividades de una ejecucion anterior que ya no
  /// corresponden a una orden abierta.
  var _revisadas = false;
  var _detenido = false;
  Future<void> _cola = Future.value();

  Future<void> _enCola(Future<void> Function() tarea) {
    final turno = _cola
        .then((_) => tarea())
        .then<void>((_) {}, onError: (Object _) {});
    _cola = turno;
    return turno;
  }

  /// Llego una lista nueva de ordenes en curso.
  Future<void> alCambiarLasOrdenes(List<OrdenEnCurso> ordenes) =>
      _enCola(() => _sincronizar(ordenes));

  /// Cerrar sesion: corre antes de avisar al servidor, con la sesion viva
  /// (`ControladorSesion.registrarAntesDeCerrarSesion`).
  Future<void> alCerrarSesion() => _enCola(() async {
    try {
      await _darDeBajaTodas();
    } on Object {
      // Sin baja en el backend la actividad igual se quita del telefono.
    }
    await _terminarTodas();
  });

  Future<void> _darDeBajaTodas() async {
    final ordenes = {..._vivas.keys, ...await _servicio.activas()};
    if (ordenes.isEmpty) return;
    final repositorio = _repositorio();
    await Future.wait([
      for (final ordenId in ordenes)
        repositorio
            .darDeBaja(ordenId: ordenId, pushToken: _vivas[ordenId]?.token)
            .then<void>((_) {}, onError: (Object _) {}),
    ]);
  }

  /// La sesion termino sin pasar por cerrar sesion (vencio, cuenta
  /// desactivada, equipo comprometido): ya no hay token para avisar al
  /// backend, pero la pantalla bloqueada no debe seguir mostrando la orden.
  Future<void> alPerderLaSesion() => _enCola(_terminarTodas);

  /// La app se desmonta: deja de escuchar tokens. Las actividades siguen en
  /// la pantalla bloqueada y el backend las sigue actualizando.
  void detener() {
    _detenido = true;
    for (final actividad in _vivas.values) {
      unawaited(actividad.tokens?.cancel());
    }
  }

  Future<void> _sincronizar(List<OrdenEnCurso> ordenes) async {
    if (_detenido) return;
    final abiertas = {
      for (final orden in ordenes)
        if (orden.etapa != EtapaTaller.entregado &&
            !_cerradas.contains(orden.id))
          orden.id: EstadoDeActividad.deOrden(orden),
    };

    for (final ordenId in [..._vivas.keys]) {
      if (!abiertas.containsKey(ordenId)) await _terminarEntregada(ordenId);
    }
    if (abiertas.isEmpty && _revisadas) return;
    if (!await _servicio.disponible()) return;

    if (!_revisadas) {
      _revisadas = true;
      for (final ordenId in await _servicio.activas()) {
        if (!abiertas.containsKey(ordenId)) await _servicio.terminar(ordenId);
      }
    }

    for (final MapEntry(key: ordenId, value: estado) in abiertas.entries) {
      final viva = _vivas[ordenId];
      if (viva == null) {
        await _iniciar(ordenId, estado);
      } else if (viva.estado != estado) {
        viva.estado = estado;
        await _servicio.actualizar(ordenId, estado);
      }
    }

    // Lo que no se pudo registrar antes (sin red) se intenta otra vez.
    for (final MapEntry(key: ordenId, value: actividad) in _vivas.entries) {
      if (actividad.token != null && !actividad.registrado) {
        unawaited(_registrar(ordenId, actividad));
      }
    }
  }

  Future<void> _iniciar(int ordenId, EstadoDeActividad estado) async {
    final actividad = _Actividad(estado);
    _vivas[ordenId] = actividad;
    // Se escucha antes de iniciar para no perder el primer token.
    actividad.tokens = _servicio
        .tokensDe(ordenId)
        .listen((token) => _alLlegarToken(ordenId, actividad, token));
    if (!await _servicio.iniciar(ordenId, estado)) {
      _vivas.remove(ordenId);
      unawaited(actividad.tokens?.cancel());
    }
  }

  void _alLlegarToken(int ordenId, _Actividad actividad, String token) {
    if (_detenido || actividad.cerrada || actividad.token == token) return;
    actividad
      ..token = token
      ..registrado = false;
    unawaited(_registrar(ordenId, actividad));
  }

  Future<void> _registrar(int ordenId, _Actividad actividad) async {
    final token = actividad.token;
    if (token == null ||
        actividad.enviando ||
        actividad.cerrada ||
        _detenido ||
        _vivas[ordenId] != actividad) {
      return;
    }
    actividad.enviando = true;
    try {
      await _repositorio().registrar(ordenId: ordenId, pushToken: token);
      if (actividad.token == token) actividad.registrado = true;
    } on OrdenYaEntregada {
      actividad.cerrada = true;
      unawaited(_enCola(() => _cerrarPorEntrega(ordenId, actividad)));
    } on Object {
      // Sin red o servidor caido: se reintenta en el siguiente cambio.
    } finally {
      actividad.enviando = false;
    }
    // Si ActivityKit roto el token mientras se mandaba, va el nuevo.
    if (!actividad.cerrada && actividad.token != token) {
      unawaited(_registrar(ordenId, actividad));
    }
  }

  /// El backend dijo que la orden ya se entrego.
  Future<void> _cerrarPorEntrega(int ordenId, _Actividad actividad) async {
    _cerradas.add(ordenId);
    if (_vivas[ordenId] != actividad) return;
    await _terminarEntregada(ordenId);
  }

  Future<void> _terminarEntregada(int ordenId) async {
    final actividad = _vivas.remove(ordenId);
    if (actividad == null) return;
    unawaited(actividad.tokens?.cancel());
    await _servicio.terminar(
      ordenId,
      estadoFinal: actividad.estado.entregada(),
    );
  }

  Future<void> _terminarTodas() async {
    for (final actividad in _vivas.values) {
      unawaited(actividad.tokens?.cancel());
    }
    _vivas.clear();
    _cerradas.clear();
    _revisadas = false;
    await _servicio.terminarTodas();
  }
}

class _Actividad {
  _Actividad(this.estado);

  EstadoDeActividad estado;
  StreamSubscription<String>? tokens;

  /// El ultimo push token que dio ActivityKit.
  String? token;

  /// El backend ya tiene [token].
  var registrado = false;
  var enviando = false;

  /// El backend contesto que la orden ya se entrego.
  var cerrada = false;
}
