import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V2-T03.05: los criterios y los enlaces de la matriz coinciden', () {
    final fila = RegExp(
      r'^\| `(V2-M\d{2}\.\d{2}: [^`\r\n]+)` \| \[[^\]]+\]\(\.\./([^\s)]+_test\.dart)\) \|\r?$',
      multiLine: true,
    );
    final titulo = RegExp(r'''\(\s*['"](V2-M\d{2}\.\d{2}: [^\r\n]+?)['"],''');
    final matriz = File('plan/cumplimiento-ficha.md').readAsStringSync();
    final enlazados = fila
        .allMatches(matriz)
        .map((m) => (m[1]!, m[2]!))
        .toList();

    final pruebas = <(String, String)>[];
    for (final carpeta in ['test', 'integration_test']) {
      for (final archivo in Directory(
        carpeta,
      ).listSync(recursive: true, followLinks: false).whereType<File>()) {
        final ruta = archivo.path.replaceAll('\\', '/');
        if (!ruta.endsWith('_test.dart')) continue;
        final contenido = archivo.readAsStringSync();
        pruebas.addAll(titulo.allMatches(contenido).map((m) => (m[1]!, ruta)));
      }
    }

    expect(pruebas, isNotEmpty);
    expect(enlazados, unorderedEquals(pruebas));
  });
}
