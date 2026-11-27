import 'dart:async';

import '../dominio/actividad_en_vivo.dart';

/// ActivityKit en memoria para pruebas: guarda que actividades estan vivas y
/// con que estado, y deja a la prueba emitir push tokens con [emitirToken].
class ServicioActividadEnVivoFake implements ServicioActividadEnVivo {
  ServicioActividadEnVivoFake({
    this.estaDisponible = true,
    this.iniciaActividades = true,
    Map<int, EstadoDeActividad> previas = const {},
  }) : vivas = {...previas};

  /// Lo que contesta [disponible].
  bool estaDisponible;

  /// Si [iniciar] logra crear la actividad (el sistema puede negarse).
  bool iniciaActividades;

  /// Las actividades vivas y su ultimo estado, por orden.
  final Map<int, EstadoDeActividad> vivas;

  /// Lo que se le pidio, en orden: `iniciar:41`, `actualizar:41`,
  /// `terminar:41`, `terminarTodas`.
  final llamadas = <String>[];

  /// El estado final con que se termino cada orden (nulo: de inmediato).
  final finales = <int, EstadoDeActividad?>{};

  final _tokens = StreamController<(int, String)>.broadcast();

  /// Cuantas suscripciones a tokens siguen abiertas.
  var escuchas = 0;

  /// Simula que ActivityKit dio (o roto) el token de la actividad de [ordenId].
  void emitirToken(int ordenId, String token) => _tokens.add((ordenId, token));

  @override
  Future<bool> disponible() async => estaDisponible;

  @override
  Future<bool> iniciar(int ordenId, EstadoDeActividad estado) async {
    llamadas.add('iniciar:$ordenId');
    if (!estaDisponible || !iniciaActividades) return false;
    vivas[ordenId] = estado;
    return true;
  }

  @override
  Stream<String> tokensDe(int ordenId) {
    late final StreamSubscription<(int, String)> suscripcion;
    late final StreamController<String> salida;
    salida = StreamController<String>(
      onListen: () {
        escuchas++;
        suscripcion = _tokens.stream
            .where((t) => t.$1 == ordenId)
            .listen((t) => salida.add(t.$2));
      },
      onCancel: () {
        escuchas--;
        return suscripcion.cancel();
      },
    );
    return salida.stream;
  }

  @override
  Future<void> actualizar(int ordenId, EstadoDeActividad estado) async {
    llamadas.add('actualizar:$ordenId');
    if (vivas.containsKey(ordenId)) vivas[ordenId] = estado;
  }

  @override
  Future<void> terminar(int ordenId, {EstadoDeActividad? estadoFinal}) async {
    llamadas.add('terminar:$ordenId');
    vivas.remove(ordenId);
    finales[ordenId] = estadoFinal;
  }

  @override
  Future<void> terminarTodas() async {
    llamadas.add('terminarTodas');
    vivas.clear();
  }

  @override
  Future<List<int>> activas() async => vivas.keys.toList();
}
