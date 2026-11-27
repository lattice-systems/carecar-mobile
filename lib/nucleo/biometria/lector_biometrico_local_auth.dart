import 'package:local_auth/local_auth.dart';

import 'lector_biometrico.dart';

/// El [LectorBiometrico] de verdad · V2-M01.05.
///
/// **Es el unico archivo que importa `local_auth`.** Todo lo demas habla con
/// la interfaz, asi que el dia que el equipo prefiera un canal nativo propio se
/// cambia esta clase y nada mas.
class LectorBiometricoLocalAuth implements LectorBiometrico {
  LectorBiometricoLocalAuth([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Nunca propaga: la biometria es una comodidad, no un camino critico. Si la
  /// plataforma falla se responde que no hay, y la app pide la contrasena.
  @override
  Future<bool> disponible() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      // `canCheckBiometrics` dice que el equipo puede; la lista dice que
      // alguien registro algo. Sin lo segundo, ofrecer el candado llevaria a un
      // error en lugar de a una huella.
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  /// Las clases registradas, ordenadas para que el texto no dependa del orden
  /// en que las devuelva el sistema.
  @override
  Future<String> firma() async {
    try {
      final tipos =
          (await _auth.getAvailableBiometrics()).map((t) => t.name).toList()
            ..sort();
      return tipos.join(',');
    } on Object {
      return '';
    }
  }

  @override
  Future<bool> identificar({required String motivo}) async {
    try {
      return await _auth.authenticate(
        localizedReason: motivo,
        // Solo biometria: con el PIN del equipo bastaria el patron de la
        // pantalla, y lo que el criterio pide es huella o rostro.
        biometricOnly: true,
        // El dialogo se queda mientras la persona cambia de app -tipico al ir
        // a Ajustes a registrar una huella- en vez de cancelarse solo. En
        // local_auth 3 esta bandera se llama asi; antes era `stickyAuth`.
        persistAcrossBackgrounding: true,
      );
    } on Object {
      // Cancelar, agotar los intentos o cualquier error de la plataforma son
      // lo mismo para la app: no se desbloqueo.
      return false;
    }
  }
}
