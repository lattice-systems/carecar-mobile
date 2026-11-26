import 'dart:io';
import 'dart:typed_data';

import 'package:carecar_mobile/nucleo/diseno/tokens/tipografia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Lee `usWeightClass` de la tabla `OS/2` de un TTF.
int _pesoDelArchivo(File archivo) {
  final datos = ByteData.sublistView(archivo.readAsBytesSync());
  final tablas = datos.getUint16(4);
  for (var i = 0; i < tablas; i++) {
    final registro = 12 + 16 * i;
    final nombre = String.fromCharCodes(
      Uint8List.sublistView(datos, registro, registro + 4),
    );
    if (nombre == 'OS/2') {
      return datos.getUint16(datos.getUint32(registro + 8) + 4);
    }
  }
  throw StateError('${archivo.path} no tiene tabla OS/2');
}

void main() {
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;

  /// Pesos declarados de una familia, con el archivo de cada uno.
  Map<int, String> declarados(String familia) {
    final fuentes = (pubspec['flutter'] as YamlMap)['fonts'] as YamlList;
    final entradas = fuentes.cast<YamlMap>().where(
      (f) => f['family'] == familia,
    );
    expect(entradas, hasLength(1), reason: 'familia $familia en pubspec.yaml');
    return {
      for (final f in (entradas.single['fonts'] as YamlList).cast<YamlMap>())
        (f['weight'] as int?) ?? 400: f['asset'] as String,
    };
  }

  test('cada familia declara solo los pesos que la escala usa', () {
    final usados = <String, Set<int>>{};
    for (final estilo in Tipografia.crear().todos) {
      usados
          .putIfAbsent(estilo.fontFamily!, () => {})
          .add(estilo.fontWeight!.value);
    }

    expect(usados.keys, {Tipografia.familiaTexto, Tipografia.familiaCifras});
    for (final MapEntry(key: familia, value: pesos) in usados.entries) {
      expect(declarados(familia).keys.toSet(), pesos, reason: familia);
    }
  });

  test('cada archivo declarado existe y trae el peso que dice', () {
    for (final familia in [Tipografia.familiaTexto, Tipografia.familiaCifras]) {
      for (final MapEntry(key: peso, value: ruta) in declarados(
        familia,
      ).entries) {
        expect(ruta, startsWith('assets/fonts/'));
        expect(File(ruta).existsSync(), isTrue, reason: ruta);
        expect(_pesoDelArchivo(File(ruta)), peso, reason: ruta);
      }
    }
  });

  test('la licencia OFL de Geist viaja junto a las fuentes', () {
    final licencia = File('assets/fonts/Geist-OFL.txt');

    expect(licencia.existsSync(), isTrue);
    expect(
      licencia.readAsStringSync(),
      allOf(
        contains('The Geist Project Authors'),
        contains('SIL OPEN FONT LICENSE Version 1.1'),
      ),
    );
  });

  test('las fuentes no se descargan en tiempo de ejecución', () {
    // `pubspec.lock` cubre también las dependencias transitivas.
    expect(
      File('pubspec.lock').readAsStringSync(),
      isNot(contains('google_fonts')),
    );

    final prohibido = RegExp(
      r'google_fonts|fonts\.googleapis\.com|fonts\.gstatic\.com',
    );
    final conDescarga = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => prohibido.hasMatch(f.readAsStringSync()))
        .map((f) => f.path);
    expect(conDescarga, isEmpty);
  });
}
