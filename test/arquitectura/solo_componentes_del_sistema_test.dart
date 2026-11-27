import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V2-T02.18: los módulos v2 usan los controles del sistema de diseño
/// (`lib/nucleo/diseno/`), no los de Material ni los de la v1. Así todos los
/// botones y campos se ven, rebotan y suenan igual en el lector de pantalla.
///
/// Si falta un control, se agrega primero al sistema (AGENTS.md §8) o se usa un
/// provisional en `presentacion/provisional/` (que esta prueba no revisa).
const _prohibidos = {
  'IconButton': 'BotonCircular',
  'TextButton': 'BotonPildora (tonal) o BotonTexto del sistema',
  'ElevatedButton': 'BotonPildora',
  'FilledButton': 'BotonPildora',
  'OutlinedButton': 'BotonPildora (tonal)',
  'TextField': 'CampoTexto o CampoMensaje',
  'Card': 'SuperficieLiquida o GrupoLista',
  'ListTile': 'FilaLista o FilaGrupo',
  'Chip': 'ChipPista',
};

final _uso = RegExp(r'\b(' + _prohibidos.keys.join('|') + r')\(');
final _importacionV1 = RegExp(
  r'''import\s+['"][^'"]*(shadcn_ui|/widgets/[a-z_]+\.dart)['"]''',
);

void main() {
  test('lib/modulos/ solo usa controles del sistema de diseño', () {
    final violaciones = <String>[];
    final archivos = Directory('lib/modulos')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/provisional/'));
    for (final archivo in archivos) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        final linea = lineas[i];
        if (linea.trimLeft().startsWith('//')) continue;
        for (final m in _uso.allMatches(linea)) {
          violaciones.add(
            '${archivo.path}:${i + 1} usa ${m[1]} de Material -> '
            '${_prohibidos[m[1]]}',
          );
        }
        if (_importacionV1.hasMatch(linea) &&
            !linea.contains('/modulos/widgets/')) {
          violaciones.add(
            '${archivo.path}:${i + 1} importa la v1 -> usa lib/nucleo/diseno',
          );
        }
      }
    }
    expect(
      violaciones,
      isEmpty,
      reason:
          'Controles fuera del sistema de diseño (${violaciones.length}):\n'
          '${violaciones.join('\n')}\n'
          'Ver docs/diseno/sistema-de-diseno-v2.md y AGENTS.md §8.',
    );
  });

  test('lib/modulos/ no arma su propio encabezado: usa MarcoPantalla', () {
    // V2-T02.23: `MarcoPantalla` es la única implementación del marco de una
    // pantalla de detalle. Quien armaba `EncabezadoGrande` a mano olvidaba el
    // botón de regreso o de cierre (cinco pantallas quedaron sin salida
    // visible) o copiaba el marco con un cierre de otro color.
    final armadoAMano = RegExp(r'\bEncabezadoGrande\(');
    // La galería muestra los componentes tal cual; el ejemplo es de desarrollo.
    const exentos = ['modulos/galeria/', 'modulos/ejemplo/', '/provisional/'];
    final violaciones = <String>[];
    final archivos = Directory('lib/modulos')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !exentos.any(f.path.replaceAll(r'\', '/').contains));
    for (final archivo in archivos) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        if (lineas[i].trimLeft().startsWith('//')) continue;
        if (armadoAMano.hasMatch(lineas[i])) {
          violaciones.add(
            '${archivo.path}:${i + 1} arma EncabezadoGrande a mano -> '
            'MarcoPantalla (con conRegreso: true si es un detalle)',
          );
        }
      }
    }
    expect(
      violaciones,
      isEmpty,
      reason:
          'Encabezados armados a mano (${violaciones.length}):\n'
          '${violaciones.join('\n')}\n'
          'Ver docs/diseno/sistema-de-diseno-v2.md, «Encabezados y marcos».',
    );
  });
}
