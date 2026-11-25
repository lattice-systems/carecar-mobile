import 'dart:ui' show ImageFilter;

import 'package:carecar_mobile/nucleo/diseno/componentes/barra_portada.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/cabecera_portada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _cabecera({
  AccionPortada? principal,
  AccionPortada? secundaria,
  String? subtitulo = 'Nissan Kicks 2023',
}) => CabeceraPortada(
  titulo: 'Mi Kicks',
  subtitulo: subtitulo,
  descripcion: 'Foto de tu Nissan Kicks',
  portada: const Icon(Icons.directions_car_filled, size: 120),
  principal: principal,
  secundaria: secundaria,
);

void main() {
  testWidgets('muestra titulo, subtitulo y la portada', (tester) async {
    await tester.pumpWidget(conTemaPista(_cabecera()));
    expect(find.text('Mi Kicks'), findsOneWidget);
    expect(find.text('Nissan Kicks 2023'), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_filled), findsWidgets);
  });

  testWidgets('el fondo se desenfoca con sigma 40', (tester) async {
    await tester.pumpWidget(conTemaPista(_cabecera()));
    final filtro = tester.widget<ImageFiltered>(find.byType(ImageFiltered));
    expect(filtro.imageFilter, ImageFilter.blur(sigmaX: 40, sigmaY: 40));
  });

  testWidgets('sin acciones no muestra botones', (tester) async {
    await tester.pumpWidget(conTemaPista(_cabecera()));
    expect(find.byType(BotonPildora), findsNothing);
  });

  testWidgets('las dos acciones responden', (tester) async {
    var a = 0;
    var b = 0;
    await tester.pumpWidget(
      conTemaPista(
        _cabecera(
          principal: AccionPortada(
            texto: 'Agendar',
            icono: Icons.event,
            alPresionar: () => a++,
          ),
          secundaria: AccionPortada(texto: 'Detalle', alPresionar: () => b++),
        ),
      ),
    );
    await tester.tap(find.text('Agendar'));
    await tester.tap(find.text('Detalle'));
    expect([a, b], [1, 1]);
  });

  testWidgets('la descripcion reemplaza a la imagen para el lector', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(conTemaPista(_cabecera()));
    expect(find.bySemanticsLabel('Foto de tu Nissan Kicks'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Mi Kicks')).flagsCollection.isHeader,
      isTrue,
    );
    semantica.dispose();
  });

  testWidgets('con letra al 200 % los botones se apilan sin desbordar', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        SingleChildScrollView(
          child: _cabecera(
            principal: AccionPortada(texto: 'Agendar cita', alPresionar: () {}),
            secundaria: AccionPortada(texto: 'Ver detalle', alPresionar: () {}),
          ),
        ),
        escenario: Escenario.letraGrande,
      ),
    );
    final a = tester.getTopLeft(find.byType(BotonPildora).first);
    final b = tester.getTopLeft(find.byType(BotonPildora).last);
    expect(b.dy, greaterThan(a.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(
          SingleChildScrollView(
            child: _cabecera(
              principal: AccionPortada(texto: 'Agendar', alPresionar: () {}),
              secundaria: AccionPortada(texto: 'Detalle', alPresionar: () {}),
            ),
          ),
          escenario: escenario,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  group('bajo una barra translucida', () {
    // Pantalla con zona de reloj de 30 para comprobar que la reserva suma la
    // barra y esa zona, no solo el alto de la barra.
    Widget pantalla(Widget cuerpo, {double escala = 1}) => conTemaPista(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 800),
          padding: const EdgeInsets.only(top: 30),
          textScaler: TextScaler.linear(escala),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const BarraPortada(titulo: 'Detalle'),
          body: cuerpo,
        ),
      ),
    );

    Future<void> comprobar(WidgetTester tester, Widget cuerpo) async {
      await tester.pumpWidget(pantalla(cuerpo));
      final barra = tester.getRect(find.byType(AppBar));
      final pieza = tester.getRect(
        find.byIcon(Icons.directions_car_filled).last,
      );
      expect(pieza.top, greaterThanOrEqualTo(barra.bottom));
      // El fondo de la portada si llega hasta arriba.
      expect(tester.getRect(find.byType(CabeceraPortada)).top, 0);
    }

    testWidgets('en un ListView con relleno propio', (tester) async {
      await comprobar(
        tester,
        ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [_cabecera()],
        ),
      );
    });

    testWidgets('en un SingleChildScrollView', (tester) async {
      await comprobar(tester, SingleChildScrollView(child: _cabecera()));
    });

    testWidgets('con la letra al 200 % la reserva sigue siendo la barra', (
      tester,
    ) async {
      await tester.pumpWidget(
        pantalla(SingleChildScrollView(child: _cabecera()), escala: 2),
      );
      final barra = tester.getRect(find.byType(AppBar));
      final pieza = tester.getRect(
        find.byIcon(Icons.directions_car_filled).last,
      );
      expect(pieza.top, greaterThanOrEqualTo(barra.bottom));
    });

    testWidgets('al desplazar la barra es opaca y tapa lo que sube', (
      tester,
    ) async {
      await tester.pumpWidget(
        pantalla(
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [_cabecera(), const SizedBox(height: 1200)],
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppBar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color?.a, 1);
    });

    testWidgets('sin barra extendida no agrega reserva', (tester) async {
      await tester.pumpWidget(conTemaPista(_cabecera()));
      final pieza = tester.getRect(
        find.byIcon(Icons.directions_car_filled).last,
      );
      final cabecera = tester.getRect(find.byType(CabeceraPortada));
      expect(pieza.top - cabecera.top, lessThan(30));
    });
  });
}
