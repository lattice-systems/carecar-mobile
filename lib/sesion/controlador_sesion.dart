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

  /// Lo que `ClienteApi` usa para poner el encabezado `Authorization`.
  Future<String?> obtenerToken() => _almacen.leerToken();

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
      await _almacen.guardarToken(sesion.accessToken);
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

  Future<void> cerrarSesion() async {
    await _almacen.borrarToken();
    _cambiarA(const SinSesion());
  }

  void _cambiarA(EstadoSesion nuevo) {
    _estado = nuevo;
    notifyListeners();
  }
}
