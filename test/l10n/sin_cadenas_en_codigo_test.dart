import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de V2-M20.01: ninguna cadena visible en el codigo de la v2.
///
/// Busca textos escritos a mano en widgets (`Text('...')`) y en los argumentos
/// con los que los componentes reciben texto (`titulo: '...'`, `tooltip: '...'`).
/// Todo texto que ve o escucha una persona va en `lib/l10n/app_es.arb`.
///
/// Es una guarda, no un analizador: no entiende el codigo, solo busca esos dos
/// patrones. No ve una cadena dentro de un ternario (`a ? 'x' : 'y'`) ni de un
/// `??`. Sirve para que un archivo nuevo no vuelva a meter cadenas, no para
/// probar que no queda ninguna.
void main() {
  /// Archivos que todavia tienen cadenas escritas a mano y estan por migrar.
  /// Hoy esta vacia (V2-M20.01 fase 2). Un archivo nuevo no entra a esta lista.
  const pendientes = <String>{};

  /// Carpetas fuera de la regla, con su razon.
  const exentas = <String>[
    // Herramienta de desarrollo, no la ve ninguna persona usuaria.
    'lib/modulos/galeria/',
    // Modulo de ejemplo, se elimina en V2-T01.07.
    'lib/modulos/ejemplo/',
    // Codigo generado.
    'lib/l10n/',
  ];

  final porTexto = RegExp(r'''\bText\(\s*(const\s+)?['"]''');
  final porArgumento = RegExp(
    r'''\b(titulo|mensaje|texto|etiqueta|tooltip|label|hintText|sugerencia|'''
    r'''ayuda|error|descripcion|subtitulo|detalle|nota|textoAccion|'''
    r'''textoPrincipal|textoSecundario|textoReintentar|mensajeVacio|'''
    r'''descripcionFoto|mensajeConfirmacion):\s*(const\s+)?['"]''',
  );

  Set<String> conCadenas() {
    final encontrados = <String>{};
    final archivos = [
      for (final raiz in ['lib/modulos', 'lib/nucleo'])
        ...Directory(raiz)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
    ];
    for (final archivo in archivos) {
      final ruta = archivo.path.replaceAll(r'\', '/');
      if (exentas.any(ruta.contains)) continue;
      final lineas = archivo.readAsStringSync().split('\n');
      final codigo = lineas
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      if (porTexto.hasMatch(codigo) || porArgumento.hasMatch(codigo)) {
        encontrados.add(ruta);
      }
    }
    return encontrados;
  }

  test('ningun archivo nuevo trae cadenas escritas a mano', () {
    final nuevos = conCadenas().difference(pendientes);
    expect(
      nuevos,
      isEmpty,
      reason:
          'Estos archivos traen texto visible en el codigo. Pasalo a '
          'lib/l10n/app_es.arb y a app_en.arb y usa AppLocalizations:\n'
          '${nuevos.join('\n')}',
    );
  });

  test('la lista de pendientes solo se achica', () {
    final yaMigrados = pendientes.difference(conCadenas());
    expect(
      yaMigrados,
      isEmpty,
      reason:
          'Estos archivos ya no traen cadenas: quitalos de `pendientes`:\n'
          '${yaMigrados.join('\n')}',
    );
  });

  test('los archivos de idioma tienen las mismas claves', () {
    Set<String> claves(String ruta) {
      final texto = File(ruta).readAsStringSync();
      // Solo claves de primer nivel (2 espacios), sin las anidadas de `@clave`.
      return RegExp(
        r'^  "([A-Za-z0-9_]+)"\s*:',
        multiLine: true,
      ).allMatches(texto).map((m) => m.group(1)!).toSet();
    }

    final es = claves('lib/l10n/app_es.arb');
    final en = claves('lib/l10n/app_en.arb');
    expect(en.difference(es), isEmpty, reason: 'Claves solo en ingles');
    expect(es.difference(en), isEmpty, reason: 'Falta traducir al ingles');
  });
}
