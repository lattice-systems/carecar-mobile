/// Quita de un texto lo que identifica a una persona o abre su cuenta:
/// correo, telefono, VIN y tokens (V2-M22.07).
///
/// Es la ultima barrera antes de escribir en el registro: no sabe de que
/// pantalla viene el texto, solo busca la forma de cada dato. Prefiere tapar
/// de mas (un numero largo que no era un telefono) a dejar pasar un dato.
String quitarDatosPersonales(String texto) {
  var limpio = texto;
  for (final (patron, reemplazo) in _reglas) {
    limpio = limpio.replaceAllMapped(patron, (m) => reemplazo(m));
  }
  return limpio;
}

// El orden importa: primero lo que tiene forma propia y puede contener
// numeros (tokens), despues correo y VIN, y al final los telefonos, que son
// la regla mas amplia.
final List<(RegExp, String Function(Match))> _reglas = [
  // JWT: tres partes en base64url, la primera empieza con «eyJ» ({"...).
  (
    RegExp(r'\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*'),
    (_) => '[token]',
  ),
  // Lo que sigue a «Bearer».
  (
    RegExp(r'(Bearer\s+)[A-Za-z0-9._~+/=-]+', caseSensitive: false),
    (m) => '${m[1]}[token]',
  ),
  // El valor de un campo token, llave o contrasena: `token=abc`,
  // `"refresh_token":"abc"`, `contrasena: abc`.
  (
    RegExp(
      r'''\b(token|access_token|refresh_token|id_token|api[_-]?key|contrasena|'''
      r'''password|passwd|clave|secret|secreto)\b(["']?\s*[:=]\s*["']?)'''
      r'''([^\s"'&,;}]+)''',
      caseSensitive: false,
    ),
    (m) => '${m[1]}${m[2]}[token]',
  ),
  // Correo.
  (
    RegExp(
      r'[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}',
    ),
    (_) => '[correo]',
  ),
  // VIN: 17 caracteres sin I, O ni Q, con al menos una letra y un digito
  // (una palabra larga sin digitos no es un VIN).
  (
    RegExp(
      r'(?<![A-Za-z0-9])(?=[A-HJ-NPR-Z0-9]*\d)(?=[A-HJ-NPR-Z0-9]*[A-HJ-NPR-Z])'
      r'[A-HJ-NPR-Z0-9]{17}(?![A-Za-z0-9])',
      caseSensitive: false,
    ),
    (_) => '[vin]',
  ),
  // Telefono: de 10 a 15 digitos, con espacios, puntos, guiones o parentesis
  // entre ellos y un + opcional al inicio.
  (
    RegExp(r'(?<!\d)\(?\+?\d(?:[\s().-]{0,2}\d){9,14}(?!\d)'),
    (_) => '[telefono]',
  ),
];
