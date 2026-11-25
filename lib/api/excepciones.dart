import 'modelos/problema.dart';

/// Falla al hablar con la API.
///
/// [mensaje] siempre se puede mostrar al usuario: o viene del `message` del
/// backend, que la guia de estilos pide mostrar tal cual, o es un texto propio
/// que dice que paso y que hacer.
sealed class ExcepcionApi implements Exception {
  const ExcepcionApi(this.mensaje, {this.problema});

  final String mensaje;

  /// El error del backend, cuando vino con el formato del contrato.
  final Problema? problema;

  @override
  String toString() => '$runtimeType: $mensaje';
}

/// No se pudo llegar al servidor: sin red, servidor apagado, DNS, timeout.
///
/// Es el caso que APP-2.1 pide distinguir de «credenciales invalidas».
class SinConexion extends ExcepcionApi {
  const SinConexion([this.causa, String mensaje = mensajePorOmision])
    : super(mensaje);

  /// Lo que dice la excepcion cuando no hay una causa mas precisa.
  static const mensajePorOmision =
      'No se pudo conectar con el servidor. Intenta de nuevo.';

  final Object? causa;
}

/// El certificado del servidor no se pudo verificar (V2-M22.15).
///
/// Con los certificados fijados (V2-M22.04) pasa si una red con filtros
/// (WiFi público, escuela, trabajo) presenta otro certificado, o si el servidor
/// cambió de autoridad. La conexión se corta para no hablar con quien no es el
/// servidor. Es una [SinConexion]: la caché y las pantallas la tratan igual y
/// solo el aviso global la distingue.
class ConexionNoSegura extends SinConexion {
  const ConexionNoSegura([Object? causa])
    : super(
        causa,
        'No pudimos verificar que la conexión sea segura. Prueba con otra '
        'red o con datos móviles.',
      );
}

/// 401 · Sin token, token invalido o credenciales incorrectas.
class CredencialesInvalidas extends ExcepcionApi {
  const CredencialesInvalidas(super.mensaje, {super.problema});
}

/// 403 · En el login, la cuenta esta desactivada (CRM-1.3).
///
/// El mock tambien lo usa para una cuenta desactivada con un token todavia
/// vigente. El contrato no define ese caso: es la pregunta RIC-3.
class CuentaDesactivada extends ExcepcionApi {
  const CuentaDesactivada(super.mensaje, {super.problema});
}

/// 404 · No existe **o no pertenece al cliente**.
///
/// El contrato usa el mismo codigo para los dos casos a proposito, para que la
/// app no pueda distinguirlos.
class NoEncontrado extends ExcepcionApi {
  const NoEncontrado(super.mensaje, {super.problema});
}

/// 400 · Datos de entrada invalidos.
class DatosInvalidos extends ExcepcionApi {
  const DatosInvalidos(super.mensaje, {super.problema});
}

/// 409 · Franja sin cupo, doble reserva, o fuera del plazo de cancelacion.
class Conflicto extends ExcepcionApi {
  const Conflicto(super.mensaje, {super.problema});
}

/// 422 · El servidor entendio la peticion pero la rechaza por una regla de
/// negocio. Cual regla lo dice [codigo] (`FUERA_DE_COBERTURA`, `KM_INVALIDO`,
/// `SIN_PARAMETROS_DE_VALUACION`…), no el endpoint ni el texto.
///
/// Cada repositorio traduce el codigo que le toca a su fallo de dominio; un
/// 422 con otro codigo pasa tal cual en lugar de confundirse con el suyo.
class SolicitudRechazada extends ExcepcionApi {
  const SolicitudRechazada(super.mensaje, {super.problema});

  /// El codigo del contrato, o `desconocido` si el servidor no mando uno.
  CodigoProblema get codigo => problema?.codigo ?? CodigoProblema.desconocido;
}

/// 422 de `POST /toma-a-cuenta/estimaciones`: la agencia todavia no tiene
/// parametros para esa marca, modelo y anio (`SIN_PARAMETROS_DE_VALUACION`).
///
/// No es un fallo de la app ni del cliente: la app lo explica y ofrece pedir
/// una valuacion formal.
class SinParametrosDeValuacion extends SolicitudRechazada {
  const SinParametrosDeValuacion(super.mensaje, {super.problema});
}

/// 429 · Cinco intentos fallidos seguidos: el login se bloquea 15 minutos.
///
/// RIC-5. Sin este caso, un bloqueo se veria como «ocurrio un error
/// inesperado», que es justo lo contrario de lo que el usuario necesita saber.
class DemasiadosIntentos extends ExcepcionApi {
  const DemasiadosIntentos(
    super.mensaje, {
    super.problema,
    this.esperaSegundos,
  });

  /// Lo que dice el encabezado `Retry-After`, en segundos, si vino.
  final int? esperaSegundos;

  /// «15 minutos», «45 segundos»: para armar el mensaje al usuario.
  String? get esperaLegible {
    final s = esperaSegundos;
    if (s == null || s <= 0) return null;
    if (s < 60) return '$s segundos';
    final minutos = (s / 60).ceil();
    return minutos == 1 ? '1 minuto' : '$minutos minutos';
  }
}

/// Cualquier otro codigo que el contrato no declara, incluido 5xx.
class ErrorDelServidor extends ExcepcionApi {
  const ErrorDelServidor(super.mensaje, {super.problema, this.status});

  final int? status;
}

/// El servidor respondio con exito pero el cuerpo no se pudo leer.
///
/// Se reporta aparte para no confundir «el servidor fallo» con «el servidor
/// contesto algo que no entendemos», que suele ser una desviacion del contrato.
class RespuestaInvalida extends ExcepcionApi {
  const RespuestaInvalida(super.mensaje, {this.causa});

  final Object? causa;
}
