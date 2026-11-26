import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V2-T02.07: la app usa un solo set de íconos, Lucide de trazo 1.5
/// (`LucideIcons300`). Mezclar los de Material o Cupertino cambia el grosor y
/// el estilo de una pantalla a otra.
final _otroSet = RegExp(r'\b(Icons|CupertinoIcons|LucideIcons)\.');

void main() {
  test('lib/ solo usa los íconos de LucideIcons300', () {
    final violaciones = <String>[];
    final archivos = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final archivo in archivos) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        if (lineas[i].trimLeft().startsWith('//')) continue;
        if (_otroSet.hasMatch(lineas[i])) {
          violaciones.add('${archivo.path}:${i + 1} ${lineas[i].trim()}');
        }
      }
    }
    expect(violaciones, isEmpty, reason: violaciones.join('\n'));
  });
}
