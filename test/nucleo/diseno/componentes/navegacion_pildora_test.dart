import 'dart:ui' show Tristate;

import 'package:carecar_mobile/nucleo/diseno/componentes/barra_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_navegacion.dart'
    show DestinoNavegacion;
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_accion_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_acciones_pildora.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

const _destinos = [
  DestinoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined),
  DestinoNavegacion(
    etiqueta: 'Vehículos',
    icono: Icons.directions_car_outlined,
  ),
  DestinoNavegacion(
    etiqueta: 'Citas',
    icono: Icons.calendar_month_outlined,
    conteo: 2,
  ),
  DestinoNavegacion(etiqueta: 'Catálogo', icono: Icons.grid_view_outlined),
];

void main() {
  group('BarraFlotante (rediseño de navegación)', () {
    Widget barra(int indice, ValueChanged<int> alCambiar) => conTemaPista(
      Align(
        alignment: Alignment.bottomCenter,
        child: BarraFlotante(
          destinos: _destinos,
          indice: indice,
          alCambiar: alCambiar,
        ),
      ),
    );

    testWidgets('muestra icono y etiqueta de cada destino sin desbordar', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            BarraFlotante(destinos: _destinos, indice: 0, alCambiar: (_) {}),
            escenario: escenario,
          ),
        );
        for (final d in _destinos) {
          expect(find.text(d.etiqueta), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('tocar un destino avisa su índice', (tester) async {
      var elegido = -1;
      await tester.pumpWidget(barra(0, (i) => elegido = i));

      await tester.tap(find.text('Catálogo'));

      expect(elegido, 3);
    });

    testWidgets('es una píldora flotante: no toca los bordes de la pantalla', (
      tester,
    ) async {
      await tester.pumpWidget(barra(0, (_) {}));

      final caja = tester.getRect(
        find.descendant(
          of: find.byType(BarraFlotante),
          matching: find.byType(ClipRRect),
        ),
      );
      final pantalla = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(caja.left, greaterThan(0));
      expect(caja.right, lessThan(pantalla.width));
      expect(caja.bottom, lessThan(pantalla.height));
    });

    testWidgets('cada destino mide al menos 48 y anuncia su posición', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(barra(1, (_) {}));

      for (final d in _destinos) {
        expect(tester.getSize(find.text(d.etiqueta)).height, greaterThan(0));
      }
      final selec = tester.getSemantics(find.text('Vehículos'));
      expect(selec.label, contains('Vehículos, 2 de 4'));
      expect(selec.flagsCollection.isSelected, Tristate.isTrue);
      final otro = tester.getSemantics(find.text('Inicio'));
      expect(otro.flagsCollection.isSelected, Tristate.isFalse);
      expect(
        tester.getSemantics(find.text('Citas')).label,
        contains('2 pendientes'),
      );
      semantica.dispose();
    });

    testWidgets('el destino activo se distingue del resto', (tester) async {
      await tester.pumpWidget(barra(2, (_) {}));

      final activo = tester.widget<Text>(find.text('Citas')).style!;
      final inactivo = tester.widget<Text>(find.text('Inicio')).style!;
      expect(activo.fontWeight, FontWeight.w700);
      expect(activo.color, isNot(inactivo.color));
    });
  });

  group('GrupoAccionesPildora', () {
    testWidgets('cada acción es un botón de 48 con su etiqueta', (
      tester,
    ) async {
      var citas = 0;
      var ayuda = 0;
      await tester.pumpWidget(
        conTemaPista(
          Center(
            child: GrupoAccionesPildora(
              acciones: [
                AccionIcono(
                  icono: Icons.calendar_month_outlined,
                  etiqueta: 'Mis citas',
                  alPresionar: () => citas++,
                ),
                AccionIcono(
                  icono: Icons.help_outline,
                  etiqueta: 'Ayuda',
                  alPresionar: () => ayuda++,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Mis citas'));
      await tester.tap(find.byTooltip('Ayuda'));

      expect((citas, ayuda), (1, 1));
      for (final e in ['Mis citas', 'Ayuda']) {
        final caja = tester.getSize(find.byTooltip(e));
        expect(caja.width, greaterThanOrEqualTo(48));
        expect(caja.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Center(
              child: GrupoAccionesPildora(
                acciones: [
                  AccionIcono(
                    icono: Icons.search,
                    etiqueta: 'Buscar',
                    alPresionar: () {},
                  ),
                  AccionIcono(
                    icono: Icons.tune,
                    etiqueta: 'Filtrar',
                    alPresionar: () {},
                  ),
                  AccionIcono(
                    icono: Icons.history,
                    etiqueta: 'Historial',
                    alPresionar: () {},
                  ),
                ],
              ),
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('BotonAccionFlotante', () {
    testWidgets('muestra texto e icono y avisa al tocarlo', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        conTemaPista(
          Center(
            child: BotonAccionFlotante(
              texto: 'Agendar cita',
              icono: Icons.add,
              alPresionar: () => toques++,
            ),
          ),
        ),
      );

      expect(find.text('Agendar cita'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.text('Agendar cita'));
      expect(toques, 1);
      expect(
        tester.getSize(find.byType(BotonAccionFlotante)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('es un botón para el lector de pantalla', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(
          Center(
            child: BotonAccionFlotante(
              texto: 'Agendar cita',
              icono: Icons.add,
              alPresionar: () {},
            ),
          ),
        ),
      );

      final s = tester.getSemantics(find.text('Agendar cita'));
      expect(s.flagsCollection.isButton, isTrue);
      expect(s.label, 'Agendar cita');
      semantica.dispose();
    });

    testWidgets('con letra grande no desborda', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Center(
              child: BotonAccionFlotante(
                texto: 'Agendar cita',
                icono: Icons.add,
                alPresionar: () {},
              ),
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
