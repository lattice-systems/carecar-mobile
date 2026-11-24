/// El servidor bloqueo el login por demasiados intentos · V2-M01.01.
///
/// Son cinco intentos fallidos seguidos con el mismo correo y 15 minutos de
/// espera (RIC-5). Llega como un **429** con `codigo: DEMASIADOS_INTENTOS` y el
/// encabezado `Retry-After` en segundos.
///
/// Existe para que la pantalla pueda decir **cuanto falta**, no cuanto duraba
/// el bloqueo cuando empezo. La v1 armaba el texto en el momento del fallo
/// («Espera 15 minutos») y se quedaba viejo: a los diez minutos seguia
/// diciendo quince.
///
/// **No arma textos.** Entrega numeros y un booleano, y la presentacion elige
/// la clave del ARB. Es la regla de `lib/modulos/README.md`: el dominio nunca
/// escribe lo que lee una persona, porque el orden de las palabras cambia
/// entre idiomas.
class BloqueoPorIntentos {
  const BloqueoPorIntentos({required this.termina});

  /// Arma el bloqueo a partir del `Retry-After` del 429.
  ///
  /// Devuelve `null` cuando no hay nada que contar: el encabezado es
  /// **opcional** en el contrato, y sin el —o con una espera de cero o
  /// negativa— no se puede hacer cuenta regresiva. En ese caso la pantalla
  /// muestra el aviso generico de demasiados intentos, sin reloj.
  static BloqueoPorIntentos? desde({
    required DateTime ahora,
    required Duration? espera,
  }) {
    if (espera == null || espera <= Duration.zero) return null;
    return BloqueoPorIntentos(termina: ahora.add(espera));
  }

  /// Cuando se puede volver a intentar.
  final DateTime termina;

  /// Cuanto falta, nunca negativo.
  ///
  /// Se recorta en cero para que la pantalla no tenga que comprobarlo: un
  /// bloqueo vencido simplemente no le queda tiempo.
  Duration restante(DateTime ahora) {
    final falta = termina.difference(ahora);
    return falta.isNegative ? Duration.zero : falta;
  }

  /// `true` cuando ya se puede volver a intentar.
  bool yaTermino(DateTime ahora) => restante(ahora) == Duration.zero;

  /// Los minutos que faltan, **redondeados hacia arriba**.
  ///
  /// Hacia arriba a proposito: con un segundo restante faltan «1 minuto» y no
  /// «0 minutos», que mientras el bloqueo sigue vigente seria mentira. Al
  /// vencer, es cero.
  int minutosRestantes(DateTime ahora) {
    final segundos = restante(ahora).inSeconds;
    return (segundos / Duration.secondsPerMinute).ceil();
  }

  /// Los segundos que faltan, para el ultimo minuto.
  int segundosRestantes(DateTime ahora) => restante(ahora).inSeconds;

  /// Si conviene decirlo en minutos o en segundos.
  ///
  /// Arriba de un minuto, en minutos. Abajo, en segundos: un «Espera 1 minuto»
  /// congelado durante 59 segundos se siente roto, y los segundos bajando
  /// dejan ver que algo avanza.
  bool seMuestraEnMinutos(DateTime ahora) =>
      restante(ahora) >= const Duration(minutes: 1);
}
