import 'cambio_de_correo_pendiente.dart';
import 'fallos_acceso.dart';
import 'perfil_del_cliente.dart';
import 'sesion_de_la_cuenta.dart';

/// Lo que el modulo `acceso` necesita del servidor · M01.
///
/// La presentacion depende de esta interfaz y no de `CarecarApi`, asi que una
/// prueba la sustituye sin levantar red y el dia que el contrato cambie se
/// toca `datos/`, no las pantallas.
abstract interface class RepositorioAcceso {
  /// `POST /auth/cambiar-contrasena`.
  ///
  /// Termina sin devolver nada: el contrato **no entrega una sesion nueva**,
  /// asi que `debeCambiarContrasena` sigue en `true` y quien llama tiene que
  /// marcar que ya se cambio (`contrasenaCambiadaProvider`).
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  });

  /// `POST /auth/recuperar-contrasena`.
  ///
  /// Manda al correo un enlace de un solo uso (V2-T05.04). **Termina bien
  /// exista o no la cuenta**: el contrato responde igual para no revelar que
  /// correos hay registrados, asi que quien llame no puede saberlo y la
  /// pantalla dice lo mismo en los dos casos.
  Future<void> pedirEnlaceDeRecuperacion(String correo);

  /// `POST /auth/restablecer-contrasena` con el token del enlace.
  ///
  /// Lanza [EnlaceNoValido] si el enlace vencio o ya se uso. Cualquier otro
  /// 400 -una contrasena que no cumple, por ejemplo- sale tal cual: los dos
  /// comparten codigo HTTP y solo los separa `Problema.codigo`.
  Future<void> restablecerConEnlace({
    required String token,
    required String contrasenaNueva,
  });

  /// `POST /auth/restablecer-contrasena` con el correo y el código de 6
  /// dígitos que trae el mismo correo de recuperación (V2-T02.27).
  ///
  /// Es el camino que sirve hoy: el enlace aún no abre la app (falta el
  /// dominio con enlaces universales). Lanza [CodigoNoValido] si el código
  /// vencio, ya se uso o esta mal escrito; una contrasena que no cumple sale
  /// tal cual, igual que con el enlace.
  Future<void> restablecerConCodigo({
    required String correo,
    required String codigo,
    required String contrasenaNueva,
  });

  /// `GET /perfil`: los datos del cliente que inicio sesion · V2-M01.06.
  ///
  /// De solo lectura: editarlos es V2-M01.07.
  Future<PerfilDelCliente> perfil();

  /// `PATCH /perfil`: pide cambiar el correo · V2-M01.07.
  ///
  /// **No cambia nada todavia**: manda un codigo al correo nuevo. Lanza
  /// [ContrasenaNoCoincide] si la contrasena actual no es la correcta y
  /// [CorreoEnUso] si ese correo ya es de otro cliente. Un correo mal escrito
  /// sale como el fallo de datos que es, **sin confundirse con la
  /// contrasena**: los dos llegan en 400 y solo los separa el codigo.
  Future<CambioDeCorreoPendiente> pedirCambioDeCorreo({
    required String correo,
    required String contrasenaActual,
  });

  /// `POST /perfil/verificaciones/{id}/confirmar`: aplica el cambio · V2-M01.07.
  ///
  /// Devuelve el perfil ya actualizado. Lanza [CodigoNoValido] si el codigo es
  /// equivocado, ya se uso o vencio -los tres llegan igual- y [CorreoEnUso] si
  /// alguien tomo ese correo mientras se verificaba.
  Future<PerfilDelCliente> confirmarCambioDeCorreo({
    required int id,
    required String codigo,
  });

  /// `GET /sesiones`: las sesiones vigentes de la cuenta · V2-M01.09.
  ///
  /// Llegan ordenadas por actividad, las mas recientes primero, y **el orden se
  /// conserva**: el servidor ya decidio que hacer con las que nunca se
  /// refrescaron, y reordenar aqui seria discrepar de el.
  Future<List<SesionDeLaCuenta>> sesiones();

  /// `DELETE /sesiones/{id}`: cierra esa sesion.
  ///
  /// Idempotente: cerrar una ya cerrada termina bien. Una sesion que no es de
  /// esta cuenta lanza `NoEncontrado`.
  Future<void> cerrarUnaSesion(int sesionId);

  /// `DELETE /sesiones`: cierra **todas**, incluida la de este celular.
  ///
  /// Quien llame tiene que cerrar la sesion local tambien: el access token en
  /// curso sigue valiendo hasta que expire.
  Future<void> cerrarTodasLasSesiones();
}
