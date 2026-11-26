import 'package:carecar_mobile/nucleo/diseno/componentes/avatar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/chip_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('ChipPista', () {
    testWidgets('al tocar pide el valor contrario', (tester) async {
      bool? recibido;
      await tester.pumpWidget(
        conTemaPista(
          ChipPista(
            texto: 'Servicio',
            seleccionado: false,
            alCambiar: (v) => recibido = v,
          ),
        ),
      );
      await tester.tap(find.byType(ChipPista));
      expect(recibido, isTrue);
    });

    testWidgets('seleccionado pide false y muestra la palomita', (
      tester,
    ) async {
      bool? recibido;
      await tester.pumpWidget(
        conTemaPista(
          ChipPista(
            texto: 'Servicio',
            seleccionado: true,
            alCambiar: (v) => recibido = v,
          ),
        ),
      );
      expect(find.byIcon(LucideIcons300.check), findsOneWidget);
      await tester.tap(find.byType(ChipPista));
      expect(recibido, isFalse);
    });

    testWidgets('sin alCambiar no responde', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const ChipPista(
            texto: 'Servicio',
            seleccionado: false,
            alCambiar: null,
          ),
        ),
      );
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('deja una zona tactil de 48 en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            ChipPista(
              texto: 'Servicio',
              seleccionado: false,
              alCambiar: (_) {},
            ),
            escenario: escenario,
          ),
        );
        expect(
          tester.getSize(find.byType(ChipPista)).height,
          greaterThanOrEqualTo(48),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('avisa seleccionado al lector de pantalla', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(
          ChipPista(texto: 'Servicio', seleccionado: true, alCambiar: (_) {}),
        ),
      );
      expect(
        tester.getSemantics(find.byType(ChipPista)),
        matchesSemantics(
          label: 'Servicio',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantica.dispose();
    });
  });

  group('Avatar', () {
    test('iniciales toma la primera letra de las dos primeras palabras', () {
      expect(Avatar.iniciales('ana lopez ruiz'), 'AL');
      expect(Avatar.iniciales('  Cristian  '), 'C');
      expect(Avatar.iniciales(''), '');
    });

    testWidgets('sin imagen muestra las iniciales', (tester) async {
      await tester.pumpWidget(conTemaPista(const Avatar(nombre: 'Ana Lopez')));
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('el lector de pantalla dice el nombre completo', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(conTemaPista(const Avatar(nombre: 'Ana Lopez')));
      expect(find.bySemanticsLabel('Ana Lopez'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('mide lo que dice cada tamano', (tester) async {
      final esperado = {
        TamanoAvatar.chico: 32.0,
        TamanoAvatar.normal: 40.0,
        TamanoAvatar.grande: 64.0,
      };
      for (final e in esperado.entries) {
        await tester.pumpWidget(
          conTemaPista(
            Align(
              child: Avatar(nombre: 'Ana Lopez', tamano: e.key),
            ),
          ),
        );
        expect(tester.getSize(find.byType(Avatar)), Size.square(e.value));
      }
    });

    testWidgets('si la imagen falla cae a las iniciales', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Avatar(nombre: 'Ana Lopez', imagen: _ImagenQueFalla()),
        ),
      );
      await tester.pump();
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('no desborda en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(const Avatar(nombre: 'Ana Lopez'), escenario: escenario),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}

class _ImagenQueFalla extends ImageProvider<_ImagenQueFalla> {
  const _ImagenQueFalla();

  @override
  Future<_ImagenQueFalla> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _ImagenQueFalla key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(Exception('sin imagen')),
    );
  }
}
