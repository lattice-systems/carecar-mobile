import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/hoja_inferior.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/menu.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/pestanas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('Dialogo', () {
    testWidgets('muestra titulo, mensaje y acciones en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Dialogo(
              titulo: 'Cancelar cita',
              mensaje: 'No se puede deshacer.',
              textoPrincipal: 'Cancelar cita',
              alPrincipal: () {},
              textoSecundario: 'Volver',
              alSecundario: () {},
              peligro: true,
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('No se puede deshacer.'), findsOneWidget);
        expect(find.text('Volver'), findsOneWidget);
        expect(find.text('Cancelar cita'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('mostrarDialogo entrega el valor al cerrar', (tester) async {
      String? resultado;
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                resultado = await mostrarDialogo<String>(
                  context,
                  builder: (c) => Dialogo(
                    titulo: 'Aviso',
                    mensaje: 'Seguro',
                    textoPrincipal: 'Aceptar',
                    alPrincipal: () => Navigator.of(c).pop('si'),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(resultado, 'si');
      expect(find.text('Seguro'), findsNothing);
    });

    testWidgets('sin cerrarAlTocarFuera no se cierra al tocar el velo', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => mostrarDialogo<void>(
                context,
                cerrarAlTocarFuera: false,
                builder: (_) => const Dialogo(
                  titulo: 'Fijo',
                  mensaje: 'Sigue aqui',
                  textoPrincipal: 'Ok',
                  alPrincipal: null,
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.text('Sigue aqui'), findsOneWidget);
    });
  });

  group('HojaInferior', () {
    testWidgets('muestra titulo y contenido, y se cierra con pop', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => mostrarHojaInferior<void>(
                context,
                titulo: 'Filtros',
                builder: (c) => TextButton(
                  onPressed: () => Navigator.of(c).pop(),
                  child: const Text('Listo'),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Filtros'), findsOneWidget);
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.text('Filtros'), findsNothing);
    });

    testWidgets('con letra al 200 % no desborda', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const HojaInferior(titulo: 'Filtros', hijo: Text('Contenido')),
          escenario: Escenario.letraGrande,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Menu', () {
    testWidgets('abre, lista las opciones y entrega la elegida', (
      tester,
    ) async {
      String? elegido;
      await tester.pumpWidget(
        conTemaPista(
          Menu<String>(
            etiqueta: 'Mas opciones',
            alSeleccionar: (v) => elegido = v,
            items: const [
              ItemMenu(
                valor: 'editar',
                texto: 'Editar',
                icono: LucideIcons300.pencil,
              ),
              ItemMenu(valor: 'borrar', texto: 'Borrar', peligro: true),
              ItemMenu(valor: 'x', texto: 'Apagada', habilitado: false),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(Menu<String>));
      await tester.pumpAndSettle();
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Apagada'), findsOneWidget);
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      expect(elegido, 'borrar');
    });

    testWidgets('el disparador mide al menos 48', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Menu<String>(
            etiqueta: 'Mas opciones',
            alSeleccionar: _nada,
            items: [ItemMenu(valor: 'a', texto: 'A')],
          ),
        ),
      );
      final tamano = tester.getSize(find.byType(IconButton));
      expect(tamano.height, greaterThanOrEqualTo(48));
      expect(tamano.width, greaterThanOrEqualTo(48));
    });
  });

  group('Pestanas', () {
    testWidgets('marca la seleccionada y avisa el cambio', (tester) async {
      var indice = 0;
      await tester.pumpWidget(
        conTemaPista(
          StatefulBuilder(
            builder: (context, setState) => Pestanas(
              etiquetas: const ['Citas', 'Historial', 'Garantia'],
              indice: indice,
              alCambiar: (i) => setState(() => indice = i),
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Citas')),
        matchesSemantics(
          label: 'Citas, 1 de 3',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasEnabledState: false,
          isFocusable: false,
        ),
      );
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();
      expect(indice, 1);
    });

    testWidgets('cada pestana mide al menos 48 de alto y no desborda', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Pestanas(
              etiquetas: const ['Citas', 'Historial', 'Garantia', 'Pagos'],
              indice: 0,
              alCambiar: (_) {},
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(InkWell).first).height,
          greaterThanOrEqualTo(48),
        );
      }
    });
  });
}

void _nada(String _) {}
