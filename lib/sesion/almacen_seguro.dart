import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'almacen_sesion.dart';

/// Lo minimo que [AlmacenSeguro] necesita del almacenamiento del sistema.
///
/// Es un puerto propio y no `FlutterSecureStorage` directo para que las pruebas
/// puedan pasar un doble: el plugin de verdad necesita el Keystore de Android o
/// el Keychain de iOS, o sea un dispositivo. Tambien deja cambiar de libreria
/// sin tocar [AlmacenSeguro].
abstract interface class AlmacenamientoCifrado {
  Future<String?> leer(String clave);
  Future<void> escribir(String clave, String valor);
  Future<void> borrar(String clave);
}

/// El almacenamiento cifrado del sistema operativo.
///
/// Android usa el Keystore y iOS el Keychain. **Esta clase no se puede probar
/// sin un dispositivo**, y por eso no tiene logica: solo traduce las llamadas.
/// Todo lo que se puede equivocar vive en [AlmacenSeguro], que si se prueba.
class AlmacenamientoDelSistema implements AlmacenamientoCifrado {
  AlmacenamientoDelSistema([FlutterSecureStorage? almacenamiento])
    : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  final FlutterSecureStorage _almacenamiento;

  @override
  Future<String?> leer(String clave) => _almacenamiento.read(key: clave);

  @override
  Future<void> escribir(String clave, String valor) =>
      _almacenamiento.write(key: clave, value: valor);

  @override
  Future<void> borrar(String clave) => _almacenamiento.delete(key: clave);
}

/// Guarda la sesion en el almacenamiento cifrado del sistema (decision D-D).
///
/// Los dos tokens van **juntos en una sola entrada**, no en dos: asi no puede
/// quedar un access token sin su refresh si algo falla a la mitad.
class AlmacenSeguro implements AlmacenSesion {
  /// Recibe el almacenamiento posicional, como [ControladorSesion], porque el
  /// campo es privado y Dart no admite parametros con nombre con guion bajo.
  AlmacenSeguro(this._sistema);

  /// Usa el almacenamiento cifrado real. Es lo que arma `main.dart`.
  AlmacenSeguro.delSistema() : _sistema = AlmacenamientoDelSistema();

  /// La clave de la entrada. Si cambia, las sesiones guardadas se pierden y el
  /// cliente vuelve a entrar una vez.
  static const clave = 'carecar.sesion.v1';

  final AlmacenamientoCifrado _sistema;

  @override
  Future<TokensSesion?> leer() async =>
      deserializarTokens(await _sistema.leer(clave));

  @override
  Future<void> guardar(TokensSesion tokens) =>
      _sistema.escribir(clave, serializarTokens(tokens));

  @override
  Future<void> borrar() => _sistema.borrar(clave);
}
