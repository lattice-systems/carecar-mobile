import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// La API de la app rechaza con 400 una página de más de 50 elementos
/// («El tamaño de la página debe estar entre 1 y 50»). La API simulada no lo
/// exigía y la bitácora y «agregar a mi cita» fallaban solo en producción.
void main() {
  test('ningún código pide páginas de más de 50 elementos', () {
    final patron = RegExp(
      r'(tamano\s*:\s*|_?tamanoPagina\w*\s*=\s*|=>\s*)(\d{3,})\b',
    );
    final pedidos = RegExp(r'tamano\s*:\s*(\d+)|_?tamanoPagina\w*\s*=\s*(\d+)');
    final excesos = <String>[];
    for (final archivo
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  // `tamano:` también es el tamaño de un widget: solo se miran
                  // los que hablan con la API.
                  !f.path.startsWith('lib/widgets') &&
                  !f.path.startsWith('lib/pantallas') &&
                  !f.path.contains('/diseno/') &&
                  !f.path.contains('/galeria/'),
            )) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        for (final m in pedidos.allMatches(lineas[i])) {
          final n = int.parse(m.group(1) ?? m.group(2)!);
          if (n > 50) excesos.add('${archivo.path}:${i + 1} pide $n');
        }
      }
    }
    expect(patron.hasMatch('tamano: 100'), isTrue); // el detector funciona
    expect(excesos, isEmpty, reason: excesos.join('\n'));
  });
}
