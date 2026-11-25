import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../sesion/almacen_seguro.dart';

/// Cifra y descifra las copias de la caché de la API (V2-M22.13).
///
/// La caché guarda correo, VIN y placas en `SharedPreferences`, que es un
/// archivo de texto legible para quien tenga el teléfono con root o una copia
/// de seguridad de iOS. Cifrarlas hace que ese archivo no diga nada sin la
/// llave, que vive en el Keystore de Android o el Keychain de iOS.
abstract interface class CifradorDeCache {
  /// Cifra [texto] y devuelve una cadena lista para guardar en disco.
  ///
  /// [contexto] (la clave de la copia, por ejemplo `vehiculos`) queda atado al
  /// resultado: una copia no se puede pasar a otra clave sin que falle.
  Future<String> cifrar(String texto, {required String contexto});

  /// Devuelve el texto original, o `null` si [guardado] no es una copia válida
  /// de este teléfono: texto sin cifrar de una versión anterior, alterado, de
  /// otro [contexto], de una llave que ya se olvidó, o si el almacenamiento
  /// seguro no responde. Nunca lanza: sin copia legible se pide a la red.
  Future<String?> descifrar(String guardado, {required String contexto});

  /// Olvida la llave: lo cifrado hasta ahora ya no se puede leer.
  Future<void> olvidar();
}

/// AES-256-GCM con una llave aleatoria guardada en el almacenamiento seguro.
///
/// GCM cifra y autentica: una copia alterada, o movida a otra clave de la
/// caché (va como dato asociado), no se descifra en vez de dar basura. Cada
/// copia lleva su propio nonce de 12 bytes y su etiqueta de 16.
///
/// La llave se crea la primera vez que hace falta y se reutiliza. Si el
/// almacenamiento seguro falla, no hay copias: es preferible pedir a la red que
/// guardar sin cifrar.
class CifradorAesGcm implements CifradorDeCache {
  CifradorAesGcm(this._almacenamiento);

  /// Dónde se guarda la llave. Si cambia, las copias existentes se descartan.
  static const claveEnAlmacen = 'carecar.cache.clave.v1';

  /// Formato de lo guardado: marca, y nonce + datos + etiqueta en base64url.
  static const _marca = 'c1.';
  static const _bytesDeLlave = 32;
  static const _bytesDeNonce = 12;
  static const _bytesDeEtiqueta = 16;

  final AlmacenamientoCifrado _almacenamiento;
  final AesGcm _algoritmo = AesGcm.with256bits();
  Future<SecretKey>? _llave;

  /// Una sola lectura o creación aunque lleguen varias peticiones a la vez:
  /// dos llaves distintas dejarían ilegible lo que cifró la primera.
  Future<SecretKey> _obtenerLlave() => _llave ??= _cargarOCrearLlave();

  Future<SecretKey> _cargarOCrearLlave() async {
    try {
      final guardada = await _almacenamiento.leer(claveEnAlmacen);
      final bytes = guardada == null ? null : _decodificar(guardada);
      if (bytes != null && bytes.length == _bytesDeLlave) {
        return SecretKey(bytes);
      }
      final nueva = await _algoritmo.newSecretKey();
      await _almacenamiento.escribir(
        claveEnAlmacen,
        base64Encode(await nueva.extractBytes()),
      );
      return nueva;
    } catch (_) {
      // Que el siguiente intento vuelva a probar, no que se quede el error.
      _llave = null;
      rethrow;
    }
  }

  /// Lo que se autentica además del texto: la clave de la copia en la caché.
  static List<int> _asociado(String contexto) => utf8.encode(contexto);

  static List<int>? _decodificar(String texto) {
    try {
      return base64Decode(texto);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<String> cifrar(String texto, {required String contexto}) async {
    final caja = await _algoritmo.encrypt(
      utf8.encode(texto),
      secretKey: await _obtenerLlave(),
      aad: _asociado(contexto),
    );
    return '$_marca${base64Url.encode(caja.concatenation())}';
  }

  @override
  Future<String?> descifrar(String guardado, {required String contexto}) async {
    if (!guardado.startsWith(_marca)) return null;
    try {
      final caja = SecretBox.fromConcatenation(
        base64Url.decode(guardado.substring(_marca.length)),
        nonceLength: _bytesDeNonce,
        macLength: _bytesDeEtiqueta,
      );
      final claro = await _algoritmo.decrypt(
        caja,
        secretKey: await _obtenerLlave(),
        aad: _asociado(contexto),
      );
      return utf8.decode(claro);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> olvidar() async {
    _llave = null;
    await _almacenamiento.borrar(claveEnAlmacen);
  }
}
