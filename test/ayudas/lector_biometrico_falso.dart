import 'package:carecar_mobile/nucleo/biometria/lector_biometrico.dart';

/// Un [LectorBiometrico] que responde lo que la prueba le diga · V2-M01.05.
///
/// En una prueba no hay BiometricPrompt: sin esto, la unica forma de probar el
/// candado seria en un celular a mano.
class LectorBiometricoFalso implements LectorBiometrico {
  LectorBiometricoFalso({
    this.hay = true,
    this.firmaDelEquipo = 'fingerprint',
    this.reconoce = true,
  });

  bool hay;

  /// Que biometrias dice tener el equipo ahora.
  String firmaDelEquipo;

  /// Si el sistema reconoce a la persona.
  bool reconoce;

  int identificaciones = 0;

  @override
  Future<bool> disponible() async => hay;

  @override
  Future<String> firma() async => firmaDelEquipo;

  @override
  Future<bool> identificar({required String motivo}) async {
    identificaciones++;
    return reconoce;
  }
}
