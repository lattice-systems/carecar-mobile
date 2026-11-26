/// En qué tramo cae «hace cuánto» · V2-M01.09.
enum TramoDeAntiguedad {
  /// Menos de un minuto.
  ahora,
  minutos,
  horas,
  dias,

  /// De una semana en adelante: «hace 23 días» no le dice nada a nadie, la
  /// fecha sí.
  fecha,
}

/// Cuánto hace que pasó algo, en tramos · V2-M01.09.
///
/// Devuelve **un tramo y un número, nunca texto**: el idioma, el plural y el
/// formato de fecha los pone la pantalla, igual que hace `BloqueoPorIntentos`.
/// Así esta regla se prueba sin pintar nada y sirve igual en español y en
/// inglés.
class Antiguedad {
  const Antiguedad._(this.tramo, this.cantidad);

  /// El tramo de [cuando] visto desde [ahora].
  ///
  /// Normaliza los dos instantes a UTC antes de restarlos: el contrato manda
  /// UTC y el reloj de la pantalla es local, así que compararlos sin
  /// normalizar daría el desfase de la zona como antigüedad.
  ///
  /// Una fecha **en el futuro** cuenta como [TramoDeAntiguedad.ahora], y no es
  /// un caso raro: el reloj del celular puede ir atrasado respecto al del
  /// servidor, y «hace -3 minutos» se vería roto.
  factory Antiguedad.entre({
    required DateTime cuando,
    required DateTime ahora,
  }) {
    final transcurrido = ahora.toUtc().difference(cuando.toUtc());

    if (transcurrido.inMinutes < 1) {
      return const Antiguedad._(TramoDeAntiguedad.ahora, null);
    }
    if (transcurrido.inHours < 1) {
      // `inMinutes` trunca, que es lo que se quiere: a los 5 min 59 s «hace 5
      // minutos» sigue siendo cierto y decir 6 adelantaría el reloj.
      return Antiguedad._(TramoDeAntiguedad.minutos, transcurrido.inMinutes);
    }
    if (transcurrido.inDays < 1) {
      return Antiguedad._(TramoDeAntiguedad.horas, transcurrido.inHours);
    }
    if (transcurrido.inDays < 7) {
      return Antiguedad._(TramoDeAntiguedad.dias, transcurrido.inDays);
    }
    return const Antiguedad._(TramoDeAntiguedad.fecha, null);
  }

  final TramoDeAntiguedad tramo;

  /// Cuántos minutos, horas o días. Nulo en [TramoDeAntiguedad.ahora] y en
  /// [TramoDeAntiguedad.fecha], donde no hay número que decir.
  final int? cantidad;
}
