import 'dart:io';

import 'package:carecar_mobile/nucleo/diseno/componentes/pestanas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

void main() {
  group('Reducir movimiento (V2-M20.04)', () {
    test('los componentes no traen duraciones ni curvas propias', () {
      final archivos = Directory('lib/nucleo/diseno/componentes')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final prohibidos = [
        RegExp(r'Duration\('),
        RegExp(r'Curves\.'),
        RegExp(r'Cubic\('),
      ];
      final infracciones = <String>[];
      for (final archivo in archivos) {
        final lineas = archivo.readAsLinesSync();
        for (var i = 0; i < lineas.length; i++) {
          if (lineas[i].trimLeft().startsWith('//')) continue;
          for (final p in prohibidos) {
            if (p.hasMatch(lineas[i])) {
              infracciones.add('${archivo.path}:${i + 1}');
            }
          }
        }
      }
      expect(
        infracciones,
        isEmpty,
        reason: 'Usa context.movimiento(token) en vez de valores sueltos.',
      );
    });

    Duration duracionDePestana(WidgetTester tester) {
      return tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
          .duration;
    }

    Widget pestanas() =>
        Pestanas(etiquetas: const ['A', 'B'], indice: 0, alCambiar: (_) {});

    testWidgets('sin la preferencia usa la duracion del token', (tester) async {
      await tester.pumpWidget(conTemaPista(pestanas()));
      expect(duracionDePestana(tester), const Duration(milliseconds: 220));
    });

    testWidgets('con la preferencia pasa a fundido corto', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: pestanas(),
          ),
        ),
      );
      expect(duracionDePestana(tester), const Duration(milliseconds: 120));
      expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
            .curve,
        Curves.linear,
      );
    });
  });
}
