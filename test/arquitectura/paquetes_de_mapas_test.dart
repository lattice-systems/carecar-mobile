import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Decisión 0006 (V2-T02.09): los paquetes de mapas, ubicación y
/// geocodificación se quedan detrás de `lib/nucleo/mapas/` y del componente
/// `Mapa`. Así cambiar de proveedor es cambiar una implementación.
const _permitidos = <String, Set<String>>{
  'lib/nucleo/diseno/componentes/mapa.dart': {'flutter_map', 'latlong2'},
  'lib/nucleo/mapas/ubicacion_geolocator.dart': {'geolocator'},
  'lib/nucleo/mapas/geocodificador_nativo.dart': {'geocoding'},
  // Solo abre los ajustes de la app cuando se niega la cámara (V2-M24.05); no
  // lee la ubicación.
  'lib/nucleo/camara/selector_foto.dart': {'geolocator'},
  // Provisional anterior al componente: lo retira el dueño de M17 en su
  // siguiente cambio a esas pantallas (plan/trabajo-en-paralelo.md, sección
  // 4). Al borrar el archivo se borra esta línea.
  'lib/modulos/recoleccion/presentacion/provisional/mapa_provisional.dart': {
    'flutter_map',
    'latlong2',
  },
};

final _importacion = RegExp(
  r'''^\s*(?:import|export)\s+['"]package:(flutter_map|latlong2|geolocator|geocoding)[a-z_]*/''',
  multiLine: true,
);

void main() {
  test('solo el núcleo de mapas y el componente tocan esos paquetes', () {
    final violaciones = <String>[];
    final archivos = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final archivo in archivos) {
      final ruta = archivo.path.replaceAll(r'\', '/');
      for (final m in _importacion.allMatches(archivo.readAsStringSync())) {
        if (!(_permitidos[ruta]?.contains(m[1]) ?? false)) {
          violaciones.add('$ruta importa ${m[1]}');
        }
      }
    }

    expect(
      violaciones,
      isEmpty,
      reason:
          '${violaciones.join('\n')}\n'
          'Usa lib/nucleo/mapas/mapas.dart y el componente Mapa.',
    );
  });
}
