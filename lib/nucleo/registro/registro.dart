import 'package:flutter/foundation.dart';

import 'redactor.dart';

export 'redactor.dart' show quitarDatosPersonales;

/// Unico camino para escribir en el registro de la app (V2-M22.07).
///
/// Todo lo que se registra pasa antes por [quitarDatosPersonales], asi que a
/// la salida no llega un correo, telefono, VIN ni token, ni siquiera dentro
/// del texto de una excepcion. Escribir directo con `print` o `debugPrint`
/// lo rechaza `test/arquitectura/registro_sin_datos_personales_test.dart`.
///
/// Los datos que no tienen forma reconocible (un nombre, una direccion) no
/// los puede tapar: esos no se registran. Ver `docs/seguridad/registro-sin-datos-personales.md`.
abstract final class Registro {
  /// A donde va el texto ya limpio. Las pruebas lo cambian por una lista.
  @visibleForTesting
  static void Function(String texto) salida = _imprimir;

  /// Registra [mensaje] y, si hay, el [error] que lo causo.
  static void depurar(String mensaje, {Object? error}) {
    final texto = error == null ? mensaje : '$mensaje: $error';
    salida(quitarDatosPersonales(texto));
  }

  /// Vuelve a la salida normal (consola de depuracion).
  @visibleForTesting
  static void restaurarSalida() => salida = _imprimir;

  static void _imprimir(String texto) => debugPrint(texto);
}
