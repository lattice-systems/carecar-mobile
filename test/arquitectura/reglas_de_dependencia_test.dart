import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'verificador_dependencias.dart';

/// V2-T01.06: recorre `lib/` y falla si se rompe una regla de dependencia.
/// Reglas y como leer el error: `plan/arquitectura-v2.md` y
/// `lib/modulos/README.md`.
void main() {
  test('el arbol real de lib/ respeta las reglas de dependencia', () {
    final violaciones = verificarArbol(Directory('lib'));
    expect(
      violaciones,
      isEmpty,
      reason:
          'Reglas de dependencia rotas (${violaciones.length}):\n'
          '${violaciones.join('\n')}\n'
          'Detalle de cada regla: plan/arquitectura-v2.md',
    );
  });
}
