import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';

/// Fallos listos para pruebas · V2-T01.08, criterio 4.
///
/// Existen porque armar un [Problema] a mano son seis campos obligatorios, y
/// repetirlos en cada prueba invita a cambiar uno sin querer y probar otra cosa
/// de la que se cree.
///
/// Se usan junto con [RepositorioFalso] para recorrer los tipos de error que
/// pide el criterio 5 sin levantar red:
///
/// ```dart
/// final repositorio = RepositorioFalso(vehiculos, falla: Fallos.sinConexion());
/// ```

/// Un [Problema] del contrato con lo minimo para que sea realista.
Problema problemaDePrueba(
  int status, {
  CodigoProblema codigo = CodigoProblema.desconocido,
  String message = 'Mensaje del backend.',
  String path = '/api/v1/app/recurso',
}) => Problema(
  timestamp: '2026-11-23T20:00:00Z',
  status: status,
  error: 'Error',
  message: message,
  path: path,
  codigo: codigo,
);

/// Un [Fallo] por cada caso que la app tiene que saber distinguir.
abstract final class Fallos {
  /// No se pudo llegar al servidor. Nunca hubo respuesta, asi que no hay
  /// `status` ni `Problema`.
  static Fallo sinConexion() => const SinConexion();

  /// 401 · la sesion termino, o las credenciales no pasaron.
  static Fallo sesionTerminada({
    String mensaje = 'Tu sesión terminó. Inicia sesión de nuevo.',
  }) => CredencialesInvalidas(
    mensaje,
    problema: problemaDePrueba(
      401,
      codigo: CodigoProblema.credencialesInvalidas,
      message: mensaje,
    ),
  );

  /// 403 · la agencia desactivo la cuenta (CRM-1.3).
  static Fallo cuentaDesactivada({
    String mensaje = 'Tu cuenta está desactivada. Comunícate con la agencia.',
  }) => CuentaDesactivada(
    mensaje,
    problema: problemaDePrueba(
      403,
      codigo: CodigoProblema.cuentaDesactivada,
      message: mensaje,
    ),
  );

  /// 404 · no existe **o no es del cliente**. El contrato no los distingue.
  static Fallo noEncontrado({
    String mensaje = 'No encontramos lo que buscas.',
  }) =>
      NoEncontrado(mensaje, problema: problemaDePrueba(404, message: mensaje));

  /// 409 · se decide por el [codigo], no por el texto (RIC-15).
  static Fallo conflicto(
    CodigoProblema codigo, {
    String mensaje = 'No se pudo completar la operación.',
  }) => Conflicto(
    mensaje,
    problema: problemaDePrueba(409, codigo: codigo, message: mensaje),
  );

  /// 400 · los datos de entrada no pasaron la validacion.
  ///
  /// El `message` real trae nombres de campos, asi que la app pone el suyo
  /// (RIC-14). Aqui se refleja igual para que las pruebas vean lo que vera el
  /// usuario.
  static Fallo validacion({
    String mensaje = 'Revisa los datos e intenta otra vez.',
  }) => DatosInvalidos(
    mensaje,
    problema: problemaDePrueba(
      400,
      codigo: CodigoProblema.datosInvalidos,
      message: 'contrasenaNueva: must not be blank',
    ),
  );

  /// 5xx · fallo del servidor. Tambien lleva texto propio, no el del backend.
  static Fallo servidor({
    String mensaje = 'Ocurrió un error inesperado. Intenta de nuevo más tarde.',
  }) => ErrorDelServidor(
    mensaje,
    problema: problemaDePrueba(500, message: 'NullPointerException'),
    status: 500,
  );

  /// 429 · cinco intentos fallidos bloquean el login 15 minutos (RIC-5).
  static Fallo demasiadosIntentos({
    int esperaSegundos = 900,
    String mensaje = 'Demasiados intentos. Espera antes de volver a probar.',
  }) => DemasiadosIntentos(
    mensaje,
    problema: problemaDePrueba(
      429,
      codigo: CodigoProblema.demasiadosIntentos,
      message: mensaje,
    ),
    esperaSegundos: esperaSegundos,
  );
}
