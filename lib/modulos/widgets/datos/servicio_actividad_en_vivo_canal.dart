import 'package:flutter/services.dart';

import '../dominio/actividad_en_vivo.dart';

/// Live Activity del taller por un canal de plataforma propio (V2-M25.05).
///
/// Del otro lado esta `ios/Runner/PuenteActividadEnVivo.swift` (ActivityKit).
/// Contrato del canal [nombreCanal]:
/// - `disponible` → `bool`.
/// - `iniciar` `{ordenId, estado}` → `bool` (reutiliza la de esa orden si ya
///   existe).
/// - `actualizar` `{ordenId, estado}`, `terminar` `{ordenId, estado?}` y
///   `terminarTodas`.
/// - `activas` → lista de `ordenId`.
///
/// `estado` es el `content-state` de [EstadoDeActividad.comoContentState]. Por
/// [nombreCanalTokens] llegan `{ordenId, pushToken}` cada vez que ActivityKit
/// da o rota el token de una actividad.
///
/// Mientras el puente no este enlazado en Xcode, el canal contesta
/// [MissingPluginException]: desde ese momento todo es «no disponible» y no se
/// vuelve a llamar. Un [PlatformException] (actividades apagadas en Ajustes,
/// limite del sistema) tampoco rompe nada. No se registra nada: los tokens
/// identifican la actividad.
class ServicioActividadEnVivoCanal implements ServicioActividadEnVivo {
  ServicioActividadEnVivoCanal({
    this._metodos = const MethodChannel(nombreCanal),
    this._eventos = const EventChannel(nombreCanalTokens),
  });

  static const nombreCanal = 'carecar/actividad_en_vivo';
  static const nombreCanalTokens = 'carecar/actividad_en_vivo/tokens';

  final MethodChannel _metodos;
  final EventChannel _eventos;

  /// El canal contesto que no hay puente: ya no se le llama.
  var _sinPuente = false;

  /// El puente contesto `disponible`. Hasta entonces no se escuchan tokens:
  /// escuchar un canal de eventos sin puente reporta un error de Flutter.
  var _hayPuente = false;

  Stream<Object?>? _tokens;

  Future<T?> _invocar<T>(String metodo, [Object? argumentos]) async {
    if (_sinPuente) return null;
    try {
      final respuesta = await _metodos.invokeMethod<T>(metodo, argumentos);
      _hayPuente = true;
      return respuesta;
    } on MissingPluginException {
      _sinPuente = true;
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> disponible() async =>
      await _invocar<bool>('disponible') ?? false;

  @override
  Future<bool> iniciar(int ordenId, EstadoDeActividad estado) async =>
      await _invocar<bool>('iniciar', {
        'ordenId': ordenId,
        'estado': estado.comoContentState(),
      }) ??
      false;

  @override
  Stream<String> tokensDe(int ordenId) {
    if (_sinPuente || !_hayPuente) return const Stream.empty();
    final tokens = _tokens ??= _eventos.receiveBroadcastStream().handleError(
      (Object _) {},
    );
    return tokens
        .where((evento) => evento is Map && evento['ordenId'] == ordenId)
        .map((evento) => (evento! as Map)['pushToken'])
        .where((token) => token is String && esPushTokenValido(token))
        .cast<String>();
  }

  @override
  Future<void> actualizar(int ordenId, EstadoDeActividad estado) =>
      _invocar<void>('actualizar', {
        'ordenId': ordenId,
        'estado': estado.comoContentState(),
      });

  @override
  Future<void> terminar(int ordenId, {EstadoDeActividad? estadoFinal}) =>
      _invocar<void>('terminar', {
        'ordenId': ordenId,
        'estado': ?estadoFinal?.comoContentState(),
      });

  @override
  Future<void> terminarTodas() => _invocar<void>('terminarTodas');

  @override
  Future<List<int>> activas() async {
    final ordenes = await _invocar<List<Object?>>('activas');
    return [...?ordenes?.whereType<int>()];
  }
}
