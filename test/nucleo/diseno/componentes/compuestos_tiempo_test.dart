import 'package:carecar_mobile/nucleo/diseno/componentes/calendario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/linea_de_tiempo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector_franja.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

const _pasos = [
  PasoLinea(titulo: 'Recibido', estado: EstadoPaso.hecho, hora: '09:00'),
  PasoLinea(
    titulo: 'Diagnostico',
    estado: EstadoPaso.hecho,
    hora: '10:30',
    nota: 'Sin hallazgos graves',
  ),
  PasoLinea(
    titulo: 'En reparacion',
    estado: EstadoPaso.actual,
    nota: 'Listo hacia las 16:00',
  ),
  PasoLinea(titulo: 'Control de calidad', estado: EstadoPaso.pendiente),
  PasoLinea(titulo: 'Entregado', estado: EstadoPaso.pendiente),
];

void main() {
  group('LineaDeTiempo', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const SingleChildScrollView(child: LineaDeTiempo(pasos: _pasos)),
            escenario: escenario,
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('En reparacion'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('los pasos hechos llevan palomita', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const SingleChildScrollView(child: LineaDeTiempo(pasos: _pasos)),
        ),
      );
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('cada paso se anuncia con su estado', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const SingleChildScrollView(child: LineaDeTiempo(pasos: _pasos)),
        ),
      );
      expect(
        find.bySemanticsLabel(
          'Etapa 2 de 5, completado, Diagnostico, 10:30, '
          'Sin hallazgos graves',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Etapa 3 de 5, en curso, En reparacion, Listo hacia las 16:00',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Etapa 5 de 5, pendiente, Entregado'),
        findsOneWidget,
      );
    });

    testWidgets('el paso actual respira y con reducir movimiento no', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          const SingleChildScrollView(child: LineaDeTiempo(pasos: _pasos)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(
        conTemaPista(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SingleChildScrollView(child: LineaDeTiempo(pasos: _pasos)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('sin paso actual no anima', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const LineaDeTiempo(
            pasos: [
              PasoLinea(titulo: 'A', estado: EstadoPaso.hecho),
              PasoLinea(titulo: 'B', estado: EstadoPaso.pendiente),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('LineaDeTiempoPaginada', () {
    List<PasoLinea> pasos(int n) => [
      for (var i = 1; i <= n; i++)
        PasoLinea(titulo: 'Servicio $i', estado: EstadoPaso.hecho),
    ];

    Widget lista({
      required int n,
      required bool hayMas,
      bool cargandoMas = false,
      bool cargarAlLlegar = false,
      required VoidCallback alPedirMas,
      Escenario escenario = Escenario.claro,
    }) => conTemaPista(
      SizedBox(
        height: 700,
        child: LineaDeTiempoPaginada(
          pasos: pasos(n),
          hayMas: hayMas,
          cargandoMas: cargandoMas,
          cargarAlLlegar: cargarAlLlegar,
          alPedirMas: alPedirMas,
        ),
      ),
      escenario: escenario,
    );

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          lista(n: 3, hayMas: true, alPedirMas: () {}, escenario: escenario),
        );
        expect(find.text('Servicio 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('con mas paginas muestra Ver mas y lo pide al tocar', (
      tester,
    ) async {
      var pedidas = 0;
      await tester.pumpWidget(
        lista(n: 3, hayMas: true, alPedirMas: () => pedidas++),
      );
      await tester.tap(find.text('Ver mas'));
      expect(pedidas, 1);
    });

    testWidgets('sin mas paginas no muestra Ver mas', (tester) async {
      await tester.pumpWidget(lista(n: 3, hayMas: false, alPedirMas: () {}));
      expect(find.text('Ver mas'), findsNothing);
    });

    testWidgets('mientras carga muestra esqueleto y no el boton', (
      tester,
    ) async {
      await tester.pumpWidget(
        lista(n: 3, hayMas: true, cargandoMas: true, alPedirMas: () {}),
      );
      expect(find.text('Ver mas'), findsNothing);
    });

    testWidgets('al llegar al final pide la pagina una sola vez', (
      tester,
    ) async {
      var pedidas = 0;
      await tester.pumpWidget(
        lista(
          n: 3,
          hayMas: true,
          cargarAlLlegar: true,
          alPedirMas: () => pedidas++,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(pedidas, 1);
    });

    testWidgets('pide otra vez cuando llega una pagina nueva', (tester) async {
      var pedidas = 0;
      Widget con(int n) => lista(
        n: n,
        hayMas: true,
        cargarAlLlegar: true,
        alPedirMas: () => pedidas++,
      );
      await tester.pumpWidget(con(3));
      await tester.pump();
      await tester.pumpWidget(con(6));
      await tester.pump();
      await tester.pump();
      expect(pedidas, 2);
    });

    testWidgets('solo construye los pasos visibles', (tester) async {
      await tester.pumpWidget(lista(n: 500, hayMas: false, alPedirMas: () {}));
      expect(find.text('Servicio 500'), findsNothing);
      expect(find.text('Servicio 1'), findsOneWidget);
    });
  });

  group('Calendario', () {
    final primero = DateTime(2026, 11, 3);
    final ultimo = DateTime(2027, 1, 31);

    Widget calendario({
      DateTime? seleccionado,
      DateTime? mes,
      ValueChanged<DateTime>? alSeleccionar,
      ValueChanged<DateTime>? alCambiarMes,
      bool Function(DateTime)? habilitado,
      Escenario escenario = Escenario.claro,
    }) => conTemaPista(
      SingleChildScrollView(
        child: Calendario(
          mes: mes ?? DateTime(2026, 11),
          seleccionado: seleccionado,
          alSeleccionar: alSeleccionar ?? (_) {},
          alCambiarMes: alCambiarMes ?? (_) {},
          primerDia: primero,
          ultimoDia: ultimo,
          habilitado: habilitado,
          hoy: DateTime(2026, 11, 10),
        ),
      ),
      escenario: escenario,
    );

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(calendario(escenario: escenario));
        expect(find.text('noviembre 2026'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('noviembre de 2026 empieza en domingo', (tester) async {
      await tester.pumpWidget(calendario());
      final uno = tester.getCenter(find.text('1'));
      final domingo = tester.getCenter(find.text('D'));
      expect((uno.dx - domingo.dx).abs(), lessThan(4));
    });

    testWidgets('elegir un dia avisa su fecha', (tester) async {
      DateTime? elegido;
      await tester.pumpWidget(calendario(alSeleccionar: (d) => elegido = d));
      await tester.tap(find.text('15'));
      expect(elegido, DateTime(2026, 11, 15));
    });

    testWidgets('los dias antes del primero no se pueden elegir', (
      tester,
    ) async {
      DateTime? elegido;
      await tester.pumpWidget(calendario(alSeleccionar: (d) => elegido = d));
      await tester.tap(find.text('1'));
      expect(elegido, isNull);
    });

    testWidgets('un dia sin cupo no se elige, se tacha y se anuncia', (
      tester,
    ) async {
      DateTime? elegido;
      await tester.pumpWidget(
        calendario(
          alSeleccionar: (d) => elegido = d,
          habilitado: (d) => d.day != 20,
        ),
      );
      await tester.tap(find.text('20'));
      expect(elegido, isNull);
      expect(
        tester.widget<Text>(find.text('20')).style?.decoration,
        TextDecoration.lineThrough,
      );
      expect(
        find.bySemanticsLabel('20 de noviembre, sin cupo'),
        findsOneWidget,
      );
    });

    testWidgets('hoy y seleccionado se anuncian', (tester) async {
      await tester.pumpWidget(calendario(seleccionado: DateTime(2026, 11, 10)));
      expect(
        find.bySemanticsLabel('10 de noviembre, hoy, seleccionado'),
        findsOneWidget,
      );
    });

    testWidgets('cada dia mide al menos 48 de alto', (tester) async {
      await tester.pumpWidget(calendario());
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('15'),
                matching: find.byType(InkWell),
              ),
            )
            .height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('cambia de mes y no pasa de los limites', (tester) async {
      DateTime? nuevo;
      await tester.pumpWidget(calendario(alCambiarMes: (m) => nuevo = m));
      await tester.tap(find.byTooltip('Mes siguiente'));
      expect(nuevo, DateTime(2026, 12));

      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_left),
            )
            .onPressed,
        isNull,
      );

      await tester.pumpWidget(calendario(mes: DateTime(2027, 1)));
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_right),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('SelectorFranja', () {
    const franjas = [
      FranjaHoraria(etiqueta: '09:00', cupo: 3),
      FranjaHoraria(etiqueta: '10:00', cupo: 1),
      FranjaHoraria(etiqueta: '11:00', cupo: 0),
      FranjaHoraria(etiqueta: '12:00'),
    ];

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            SelectorFranja(
              franjas: franjas,
              seleccionada: 0,
              alSeleccionar: (_) {},
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('09:00 · 3 lugares'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('dice el cupo con texto y singular o plural', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          SelectorFranja(
            franjas: franjas,
            seleccionada: null,
            alSeleccionar: (_) {},
          ),
        ),
      );
      expect(find.text('10:00 · 1 lugar'), findsOneWidget);
      expect(find.text('11:00 · sin cupo'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
    });

    testWidgets('elegir una franja avisa su indice', (tester) async {
      int? elegida;
      await tester.pumpWidget(
        conTemaPista(
          SelectorFranja(
            franjas: franjas,
            seleccionada: null,
            alSeleccionar: (i) => elegida = i,
          ),
        ),
      );
      await tester.tap(find.text('10:00 · 1 lugar'));
      expect(elegida, 1);
    });

    testWidgets('una franja sin cupo no se puede elegir', (tester) async {
      int? elegida;
      await tester.pumpWidget(
        conTemaPista(
          SelectorFranja(
            franjas: franjas,
            seleccionada: null,
            alSeleccionar: (i) => elegida = i,
          ),
        ),
      );
      await tester.tap(find.text('11:00 · sin cupo'));
      expect(elegida, isNull);
    });

    testWidgets('sin franjas explica por que', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          SelectorFranja(
            franjas: const [],
            seleccionada: null,
            alSeleccionar: (_) {},
          ),
        ),
      );
      expect(find.text('No hay horarios para este dia.'), findsOneWidget);
    });
  });
}
