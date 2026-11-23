import 'dart:io';

/// Verificador de reglas de dependencia (V2-T01.06). Dart puro: lee fuentes,
/// no compila nada. Reglas en `plan/arquitectura-v2.md`.
enum ReglaDeDependencia {
  /// R1: de otro modulo solo se importa `modulos/<b>/<b>.dart`.
  internosDeOtroModulo('R1'),

  /// R2: `lib/nucleo` no conoce los modulos (salvo el registro de rutas).
  nucleoConoceModulos('R2'),

  /// R3: el codigo v2 no importa codigo v1 de interfaz.
  v2ConoceV1('R3');

  const ReglaDeDependencia(this.codigo);
  final String codigo;
}

class ViolacionDeDependencia {
  const ViolacionDeDependencia({
    required this.archivo,
    required this.linea,
    required this.importacion,
    required this.regla,
    required this.mensaje,
  });

  final String archivo;
  final int linea;
  final String importacion;
  final ReglaDeDependencia regla;
  final String mensaje;

  @override
  String toString() =>
      '$archivo:$linea importa "$importacion" -> ${regla.codigo}: $mensaje';
}

/// UNICO archivo de `nucleo/` autorizado a importar modulos, y solo su
/// contrato publico. Es la excepcion explicita de la regla R2.
const registroDeRutas = 'lib/nucleo/navegacion/registro_de_rutas.dart';

/// Carpetas de la v1 que el codigo v2 no puede importar. `lib/api` y
/// `lib/sesion` quedan fuera a proposito: `nucleo/api` y `nucleo/sesion` las
/// envuelven hasta V2-T01.05.
const _carpetasV1 = {'pantallas', 'widgets', 'tema'};

/// Excepciones explicitas de R3: archivos de v2 que montan pantallas v1 como
/// rutas mientras dura la migracion (V2-T01.03). Cada una se quita cuando su
/// pantalla se migra (V2-T01.05) y la lista queda vacia al retirar v1
/// (V2-T01.07). Agregar un archivo aqui exige avisar al dueno de T01.
const excepcionesV1 = {
  'lib/nucleo/navegacion/rutas_del_nucleo.dart':
      'monta las pantallas v1 de acceso, inicio y cambio de contrasena',
};

const _paquete = 'carecar_mobile';

/// Revisa un archivo. [archivo] es su ruta desde la raiz del repo con `/`
/// (p. ej. `lib/modulos/citas/citas.dart`); [fuente] su contenido.
List<ViolacionDeDependencia> verificarFuente(String archivo, String fuente) {
  final origen = archivo.replaceAll('\\', '/');
  final violaciones = <ViolacionDeDependencia>[];
  for (final d in _directivas(fuente)) {
    final destino = _resolver(origen, d.uri);
    if (destino == null) continue;
    final v = _revisar(origen, d, destino);
    if (v != null) violaciones.add(v);
  }
  return violaciones;
}

/// Revisa todos los `.dart` bajo [lib] (la carpeta `lib/` del repo).
List<ViolacionDeDependencia> verificarArbol(Directory lib) {
  final archivos =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final f in archivos)
      ...verificarFuente(_desdeLib(f.path, lib.path), f.readAsStringSync()),
  ];
}

String _desdeLib(String ruta, String raizLib) {
  final r = ruta.replaceAll('\\', '/');
  final base = raizLib.replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '');
  return 'lib${r.substring(base.length)}';
}

class _Directiva {
  _Directiva(this.uri, this.linea);
  final String uri;
  final int linea;
}

final _sentencia = RegExp(
  r'^[ \t]*(?:import|export|part)\b[^;]*;',
  multiLine: true,
);
final _primeraUri = RegExp(r'''^\s*\w+\s+(['"])(.*?)\1''');
final _uriCondicional = RegExp(r'''\)\s*(['"])(.*?)\1''');

Iterable<_Directiva> _directivas(String fuente) sync* {
  for (final m in _sentencia.allMatches(fuente)) {
    final texto = m.group(0)!;
    final linea = '\n'.allMatches(fuente.substring(0, m.start)).length + 1;
    final primera = _primeraUri.firstMatch(texto);
    if (primera == null) continue; // `part of x;` y similares
    yield _Directiva(primera.group(2)!, linea);
    for (final c in _uriCondicional.allMatches(texto)) {
      yield _Directiva(c.group(2)!, linea);
    }
  }
}

/// Devuelve la ruta destino `lib/...` o `null` si no es codigo de este repo.
String? _resolver(String origen, String uri) {
  if (uri.startsWith('dart:')) return null;
  if (uri.startsWith('package:')) {
    final prefijo = 'package:$_paquete/';
    return uri.startsWith(prefijo)
        ? 'lib/${uri.substring(prefijo.length)}'
        : null;
  }
  final partes = origen.split('/')..removeLast();
  for (final p in uri.split('/')) {
    if (p == '..') {
      if (partes.isNotEmpty) partes.removeLast();
    } else if (p != '.' && p.isNotEmpty) {
      partes.add(p);
    }
  }
  return partes.join('/');
}

/// `modulos/<m>/...` -> `<m>`; `null` si la ruta no es de un modulo.
String? _moduloDe(String ruta) {
  final p = ruta.split('/');
  return p.length >= 4 && p[0] == 'lib' && p[1] == 'modulos' ? p[2] : null;
}

ViolacionDeDependencia? _revisar(String origen, _Directiva d, String destino) {
  ViolacionDeDependencia violacion(ReglaDeDependencia r, String mensaje) =>
      ViolacionDeDependencia(
        archivo: origen,
        linea: d.linea,
        importacion: d.uri,
        regla: r,
        mensaje: mensaje,
      );

  final partesOrigen = origen.split('/');
  final carpetaOrigen = partesOrigen.length > 1 ? partesOrigen[1] : '';
  final modOrigen = _moduloDe(origen);
  final modDestino = _moduloDe(destino);

  // R1: de un modulo ajeno solo el contrato publico.
  if (modDestino != null && modDestino != modOrigen) {
    final esContrato = destino == 'lib/modulos/$modDestino/$modDestino.dart';
    if (carpetaOrigen == 'nucleo' && origen != registroDeRutas) {
      return violacion(
        ReglaDeDependencia.nucleoConoceModulos,
        'lib/nucleo no conoce los modulos; solo $registroDeRutas puede '
        'importar lib/modulos/<modulo>/<modulo>.dart.',
      );
    }
    if (!esContrato) {
      return violacion(
        ReglaDeDependencia.internosDeOtroModulo,
        'es interno del modulo "$modDestino"; importa su contrato publico '
        'modulos/$modDestino/$modDestino.dart o comunicate por rutas.',
      );
    }
  }

  // R3: v2 (modulos y nucleo) no importa interfaz v1.
  if ((carpetaOrigen == 'modulos' || carpetaOrigen == 'nucleo') &&
      !excepcionesV1.containsKey(origen)) {
    final p = destino.split('/');
    if (p.length > 2 && p[0] == 'lib' && _carpetasV1.contains(p[1])) {
      return violacion(
        ReglaDeDependencia.v2ConoceV1,
        'lib/${p[1]} es codigo v1 (se retira en V2-T01.07); usa lib/nucleo '
        'o el sistema de diseno v2.',
      );
    }
  }
  return null;
}
