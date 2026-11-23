import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bloqueo de capturas y grabaciones de pantalla (V2-M22.06).
///
/// Solo se activa en pantallas que muestran datos de pago o documentos
/// (`PantallaSegura`). Varias pantallas seguras pueden estar apiladas: el
/// bloqueo se mantiene mientras quede una y se libera al cerrar la ultima.
///
/// Limite por plataforma: Android lo logra con `FLAG_SECURE` (captura negra y
/// selector de apps vacio). iOS no deja bloquear capturas; ver
/// `docs/seguridad/ocultar-en-selector.md`.
abstract class ProteccionDeCaptura {
  int _activas = 0;

  /// Una pantalla segura entro. La primera activa el bloqueo.
  Future<void> bloquear() async {
    _activas++;
    if (_activas == 1) await aplicar(bloqueada: true);
  }

  /// Una pantalla segura salio. La ultima desactiva el bloqueo.
  Future<void> permitir() async {
    if (_activas == 0) return;
    _activas--;
    if (_activas == 0) await aplicar(bloqueada: false);
  }

  /// Cambia el estado real en la plataforma.
  Future<void> aplicar({required bool bloqueada});
}

/// Implementacion real: un canal de plataforma minimo. Android pone o quita
/// `FLAG_SECURE`; iOS no implementa el canal y la llamada se ignora.
class ProteccionDeCapturaCanal extends ProteccionDeCaptura {
  static const nombreCanal = 'mx.carecar/privacidad';
  static const _canal = MethodChannel(nombreCanal);

  @override
  Future<void> aplicar({required bool bloqueada}) async {
    try {
      await _canal.invokeMethod<void>(bloqueada ? 'bloquear' : 'permitir');
    } on MissingPluginException {
      // iOS, escritorio y pruebas: no hay forma nativa de bloquear.
    } on PlatformException {
      // Nunca debe romper una pantalla de pago por no poder proteger.
    }
  }
}

/// Doble para pruebas: guarda el estado sin tocar la plataforma.
class ProteccionDeCapturaFake extends ProteccionDeCaptura {
  /// Cada cambio real aplicado, en orden.
  final List<bool> llamadas = [];

  bool get bloqueada => llamadas.isNotEmpty && llamadas.last;

  @override
  Future<void> aplicar({required bool bloqueada}) async =>
      llamadas.add(bloqueada);
}

final proteccionDeCapturaProvider = Provider<ProteccionDeCaptura>(
  (ref) => ProteccionDeCapturaCanal(),
);
