/// Rutas del nucleo, con nombre y localizacion tipadas (V2-T01.03).
///
/// Ninguna pantalla escribe una ruta como texto suelto: usa estas constantes y
/// los constructores de localizacion. Cada modulo declara las suyas en su
/// propia carpeta (ver `lib/modulos/README.md`); aqui solo viven las del
/// nucleo (acceso, recuperacion, cambio obligatorio e inicio).
library;

/// Caminos (`path`) de las rutas del nucleo.
abstract final class Rutas {
  /// Menu principal. Requiere sesion.
  static const inicio = '/';

  /// Inicio de sesion. Es la salida de toda ruta privada sin sesion.
  static const acceso = '/acceso';

  /// Recuperar la contrasena pidiendo el codigo por correo.
  static const recuperar = '/recuperar';

  /// Destino del enlace de recuperacion: `carecar://restablecer?token=...`.
  static const restablecer = '/restablecer';

  /// Cambio obligatorio de la contrasena temporal (APP-2.3).
  static const cambiarContrasena = '/cambiar-contrasena';

  /// Parametro con la ruta a la que se vuelve tras iniciar sesion.
  static const parametroDesde = 'desde';

  /// Rutas que se pueden ver sin sesion. Todo lo demas, incluidas las de los
  /// modulos, exige sesion.
  static const publicas = {acceso, recuperar, restablecer};

  /// Acceso, con la ruta a la que volver despues de entrar.
  static String localizacionAcceso({String? desde}) =>
      _con(acceso, {parametroDesde: desde});

  /// Cambio obligatorio, con la ruta a la que volver despues de cambiar.
  static String localizacionCambiarContrasena({String? desde}) =>
      _con(cambiarContrasena, {parametroDesde: desde});

  static String localizacionRecuperar({String? correo}) =>
      _con(recuperar, {'correo': correo});

  /// Enlace de recuperacion. `token` es el codigo que llega por correo (hoy de
  /// 6 digitos, RIC-18); `correo` lo completa si el enlace lo trae.
  static String localizacionRestablecer({String? token, String? correo}) =>
      _con(restablecer, {'token': token, 'correo': correo});

  static String _con(String camino, Map<String, String?> parametros) {
    final validos = {
      for (final e in parametros.entries)
        if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
    };
    return Uri(
      path: camino,
      queryParameters: validos.isEmpty ? null : validos,
    ).toString();
  }
}

/// Nombres de las rutas del nucleo, para `context.goNamed`.
abstract final class NombresRuta {
  static const inicio = 'inicio';
  static const acceso = 'acceso';
  static const recuperar = 'recuperar';
  static const restablecer = 'restablecer';
  static const cambiarContrasena = 'cambiar-contrasena';
}
