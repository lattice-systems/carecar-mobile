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
  const SinConexion([this.causa])
    : super('No se pudo conectar con el servidor. Intenta de nuevo.');

  final Object? causa;
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
