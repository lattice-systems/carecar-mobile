import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_pantalla.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_cerrar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/fila_acciones.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/marco_pantalla.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/resultado_pantalla.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/silueta_auto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_auto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget pantalla, {
  Brightness brillo = Brightness.light,
  double escala = 1,
}) => MaterialApp(
  locale: idiomaBase,
  localizationsDelegates: delegadasDeIdioma,
  supportedLocales: idiomasSoportados,
  theme: brillo == Brightness.dark ? TemaPista.oscuro() : TemaPista.claro(),
  builder: (context, hijo) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(escala)),
    child: hijo!,
  ),
  home: pantalla,
);

Future<void> _telefono(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('EncabezadoGrande', () {
    Widget lista({bool regreso = false, List<Widget> acciones = const []}) =>
        Scaffold(
          body: CustomScrollView(
            slivers: [
              EncabezadoGrande(
                titulo: 'Mi garaje',
                subtitulo: 'Dos autos',
                conRegreso: regreso,
                acciones: acciones,
              ),
              SliverList.builder(
                itemCount: 40,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('Fila $i')),
              ),
            ],
          ),
        );

    testWidgets(
      'expandido muestra el titulo grande y el subtitulo, no el pequeno',
      (tester) async {
        await _telefono(tester);
        await tester.pumpWidget(_app(lista()));
        expect(find.text('Mi garaje'), findsOneWidget);
        expect(find.text('Dos autos'), findsOneWidget);
        final grande = tester.widget<Text>(find.text('Mi garaje'));
        expect(grande.style!.fontSize, 28);
      },
    );

    testWidgets(
      'recogido queda el titulo pequeno en la barra y se va el subtitulo',
      (tester) async {
        await _telefono(tester);
        await tester.pumpWidget(_app(lista()));
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('Mi garaje'), findsOneWidget);
        expect(find.text('Dos autos'), findsNothing);
        final pequeno = tester.widget<Text>(find.text('Mi garaje'));
        expect(pequeno.style!.fontSize, 18);
      },
    );

    testWidgets('con regreso y acciones los pone en la barra', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(lista(regreso: true, acciones: const [BotonCerrar()])),
      );
      expect(find.byType(BotonRegresar), findsOneWidget);
      expect(find.byType(BotonCerrar), findsOneWidget);
      // La barra es lo primero: el titulo grande queda debajo de los botones.
      final barra = tester.getRect(find.byType(BotonRegresar));
      final titulo = tester.getRect(find.text('Mi garaje'));
      expect(titulo.top, greaterThanOrEqualTo(barra.bottom - 1));
    });

    testWidgets('un titulo largo con letra al 200 % no desborda', (
      tester,
    ) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CustomScrollView(
              slivers: [
                const EncabezadoGrande(
                  titulo: 'Historial de servicios de mi vehiculo',
                  subtitulo: 'Todo lo que le hemos hecho a tu auto',
                  conRegreso: true,
                ),
                SliverList.list(children: const [SizedBox(height: 900)]),
              ],
            ),
          ),
          escala: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('el encabezado es uno solo para el lector, grande o recogido', (
      tester,
    ) async {
      await _telefono(tester);
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_app(lista()));
      expect(find.bySemanticsLabel('Mi garaje'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Mi garaje'), findsOneWidget);
      semantica.dispose();
    });
  });

  group('MarcoPantalla', () {
    Widget marco({
      bool regreso = false,
      List<Widget>? acciones,
      Widget? barra,
    }) => MarcoPantalla(
      titulo: 'Gasto',
      conRegreso: regreso,
      acciones: acciones,
      barraInferior: barra,
      slivers: [
        SliverList.list(children: const [Text('contenido')]),
      ],
    );

    testWidgets('sin regreso ni acciones lleva Cerrar y cierra la pantalla', (
      tester,
    ) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    Navigator.of(context)
                        .push<void>(MaterialPageRoute(builder: (_) => marco())),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.byType(BotonCerrar), findsOneWidget);
      expect(find.byType(BotonRegresar), findsNothing);
      await tester.tap(find.byType(BotonCerrar));
      await tester.pumpAndSettle();
      expect(find.byType(MarcoPantalla), findsNothing);
    });

    testWidgets('con regreso lleva Regresar y no Cerrar', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(_app(marco(regreso: true)));
      expect(find.byType(BotonRegresar), findsOneWidget);
      expect(find.byType(BotonCerrar), findsNothing);
    });

    testWidgets('acciones propias sustituyen a Cerrar', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(marco(acciones: const [SizedBox(key: Key('mia'))])),
      );
      expect(find.byKey(const Key('mia')), findsOneWidget);
      expect(find.byType(BotonCerrar), findsNothing);
    });

    testWidgets('la barra inferior queda fija bajo el contenido', (
      tester,
    ) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(marco(barra: const BarraInferior(hijos: [Text('Guardar')]))),
      );
      expect(find.text('Guardar'), findsOneWidget);
      expect(
        tester.getRect(find.text('Guardar')).bottom,
        greaterThan(tester.getRect(find.text('contenido')).bottom),
      );
    });

    testWidgets('el estado ocupa el resto y conserva el titulo', (
      tester,
    ) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          MarcoPantalla.estado(titulo: 'Gasto', estado: const Text('vacio')),
        ),
      );
      expect(find.text('Gasto'), findsOneWidget);
      expect(find.text('vacio'), findsOneWidget);
    });

    testWidgets(
      'SeccionPantalla pone el titulo como encabezado y la nota debajo',
      (tester) async {
        await _telefono(tester);
        await tester.pumpWidget(
          _app(
            const Scaffold(
              body: SeccionPantalla(
                titulo: 'Fecha',
                hijo: Text('hijo'),
                nota: 'Apoyo',
              ),
            ),
          ),
        );
        expect(find.text('Fecha'), findsOneWidget);
        expect(
          tester.getRect(find.text('Apoyo')).top,
          greaterThan(tester.getRect(find.text('hijo')).bottom),
        );
      },
    );
  });

  group('BarraPantalla', () {
    testWidgets('lleva regreso, titulo, subtitulo y acciones', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: BarraPantalla(
              titulo: 'Manual',
              subtitulo: 'Versa 2024',
              acciones: [BotonCerrar()],
            ),
          ),
        ),
      );
      expect(find.byType(BotonRegresar), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Versa 2024'), findsOneWidget);
      expect(find.byType(BotonCerrar), findsOneWidget);
    });

    testWidgets('con letra al 200 % crece sin desbordar', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: BarraPantalla(
              titulo: 'Manual del propietario',
              subtitulo: 'Nissan Versa 2024',
              acciones: [BotonCerrar()],
            ),
          ),
          escala: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('FilaAcciones', () {
    testWidgets('dos acciones se reparten la fila', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: FilaAcciones(
              principal: AccionPantalla(texto: 'Agendar', alPresionar: () {}),
              secundaria: AccionPantalla(texto: 'Manual', alPresionar: () {}),
            ),
          ),
        ),
      );
      final a = tester.getRect(find.byType(BotonPildora).first);
      final b = tester.getRect(find.byType(BotonPildora).last);
      expect(a.top, b.top);
      expect(a.right, lessThan(b.left));
    });

    testWidgets('apiladas o con letra grande van una debajo de la otra', (
      tester,
    ) async {
      await _telefono(tester);
      Widget fila({bool apiladas = false}) => Scaffold(
        body: FilaAcciones(
          apiladas: apiladas,
          principal: AccionPantalla(texto: 'Agendar', alPresionar: () {}),
          secundaria: AccionPantalla(texto: 'Manual', alPresionar: () {}),
        ),
      );
      await tester.pumpWidget(_app(fila(apiladas: true)));
      expect(
        tester.getRect(find.byType(BotonPildora).last).top,
        greaterThan(tester.getRect(find.byType(BotonPildora).first).bottom - 1),
      );
      await tester.pumpWidget(_app(fila(), escala: 2));
      expect(
        tester.getRect(find.byType(BotonPildora).last).top,
        greaterThan(tester.getRect(find.byType(BotonPildora).first).bottom - 1),
      );
    });

    testWidgets('con una sola accion ocupa el ancho y toca', (tester) async {
      await _telefono(tester);
      var toques = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: FilaAcciones(
              principal: AccionPantalla(
                texto: 'Listo',
                alPresionar: () => toques++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Listo'));
      expect(toques, 1);
    });
  });

  group('TarjetaAuto', () {
    testWidgets('muestra marca, modelo, placas y kilometraje', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: TarjetaAuto(
              marca: 'Nissan',
              titulo: 'Versa 2024',
              placas: 'ABC-12-34',
              kilometraje: '18,450 km',
            ),
          ),
        ),
      );
      for (final texto in ['Nissan', 'Versa 2024', 'ABC-12-34', '18,450 km']) {
        expect(find.text(texto), findsOneWidget);
      }
      expect(find.byType(SiluetaAuto), findsOneWidget);
    });

    testWidgets('es un boton solo si tiene alToque y se anuncia entera', (
      tester,
    ) async {
      await _telefono(tester);
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: TarjetaAuto(
              titulo: 'Versa 2024',
              placas: 'ABC-12-34',
              alToque: () => toques++,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Versa 2024, ABC-12-34'), findsOneWidget);
      await tester.tap(find.byType(TarjetaAuto));
      expect(toques, 1);
      semantica.dispose();
    });

    testWidgets('con letra grande las placas bajan y no desborda', (
      tester,
    ) async {
      await _telefono(tester);
      for (final brillo in Brightness.values) {
        await tester.pumpWidget(
          _app(
            const Scaffold(
              body: TarjetaAuto(
                marca: 'Nissan',
                titulo: 'Versa 2024',
                placas: 'ABC-12-34',
                kilometraje: '18,450 km',
              ),
            ),
            brillo: brillo,
            escala: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.text('ABC-12-34')).top,
          greaterThan(tester.getRect(find.text('Versa 2024')).bottom - 1),
        );
      }
    });

    testWidgets('sin titulo queda la silueta con las placas', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(const Scaffold(body: TarjetaAuto(placas: 'ABC-12-34', alto: 150))),
      );
      expect(find.text('ABC-12-34'), findsOneWidget);
      expect(tester.getSize(find.byType(TarjetaAuto)).height, 150);
    });
  });

  group('TarjetaResumen', () {
    testWidgets(
      'muestra titulo, textos y la barra de avance con su porcentaje',
      (tester) async {
        await _telefono(tester);
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            const Scaffold(
              body: TarjetaResumen(
                titulo: 'Servicio de 20,000 km',
                subtitulo: 'Te toca por kilometraje',
                icono: Icons.build_outlined,
                progreso: 0.5,
                etiquetaProgreso: 'Faltan 1,550 km',
              ),
            ),
          ),
        );
        expect(find.text('Servicio de 20,000 km'), findsOneWidget);
        expect(find.text('Faltan 1,550 km'), findsOneWidget);
        expect(
          tester.getSemantics(find.byType(TarjetaResumen)),
          matchesSemantics(
            label: 'Servicio de 20,000 km, Te toca por kilometraje, Faltan 1,550 km',
            value: '50 %',
          ),
        );
        semantica.dispose();
      },
    );

    testWidgets(
      'con alToque es un boton con chevron; la insignia sale del estado',
      (tester) async {
        await _telefono(tester);
        var toques = 0;
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: TarjetaResumen(
                titulo: 'Folio 1042',
                icono: Icons.event_available_outlined,
                tono: Tono.exito,
                estado: 'Confirmada',
                tonoEstado: Tono.exito,
                alToque: () => toques++,
              ),
            ),
          ),
        );
        expect(find.text('Confirmada'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
        await tester.tap(find.byType(TarjetaResumen));
        expect(toques, 1);
      },
    );

    testWidgets(
      'la pista de lectura y el icono de la insignia son opcionales',
      (tester) async {
        await _telefono(tester);
        final semantica = tester.ensureSemantics();
        Widget tarjeta({required bool conIcono}) => _app(
          Scaffold(
            body: TarjetaResumen(
              titulo: 'Tu auto está en el taller',
              icono: Icons.car_repair_rounded,
              estado: '2 trabajos por aprobar',
              tonoEstado: Tono.advertencia,
              estadoConIcono: conIcono,
              pista: 'Ver el avance de tu orden',
              alToque: () {},
            ),
          ),
        );
        Finder iconoDeLaInsignia() => find.descendant(
          of: find.byType(Insignia),
          matching: find.byType(Icon),
        );

        await tester.pumpWidget(tarjeta(conIcono: true));
        expect(iconoDeLaInsignia(), findsOneWidget);
        expect(
          tester.getSemantics(find.byType(TarjetaResumen)).hint,
          'Ver el avance de tu orden',
        );

        await tester.pumpWidget(tarjeta(conIcono: false));
        expect(iconoDeLaInsignia(), findsNothing);
        semantica.dispose();
      },
    );

    testWidgets('el progreso fuera de 0 a 1 es un error de programacion', (
      tester,
    ) async {
      expect(
        () => TarjetaResumen(titulo: 'x', progreso: 1.5),
        throwsAssertionError,
      );
    });
  });

  group('ResultadoPantalla', () {
    testWidgets('muestra titulo, mensaje y acciones apiladas', (tester) async {
      await _telefono(tester);
      var salidas = 0;
      await tester.pumpWidget(
        _app(
          ResultadoPantalla(
            titulo: 'Cita confirmada',
            mensaje: 'Te esperamos el jueves.',
            principal: AccionPantalla(
              texto: 'Ver comprobante',
              alPresionar: () {},
            ),
            secundaria: AccionPantalla(
              texto: 'Listo',
              alPresionar: () => salidas++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cita confirmada'), findsOneWidget);
      expect(find.text('Te esperamos el jueves.'), findsOneWidget);
      expect(
        tester.getRect(find.text('Listo')).top,
        greaterThan(tester.getRect(find.text('Ver comprobante')).bottom),
      );
      await tester.tap(find.text('Listo'));
      expect(salidas, 1);
    });

    testWidgets('con reducir movimiento no anima la marca', (tester) async {
      await _telefono(tester);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _app(
            ResultadoPantalla(
              titulo: 'Hecho',
              principal: AccionPantalla(texto: 'Listo', alPresionar: () {}),
            ),
          ),
        ),
      );
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });

    testWidgets('se ve en oscuro y con letra al 200 % sin desbordar', (
      tester,
    ) async {
      await _telefono(tester);
      await tester.pumpWidget(
        _app(
          ResultadoPantalla(
            titulo: 'Cita confirmada',
            mensaje: 'Te esperamos el jueves 3 de diciembre a las 09:00.',
            principal: AccionPantalla(
              texto: 'Ver comprobante',
              alPresionar: () {},
            ),
            secundaria: AccionPantalla(texto: 'Listo', alPresionar: () {}),
          ),
          brillo: Brightness.dark,
          escala: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
