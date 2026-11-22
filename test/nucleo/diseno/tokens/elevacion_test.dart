import 'dart:ui';

import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/elevacion.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('en claro la elevacion es una sombra suave de dos capas', () {
    final sombras = Elevacion.sombras(Brightness.light);
    expect(sombras, hasLength(2));
    expect(sombras[0].offset, const Offset(0, 1));
    expect(sombras[0].blurRadius, 2);
    expect(sombras[1].offset, const Offset(0, 8));
    expect(sombras[1].blurRadius, 24);
    for (final sombra in sombras) {
      expect(sombra.color.a, closeTo(0.06, 0.01));
    }
  });

  test('en oscuro no hay sombra', () {
    expect(Elevacion.sombras(Brightness.dark), isEmpty);
  });

  test('en claro la superficie no cambia al subir de nivel', () {
    final p = PaletaColores.claro;
    expect(Elevacion.superficie(p, Brightness.light, nivel: 0), p.superficie);
    expect(Elevacion.superficie(p, Brightness.light, nivel: 1), p.superficieElevada);
  });

  test('en oscuro subir de nivel aclara la superficie', () {
    final p = PaletaColores.oscuro;
    expect(Elevacion.superficie(p, Brightness.dark, nivel: 0), p.superficie);
    expect(Elevacion.superficie(p, Brightness.dark, nivel: 1), p.superficieElevada);
  });
}
