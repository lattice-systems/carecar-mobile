import 'package:flutter/foundation.dart';

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
import '../api/modelos/modelos.dart';
import 'almacen_sesion.dart';

/// Estado de la sesion.
sealed class EstadoSesion {
  const EstadoSesion();
}

/// Nadie ha entrado, o se cerro la sesion.
class SinSesion extends EstadoSesion {
  const SinSesion();
}

/// Hay una peticion de login en curso.
class Autenticando extends EstadoSesion {
  const Autenticando();
}

/// Sesion iniciada.
class Autenticada extends EstadoSesion {
  const Autenticada({required this.debeCambiarContrasena});

  /// Si viene en `true`, la app debe forzar el cambio de contrasena.
  ///
  /// La pantalla de cambio es APP-2.3 y entra en S2, asi que hoy este dato se
  /// expone pero nadie lo consume todavia.
  final bool debeCambiarContrasena;
}

/// El login fallo. Se queda en la pantalla de login con el mensaje.
class FalloDeSesion extends EstadoSesion {
  const FalloDeSesion(this.mensaje, {this.esFalloDeRed = false});

  /// Siempre se puede mostrar al usuario.
  final String mensaje;

  /// `true` cuando no se pudo llegar al servidor.
  ///
  /// La tarea 3 de APP-2.1 pide distinguir «credenciales invalidas» de «sin
  /// conexion»: son dos situaciones distintas y el usuario tiene que saber cual
  /// de las dos le paso.
  final bool esFalloDeRed;
}

/// Maneja la sesion: inicia, cierra y guarda el token.
///
/// Es un [ChangeNotifier], que viene con Flutter: no agrega ninguna libreria,
/// y el acuerdo del equipo dice que no se agregan librerias que no esten
/// definidas. Si mas adelante se decide Riverpod, Bloc u otra cosa (depende de
/// la peticion EQ-1), se cambia esta clase sin tocar la pantalla ni la capa de
/// datos: la pantalla solo llama [iniciarSesion] y lee [estado].
class ControladorSesion extends ChangeNotifier {
  /// Recibe sus colaboradores por constructor: asi las pruebas pueden pasar una
  /// [CarecarApi] falsa sin levantar un servidor.
  ///
  /// Van posicionales, y no con nombre, porque los campos son privados y Dart
  /// no admite parametros con nombre que empiecen con guion bajo.
  ControladorSesion(this._api, this._almacen);

  final CarecarApi _api;
  final AlmacenSesion _almacen;

  EstadoSesion _estado = const SinSesion();
  EstadoSesion get estado => _estado;

  bool get haySesion => _estado is Autenticada;

  /// Evita que dos peticiones que reciben 401 a la vez gasten dos refresh
  /// tokens. El segundo espera el resultado del primero.
  ///
  /// Importa porque el refresh es de un solo uso (RIC-2): dos refrescos en
  /// paralelo harian que el segundo falle y cierre una sesion que estaba bien.
  Future<bool>? _refrescoEnCurso;

  /// Lo que `ClienteApi` usa para poner el encabezado `Authorization`.
  Future<String?> obtenerToken() async => (await _almacen.leer())?.accessToken;

  /// Recupera la sesion guardada al abrir la app.
  ///
  /// Es la razon de ser del almacenamiento seguro: sin esto, guardar los tokens
  /// no serviria de nada. Si el access token ya vencio pero el refresh sigue
  /// vivo, renueva en silencio; el cliente no vuelve a escribir su contrasena.
  Future<void> restaurar() async {
    final guardados = await _almacen.leer();
    if (guardados == null) return;

    if (guardados.vencido) {
      // Si el refresh tambien murio, `renovar` deja la sesion cerrada; si
      // funciono, hay que abrirla aqui. `renovar` no lo hace porque lo normal
      // es que la llamen a mitad de una peticion, con la sesion ya abierta.
      if (!await renovar()) return;
    }

    // `debeCambiarContrasena` solo viene en el login. Si el primer ingreso
    // quedo a medias, el backend lo vuelve a pedir en la siguiente peticion.
    _cambiarA(const Autenticada(debeCambiarContrasena: false));
  }

  /// Cambia el refresh token por un par nuevo. La usa `ClienteApi` ante un 401.
  ///
  /// Devuelve `true` si lo consiguio. Si no, **deja la sesion cerrada**: un
  /// refresh que ya no sirve significa que la sesion termino (RIC-2).
  Future<bool> renovar() => _refrescoEnCurso ??= _renovar().whenComplete(() {
    _refrescoEnCurso = null;
  });

  Future<bool> _renovar() async {
    final guardados = await _almacen.leer();
    if (guardados == null) return false;

    try {
      final nueva = await _api.refrescar(guardados.refreshToken);
      await _almacen.guardar(TokensSesion.deRespuesta(nueva));
      return true;
    } on SinConexion {
      // Sin red no se sabe si la sesion sigue viva: no se cierra, para no
      // sacar al cliente del tunel del metro.
      return false;
    } on ExcepcionApi {
      await _terminar();
      return false;
    }
  }

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    // Un doble toque no debe mandar dos logins.
    if (_estado is Autenticando) return;

    _cambiarA(const Autenticando());

    try {
      final sesion = await _api.iniciarSesion(
        PeticionLogin(correo: correo, contrasena: contrasena),
      );
      await _almacen.guardar(TokensSesion.deRespuesta(sesion));
      _cambiarA(
        Autenticada(debeCambiarContrasena: sesion.debeCambiarContrasena),
      );
    } on SinConexion catch (e) {
      _cambiarA(FalloDeSesion(e.mensaje, esFalloDeRed: true));
    } on ExcepcionApi catch (e) {
      // Cubre credenciales invalidas, cuenta desactivada, datos invalidos y
      // errores del servidor. El mensaje ya viene listo para mostrar.
      _cambiarA(FalloDeSesion(e.mensaje));
    } catch (e) {
      // Nada deberia llegar aqui, pero un error inesperado no puede dejar la
      // pantalla trabada en «Entrando…».
      _cambiarA(
        const FalloDeSesion('Ocurrió un error inesperado. Intenta de nuevo.'),
      );
    }
  }

  /// Cierra la sesion y **avisa al servidor** para que revoque el refresh
  /// token (RIC-4).
  ///
  /// Los tokens se borran pase lo que pase: si el aviso falla por falta de red,
  /// lo peor es que ese refresh siga vivo en el servidor hasta que expire, y
  /// eso es mejor que dejar la sesion abierta en el celular.
  Future<void> cerrarSesion() async {
    final guardados = await _almacen.leer();

    if (guardados != null) {
      try {
        await _api.cerrarSesion(guardados.refreshToken);
      } on ExcepcionApi {
        // Da igual por que fallo: la sesion se cierra en la app de todos modos.
      }
    }

    await _terminar();
  }

  /// Cierra la sesion porque el servidor contesto 403.
  ///
  /// En la app un 403 solo puede significar **cuenta desactivada**, porque un
  /// recurso ajeno responde 404 (RIC-3). No se avisa al servidor: ya fue el que
  /// lo dijo. La llama la pantalla que recibio `CuentaDesactivada`.
  Future<void> terminarPorCuentaDesactivada() => _terminar();

  /// Borra la sesion local sin avisarle al servidor.
  ///
  /// Se usa cuando el servidor ya dijo que la sesion no vale: un refresh
  /// vencido (401) o una cuenta desactivada (403). Avisar seria redundante.
  Future<void> _terminar() async {
    await _almacen.borrar();
    _cambiarA(const SinSesion());
  }

  void _cambiarA(EstadoSesion nuevo) {
    _estado = nuevo;
    notifyListeners();
  }
}
