import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lo que la app necesita del sistema para desbloquear con huella o rostro.
///
/// Es una interfaz y no `local_auth` directo para que las pruebas no toquen la
/// plataforma -en una prueba de widget no hay BiometricPrompt- y para que
/// cambiar de plugin sea cambiar una clase.
abstract interface class LectorBiometrico {
  /// Si el equipo tiene biometria configurada **y utilizable ahora**.
  ///
  /// `false` tambien cuando el equipo la soporta pero nadie ha registrado una
  /// huella: ofrecer el candado entonces solo llevaria a un error.
  Future<bool> disponible();

  /// Que biometrias hay registradas, en un texto estable y comparable.
  ///
  /// Sirve para notar que **cambio la biometria del equipo**, que es un
  /// criterio de la historia. Ver [biometriaCambio] para lo que alcanza a ver.
  Future<String> firma();

  /// Pide identificarse. `true` si el sistema la reconocio.
  ///
  /// No devuelve nada mas: la app no ve datos biometricos, solo el si o el no.
  Future<bool> identificar({required String motivo});
}

/// Si la biometria del equipo dejo de ser la que habia al prender el candado.
///
/// ## Lo que esto alcanza a ver, y lo que no
///
/// Ve que **cambie el conjunto** de biometrias registradas: que se borren
/// todas, que se quite el rostro, que aparezca una clase nueva. **No** ve que
/// alguien agregue otra huella del mismo tipo, porque el sistema sigue
/// reportando «huella» y `local_auth` no expone mas.
///
/// Verlo exigiria una llave del Keystore creada con
/// `setInvalidatedByBiometricEnrollment`, es decir un canal nativo propio por
/// plataforma. Queda anotado como limitacion de esta historia y no se finge
/// que el criterio cubre mas de lo que cubre.
///
/// Una firma vacia o desconocida cuenta como cambio: ante la duda se pide la
/// contrasena, que es el lado seguro.
bool biometriaCambio({required String? guardada, required String ahora}) {
  if (guardada == null || guardada.isEmpty) return true;
  return guardada != ahora;
}

/// El lector del sistema. `main.dart` lo inyecta con el de `local_auth`.
///
/// Sin inyectar no hay biometria: el candado no se ofrece y la app se comporta
/// como antes de esta historia.
final lectorBiometricoProvider = Provider<LectorBiometrico?>(
  (ref) => null,
  name: 'lectorBiometricoProvider',
);
