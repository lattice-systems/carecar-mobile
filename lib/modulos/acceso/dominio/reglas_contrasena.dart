/// Reglas de la contrasena de la app · V2-M01.03.
///
/// Son **las que de verdad corre el backend**, copiadas de
/// `ReglasContrasena.java` de `agencia-360-backend`: de 8 a 72 caracteres, al
/// menos una letra y un numero. El 72 es el limite de BCrypt.
///
/// **No se pide mayuscula.** El criterio de la historia la mencionaba, pero no
/// aparece en la ficha v2.1, ni en el contrato v1 (1.5.0), ni en el v2 (2.1.0),
/// ni en el backend. Pedirla aqui rechazaria contrasenas que el servidor
/// acepta, y le ensenaria al cliente una regla que nadie hace cumplir.
/// Confirmado con el equipo; el criterio quedo corregido en
/// `plan/modulos/M01-acceso-y-perfil.md`.
class ReglasContrasena {
  const ReglasContrasena._();

  static const largoMinimo = 8;
  static const largoMaximo = 72;

  /// Una letra en **cualquier** idioma, como el `Character::isLetter` del
  /// backend. Con `[a-zA-Z]` la app rechazaria `mañana2026`, que el servidor
  /// acepta: el tipo de desajuste que no se nota hasta que un cliente se
  /// queda sin poder entrar.
  static final _letra = RegExp(r'\p{L}', unicode: true);

  /// Un digito decimal en cualquier alfabeto, como `Character::isDigit`.
  static final _numero = RegExp(r'\p{Nd}', unicode: true);

  /// Revisa [nueva] regla por regla.
  ///
  /// [actual] es la contrasena que se esta reemplazando, cuando se conoce. En
  /// la recuperacion por enlace (V2-M01.04) no se conoce, y entonces la regla
  /// de «distinta de la actual» no estorba.
  static RevisionContrasena revisar(String nueva, {String? actual}) =>
      RevisionContrasena(
        estaVacia: nueva.isEmpty,
        largoSuficiente:
            nueva.length >= largoMinimo && nueva.length <= largoMaximo,
        tieneLetra: _letra.hasMatch(nueva),
        tieneNumero: _numero.hasMatch(nueva),
        // Se compara tal cual: para el servidor `temporal123` y
        // `Temporal123` son contrasenas distintas.
        esDistintaDeLaActual: actual == null || nueva != actual,
      );
}

/// Que cumple y que falta de una contrasena.
///
/// Es **una respuesta por regla** y no un booleano suelto porque el criterio
/// pide mostrarlas «en vivo»: la pantalla las va marcando mientras la persona
/// escribe, y con un solo «no cumple» no sabria cual senalar.
class RevisionContrasena {
  const RevisionContrasena({
    required this.estaVacia,
    required this.largoSuficiente,
    required this.tieneLetra,
    required this.tieneNumero,
    required this.esDistintaDeLaActual,
  });

  /// Nadie ha escrito nada todavia.
  ///
  /// Se distingue de «mal» a proposito: al abrir la pantalla no se le reclaman
  /// tres reglas incumplidas a quien acaba de llegar.
  final bool estaVacia;

  /// De [ReglasContrasena.largoMinimo] a [ReglasContrasena.largoMaximo].
  final bool largoSuficiente;

  final bool tieneLetra;
  final bool tieneNumero;

  /// `true` tambien cuando no se conoce la contrasena anterior.
  final bool esDistintaDeLaActual;

  /// Se puede mandar al servidor.
  bool get cumpleTodo =>
      largoSuficiente && tieneLetra && tieneNumero && esDistintaDeLaActual;
}
