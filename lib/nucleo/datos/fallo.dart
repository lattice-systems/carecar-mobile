import 'dart:async';
import 'dart:io';

import '../../api/excepciones.dart';
import '../../api/modelos/problema.dart';

/// Lo que puede salir mal en una llamada de datos · V2-T01.08.
///
/// No es una jerarquia nueva: es la sellada [ExcepcionApi] de `lib/api`, que ya
/// cubre los seis casos que pide la historia (sin conexion, sesion terminada,
/// no encontrado, conflicto con su codigo, validacion y servidor). Se renombra
/// aqui por el mismo motivo que `ApiCliente`: los modulos v2 hablan con el
/// nucleo y no con la v1, asi que cuando V2-T01.05 mueva el codigo, cambia
/// este archivo y ninguna pantalla.
///
/// **El [ExcepcionApi.mensaje] siempre se le puede mostrar al usuario.** Ya lo
/// garantiza `ClienteApi`, que aplica RIC-14 al construirlo: usa el `message`
/// del backend solo en 401, 403, 404, 409 y 429, y en 400 y 5xx pone un texto
/// propio. El nucleo no repite esa regla para no tener dos fuentes de verdad.
typedef Fallo = ExcepcionApi;

/// Texto para un error que no es del contrato: un bug nuestro, un paquete que
/// lanzo algo inesperado. Nunca se muestra el error original, que trae detalle
/// tecnico («Invalid argument», nombres de campos) escrito para quien programa.
const _mensajeInesperado = 'Ocurrió un error inesperado. Intenta de nuevo.';

/// Convierte **cualquier** cosa lanzada en un [Fallo].
///
/// Es la puerta del nucleo: lo que pasa por aqui llega tipado a la vista, asi
/// que ninguna pantalla tiene que preguntarse que es `Object error`.
///
/// Una [ExcepcionApi] pasa tal cual, sin envolverse: ya esta tipada y envolver
/// perderia su clase, que es justo con la que decide quien la recibe.
///
/// Las fallas de red que escapan sin tipar se reconocen aqui. `ClienteApi` ya
/// tipa las suyas; esto cubre a quien llame a otra cosa. Si aparece otra
/// excepcion de red que convenga reconocer (TLS, por ejemplo), se agrega con su
/// prueba.
Fallo falloDe(Object error) => switch (error) {
  final ExcepcionApi e => e,
  SocketException() || TimeoutException() => SinConexion(error),
  _ => ErrorDelServidor(_mensajeInesperado),
};

/// Las preguntas que una pantalla le hace a un [Fallo] para decidir que pintar.
///
/// Existen aqui para que no se respondan a mano en cada pantalla. Antes de esta
/// historia, cada una repetia
/// `error is SinConexion ? CausaError.sinConexion : CausaError.generico`.
extension CaraDelFallo on Fallo {
  /// No se pudo llegar al servidor. La vista lo distingue porque el usuario
  /// puede hacer algo distinto: revisar su conexion, no reintentar a ciegas.
  bool get esSinConexion => this is SinConexion;

  /// Hay que volver a entrar: 401 o 403.
  ///
  /// En una llamada con sesion significa que la sesion termino o que la cuenta
  /// se desactivo. En el login significa que las credenciales no pasaron. En
  /// los dos casos la salida es la misma pantalla, por eso es una sola
  /// pregunta.
  bool get sesionTerminada =>
      this is CredencialesInvalidas || this is CuentaDesactivada;

  /// Vale la pena ofrecer «Reintentar».
  ///
  /// Solo cuando repetir la misma peticion puede dar otro resultado: no hay
  /// red, o el servidor fallo y suele ser pasajero. En 400, 401, 403, 404 y 409
  /// la respuesta seria identica, y un boton que no arregla nada es peor que no
  /// tenerlo.
  ///
  /// El 429 queda fuera a proposito: si es reintentable, pero hasta que pase la
  /// espera que dice `Retry-After`. Esa es [DemasiadosIntentos.esperaLegible] y
  /// se resuelve con su propio texto, no con este boton.
  bool get esReintentable => this is SinConexion || this is ErrorDelServidor;

  /// El codigo propio del contrato, **nunca nulo** (RIC-15).
  ///
  /// Si el backend no lo mando, o el fallo no trae `Problema`, es
  /// [CodigoProblema.desconocido]. Asi quien decide puede hacer `switch` sobre
  /// el codigo sin comprobar nulos primero, que es la regla: decidir por el
  /// codigo cuando venga y por el `status` si no.
  CodigoProblema get codigo => problema?.codigo ?? CodigoProblema.desconocido;

  /// El codigo HTTP, si se conoce.
  ///
  /// Sale del `Problema` del contrato. Si el servidor no respondio con ese
  /// formato, se usa el que guardo [ErrorDelServidor]; y si tampoco, es nulo,
  /// que es el caso de [SinConexion]: nunca hubo respuesta.
  int? get status => switch (this) {
    final ErrorDelServidor e => e.problema?.status ?? e.status,
    _ => problema?.status,
  };
}
