import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// El identificador de esta instalación de la app (V2-M06.02): el
/// `instalacionId` de `/dispositivos/{instalacionId}`.
///
/// Es un UUID v4 que se genera una sola vez y se guarda en preferencias. No es
/// un secreto ni un dato personal: solo dice «este teléfono» para que el
/// servidor tenga un token por instalación y reemplace el viejo al rotar.
/// Sobrevive al cerrar sesión, porque es del teléfono y no de la cuenta. Sin
/// preferencias (pruebas, arranque fallido) dura lo que dure el proceso.
class InstalacionDeLaApp {
  InstalacionDeLaApp(this._prefs, {Random? azar})
    : _azar = azar ?? Random.secure();

  final SharedPreferences? _prefs;
  final Random _azar;
  String? _enMemoria;

  static const clave = 'push.instalacion_id';

  /// Lo que acepta el contrato (`InstalacionId`).
  static final _valido = RegExp(r'^[A-Za-z0-9-]{8,64}$');

  Future<String> obtener() async {
    final guardado = _prefs?.getString(clave);
    if (guardado != null && _valido.hasMatch(guardado)) return guardado;
    final nuevo = _enMemoria ??= _uuidV4();
    await _prefs?.setString(clave, nuevo);
    return nuevo;
  }

  String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => _azar.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
