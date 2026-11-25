import 'dart:io';

/// Verificador de V2-M22.07. Dart puro: lee fuentes, no compila nada.
///
/// Dos reglas sobre `lib/`:
/// 1. Nada escribe en la consola sin pasar por `Registro` (`print`,
///    `debugPrint`, `developer.log`, `stdout`/`stderr`).
/// 2. A `Registro.depurar` no se le interpola un correo, telefono, VIN, token
///    ni contrasena.
///
/// Es una guarda, no un analizador: mira el texto, no entiende el codigo. Lo
/// que no tiene un nombre reconocible lo tapa `quitarDatosPersonales` al
/// escribir.
class HallazgoDeRegistro {
  const HallazgoDeRegistro({
    required this.archivo,
    required this.linea,
    required this.mensaje,
  });

  final String archivo;
  final int linea;
  final String mensaje;

  @override
  String toString() => '$archivo:$linea $mensaje';
}

/// Unica carpeta que puede escribir en la consola.
const carpetaDelRegistro = 'lib/nucleo/registro/';

/// Palabras que, dentro del nombre de lo que se interpola, delatan un dato
/// personal. Se comparan por palabra: `vinculo` no es `vin`.
const _palabrasPersonales = {
  'correo',
  'email',
  'mail',
  'telefono',
  'celular',
  'movil',
  'vin',
  'token',
  'jwt',
  'contrasena',
  'password',
  'passwd',
  'clave',
  'secret',
  'secreto',
  'cookie',
  'authorization',
  'bearer',
};

final _escrituraDirecta = RegExp(
  r'(?<![\w.])(?:debugPrint|print|debugPrintStack)\s*\('
  r'|\bdeveloper\.log\s*\('
  r'|\b(?:stdout|stderr)\.(?:write|writeln|add)\s*\(',
);
final _logSuelto = RegExp(r'(?<![\w.])log\s*\(');
final _llamadaDeRegistro = RegExp(r'Registro\.depurar\s*\(');
final _interpolacion = RegExp(r'\$\{([^}]*)\}|\$([A-Za-z_][\w.]*)');

List<HallazgoDeRegistro> revisarCodigoDeRegistro(String ruta, String codigo) {
  final archivo = ruta.replaceAll(r'\', '/');
  if (archivo.startsWith(carpetaDelRegistro) ||
      archivo.startsWith('lib/l10n/')) {
    return const [];
  }
  // Las lineas de comentario se vacian, sin quitarlas, para no mover los
  // numeros de linea.
  final lineas = [
    for (final l in codigo.split('\n')) l.trimLeft().startsWith('//') ? '' : l,
  ];
  final limpio = lineas.join('\n');
  final hallazgos = <HallazgoDeRegistro>[];

  void anotar(int desplazamiento, String mensaje) => hallazgos.add(
    HallazgoDeRegistro(
      archivo: archivo,
      linea: _lineaDe(limpio, desplazamiento),
      mensaje: mensaje,
    ),
  );

  for (final m in _escrituraDirecta.allMatches(limpio)) {
    anotar(
      m.start,
      'escribe en la consola sin pasar por Registro: usa Registro.depurar',
    );
  }
  if (limpio.contains("import 'dart:developer'")) {
    for (final m in _logSuelto.allMatches(limpio)) {
      anotar(
        m.start,
        'log() de dart:developer escribe sin pasar por Registro: '
        'usa Registro.depurar',
      );
    }
  }
  for (final llamada in _llamadaDeRegistro.allMatches(limpio)) {
    final argumentos = _argumentos(limpio, llamada.end);
    for (final i in _interpolacion.allMatches(argumentos)) {
      final nombre = i.group(1) ?? i.group(2) ?? '';
      final palabra = _palabraPersonal(nombre);
      if (palabra != null) {
        anotar(
          llamada.start,
          'registra "$nombre" (un dato de tipo "$palabra"): '
          'no incluyas correo, telefono, VIN ni token',
        );
        break;
      }
    }
  }
  hallazgos.sort((a, b) => a.linea.compareTo(b.linea));
  return hallazgos;
}

List<HallazgoDeRegistro> revisarArbolDeRegistro(Directory lib) {
  final archivos =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final f in archivos)
      ...revisarCodigoDeRegistro(f.path, f.readAsStringSync()),
  ];
}

/// Texto de los argumentos de una llamada, desde el parentesis ya abierto
/// hasta el que lo cierra.
String _argumentos(String codigo, int desde) {
  var profundidad = 1;
  var i = desde;
  while (i < codigo.length && profundidad > 0) {
    final c = codigo[i];
    if (c == '(') profundidad++;
    if (c == ')') profundidad--;
    i++;
  }
  return codigo.substring(desde, i);
}

/// Primera palabra personal en el nombre de lo que se interpola
/// (`usuario.correo`, `nuevaContrasena`, `access_token`), o `null`.
String? _palabraPersonal(String expresion) {
  final palabras = expresion
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .map((p) => p.toLowerCase());
  for (final p in palabras) {
    if (_palabrasPersonales.contains(p)) return p;
  }
  return null;
}

int _lineaDe(String codigo, int desplazamiento) =>
    '\n'.allMatches(codigo.substring(0, desplazamiento)).length + 1;
