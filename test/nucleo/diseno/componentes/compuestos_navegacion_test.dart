import 'dart:convert';

import 'package:carecar_mobile/nucleo/diseno/componentes/barra_navegacion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_accion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

const _destinos = [
  DestinoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined),
  DestinoNavegacion(etiqueta: 'Mi auto', icono: Icons.directions_car_outlined),
  DestinoNavegacion(
    etiqueta: 'Servicio',
    icono: Icons.build_outlined,
    conteo: 3,
  ),
  DestinoNavegacion(etiqueta: 'Explorar', icono: Icons.explore_outlined),
  DestinoNavegacion(etiqueta: 'Cuenta', icono: Icons.person_outline),
];

void main() {
  group('BarraNavegacion', () {
    Widget barra(int indice, ValueChanged<int> alCambiar) => conTemaPista(
      Align(
        alignment: Alignment.bottomCenter,
        child: BarraNavegacion(
          destinos: _destinos,
          indice: indice,
          alCambiar: alCambiar,
        ),
      ),
    );

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            BarraNavegacion(destinos: _destinos, indice: 0, alCambiar: (_) {}),
            escenario: escenario,
          ),
        );
        for (final d in _destinos) {
          expect(find.text(d.etiqueta), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('tocar un destino avisa su indice', (tester) async {
      var elegido = -1;
      await tester.pumpWidget(barra(0, (i) => elegido = i));
      await tester.tap(find.text('Explorar'));
      expect(elegido, 3);
    });

    testWidgets('cada destino mide al menos 48', (tester) async {
      await tester.pumpWidget(barra(0, (_) {}));
      for (final inkwell in find.byType(InkWell).evaluate()) {
        final tamano = tester.getSize(find.byWidget(inkwell.widget));
        expect(tamano.height, greaterThanOrEqualTo(48));
        expect(tamano.width, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('se anuncia con posicion, seleccion y pendientes', (
      tester,
    ) async {
      await tester.pumpWidget(barra(0, (_) {}));
      expect(find.bySemanticsLabel('Inicio, 1 de 5'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Servicio, 3 de 5, 3 pendientes'),
        findsOneWidget,
      );
    });

    testWidgets('el conteo mayor a 99 se acorta', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          BarraNavegacion(
            destinos: const [
              DestinoNavegacion(etiqueta: 'A', icono: Icons.home, conteo: 150),
              DestinoNavegacion(etiqueta: 'B', icono: Icons.home),
            ],
            indice: 0,
            alCambiar: (_) {},
          ),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('EncabezadoGrande', () {
    double altura(WidgetTester tester) => tester
        .getSize(
          find
              .descendant(
                of: find.byType(EncabezadoGrande),
                matching: find.byType(DecoratedBox),
              )
              .first,
        )
        .height;

    Widget pantalla({Escenario escenario = Escenario.claro}) => conTemaPista(
      CustomScrollView(
        slivers: [
          const EncabezadoGrande(
            titulo: 'Mis citas',
            subtitulo: 'Tus proximos servicios',
            acciones: [IconButton(onPressed: null, icon: Icon(Icons.add))],
          ),
          SliverList.builder(
            itemCount: 40,
            itemBuilder: (_, i) => SizedBox(height: 56, child: Text('Fila $i')),
          ),
        ],
      ),
      escenario: escenario,
    );

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(pantalla(escenario: escenario));
        expect(find.text('Mis citas'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('al desplazar se encoge y oculta el subtitulo', (tester) async {
      await tester.pumpWidget(pantalla());
      final alturaInicial = altura(tester);
      expect(find.text('Tus proximos servicios'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      final alturaFinal = altura(tester);
      expect(alturaFinal, lessThan(alturaInicial));
      expect(find.text('Tus proximos servicios'), findsNothing);
      expect(find.text('Mis citas'), findsOneWidget);
    });

    testWidgets('con letra al 200 % es mas alto que a 100 %', (tester) async {
      await tester.pumpWidget(pantalla());
      final normal = altura(tester);
      await tester.pumpWidget(pantalla(escenario: Escenario.letraGrande));
      final grande = altura(tester);
      expect(grande, greaterThan(normal));
    });
  });

  group('TarjetaVehiculo', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            SingleChildScrollView(
              child: TarjetaVehiculo(
                nombre: 'Mazda CX-5 2024',
                detalle: 'Placa ABC-123',
                foto: MemoryImage(_png),
                estado: 'Servicio en proceso',
                tonoEstado: Tono.advertencia,
                alToque: () {},
              ),
            ),
            escenario: escenario,
          ),
        );
        await tester.pump();
        expect(find.text('Mazda CX-5 2024'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('sin foto muestra la silueta', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const TarjetaVehiculo(nombre: 'Mazda CX-5')),
      );
      expect(find.byIcon(Icons.directions_car_filled_outlined), findsOneWidget);
    });

    testWidgets('con heroTag envuelve la foto en un Hero', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          TarjetaVehiculo(
            nombre: 'Mazda CX-5',
            foto: MemoryImage(_png),
            heroTag: 'auto-1',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('se anuncia como un solo nodo y responde al toque', (
      tester,
    ) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(
          TarjetaVehiculo(
            nombre: 'Mazda CX-5',
            detalle: 'Placa ABC-123',
            estado: 'Listo',
            alToque: () => veces++,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Mazda CX-5. Placa ABC-123. Listo'),
        findsOneWidget,
      );
      await tester.tap(find.text('Mazda CX-5'));
      expect(veces, 1);
    });
  });

  group('TarjetaAccion', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            TarjetaAccion(
              titulo: 'Pedir ayuda en el camino',
              descripcion: 'Comparte tu ubicacion con la agencia',
              icono: Icons.sos,
              tono: Tono.peligro,
              alToque: () {},
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('Pedir ayuda en el camino'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('responde al toque y mide al menos 48', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(
          TarjetaAccion(
            titulo: 'Agendar',
            icono: Icons.event,
            alToque: () => veces++,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(TarjetaAccion)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Agendar'));
      expect(veces, 1);
    });

    testWidgets('deshabilitada no responde', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const TarjetaAccion(
            titulo: 'Agendar',
            icono: Icons.event,
            alToque: null,
          ),
        ),
      );
      await tester.tap(find.text('Agendar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('se anuncia como boton con titulo y descripcion', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          TarjetaAccion(
            titulo: 'Agendar',
            descripcion: 'Elige fecha y hora',
            icono: Icons.event,
            alToque: () {},
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Agendar. Elige fecha y hora'),
        findsOneWidget,
      );
    });
  });
}
