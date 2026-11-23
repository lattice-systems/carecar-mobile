import 'dart:async';

import 'package:safe_device/safe_device.dart';

/// Lo que se sabe de la integridad del equipo (V2-M22.05).
enum EstadoIntegridad {
  /// La deteccion corrio y no encontro root ni jailbreak.
  integro,

  /// Root (Android) o jailbreak (iOS): el sistema ya no protege los datos de
  /// la app de otras apps.
  comprometido,

  /// Aun no se evalua, o la deteccion fallo o tardo demasiado. No es prueba de
  /// nada: la app funciona como siempre.
  desconocido,
}

/// Frontera con la deteccion de root y jailbreak.
///
/// Los modulos nunca importan el paquete que detecta: dependen de esta
/// interfaz, y en pruebas se usa [DetectorIntegridadFalso].
abstract interface class DetectorIntegridad {
  /// `true` si el equipo tiene root o jailbreak.
  Future<bool> estaComprometido();
}

/// Deteccion real con `safe_device` (MIT, Android e iOS).
///
/// Es una señal, no una garantia: un equipo comprometido puede ocultarlo. Por
/// eso solo avisa y limita lo que se guarda; nunca bloquea.
class DetectorIntegridadDelSistema implements DetectorIntegridad {
  const DetectorIntegridadDelSistema();

  @override
  Future<bool> estaComprometido() => SafeDevice.isJailBroken;
}

/// Detector para pruebas: responde lo que se le diga, o falla.
class DetectorIntegridadFalso implements DetectorIntegridad {
  const DetectorIntegridadFalso({this.comprometido = false, this.error});

  final bool comprometido;

  /// Si viene, [estaComprometido] lo lanza.
  final Object? error;

  @override
  Future<bool> estaComprometido() async {
    final e = error;
    if (e != null) throw e;
    return comprometido;
  }
}

/// Evalua el equipo sin poder romper el arranque.
///
/// Cualquier error o una espera mayor a [limite] da
/// [EstadoIntegridad.desconocido]. Nunca lanza ni registra nada.
Future<EstadoIntegridad> evaluarIntegridad(
  DetectorIntegridad detector, {
  Duration limite = const Duration(seconds: 3),
}) async {
  try {
    final comprometido = await detector.estaComprometido().timeout(limite);
    return comprometido
        ? EstadoIntegridad.comprometido
        : EstadoIntegridad.integro;
  } on Object {
    return EstadoIntegridad.desconocido;
  }
}
