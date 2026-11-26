import 'package:carecar_mobile/nucleo/diseno/componentes/boton_circular.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/mapa.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

const _teselas = ConfiguracionTeselas(
  urlPlantilla: 'https://teselas.invalid/{z}/{x}/{y}.png',
  atribucion: '© Mapas de prueba',
);
const _leon = Coordenada(21.1250, -101.6860);

const _lienzo = ValueKey('mapa-lienzo');
const _pin = ValueKey('mapa-pin');
const _yo = ValueKey('mapa-mi-ubicacion');
const _movil = ValueKey('mapa-en-movimiento');

/// El mapa con las teselas en memoria: ninguna prueba sale a la red.
Widget _app(
  Widget hijo, {
  Escenario escenario = Escenario.claro,
  bool reducirMovimiento = false,
}) => conTemaPista(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: reducirMovimiento),
      child: SingleChildScrollView(child: hijo),
    ),
  ),
  escenario: escenario,
);

/// Guarda el pin que entrega el componente y se lo devuelve, como una pantalla.
class _ConPin extends StatefulWidget {
  const _ConPin({required this.alCambiar, this.inicial});

  final Coordenada? inicial;
  final ValueChanged<Coordenada> alCambiar;

  @override
  State<_ConPin> createState() => _EstadoConPin();
}

class _EstadoConPin extends State<_ConPin> {
  late Coordenada? _punto = widget.inicial;

  @override
  Widget build(BuildContext context) => Mapa(
    teselas: _teselas,
    fuenteTeselas: TeselasLisas(),
    pin: _punto,
    alMoverPin: (p) {
      widget.alCambiar(p);
      setState(() => _punto = p);
    },
  );
}

Mapa _soloLectura({
  Coordenada? pin,
  Coordenada? miUbicacion,
  MarcadorEnMovimiento? enMovimiento,
  ProveedorUbicacion? proveedor,
  FuenteTeselas? fuente,
  String? descripcion,
}) => Mapa(
  teselas: _teselas,
  fuenteTeselas: fuente ?? TeselasLisas(),
  pin: pin,
  miUbicacion: miUbicacion,
  enMovimiento: enMovimiento,
  proveedorUbicacion: proveedor,
  descripcion: descripcion,
);

Future<void> _esperarToque(WidgetTester tester) async {
  // El mapa espera un instante por si el toque es el primero de uno doble.
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  group('teselas', () {
    testWidgets('salen de la fuente inyectada, sin red', (tester) async {
      final fuente = TeselasLisas();

      await tester.pumpWidget(_app(_soloLectura(pin: _leon, fuente: fuente)));
      await tester.pumpAndSettle();

      expect(fuente.pedidas, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('la atribución está siempre a la vista y sobre el mapa', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_soloLectura(pin: _leon), escenario: Escenario.letraGrande),
      );
      await tester.pump();

      final credito = find.text('© Mapas de prueba');
      expect(credito.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byKey(_lienzo)).contains(tester.getCenter(credito)),
        isTrue,
      );
      expect(find.bySemanticsLabel('© Mapas de prueba'), findsOneWidget);
    });

    testWidgets('sin conexión lo explica y deja reintentar', (tester) async {
      final fuente = TeselasSinConexion();
      await tester.pumpWidget(_app(_soloLectura(pin: _leon, fuente: fuente)));
      await tester.pumpAndSettle();

      expect(find.textContaining('No pudimos cargar el mapa'), findsOneWidget);
      expect(find.byKey(_pin), findsOneWidget);

      fuente.hayConexion = true;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No pudimos cargar el mapa'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('si sigue sin conexión el aviso vuelve', (tester) async {
      await tester.pumpWidget(
        _app(_soloLectura(pin: _leon, fuente: TeselasSinConexion())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No pudimos cargar el mapa'), findsOneWidget);
    });
  });

  group('pin', () {
    testWidgets('tocar el mapa lo pone donde se tocó', (tester) async {
      Coordenada? elegido;
      await tester.pumpWidget(_app(_ConPin(alCambiar: (p) => elegido = p)));
      await tester.pump();

      await tester.tapAt(tester.getCenter(find.byKey(_lienzo)));
      await _esperarToque(tester);

      expect(elegido!.latitud, closeTo(_leon.latitud, 0.001));
      expect(elegido!.longitud, closeTo(_leon.longitud, 0.001));
    });

    testWidgets('la punta del marcador queda en la coordenada', (tester) async {
      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();

      final centro = tester.getCenter(find.byKey(_lienzo));
      final marcador = tester.getRect(find.byKey(_pin));
      expect(marcador.bottomCenter.dx, closeTo(centro.dx, 1));
      expect(marcador.bottomCenter.dy, closeTo(centro.dy, 1));
      expect(marcador.size, const Size(48, 48));
    });

    testWidgets('arrastrarlo hacia la derecha lo mueve al este', (
      tester,
    ) async {
      final movimientos = <Coordenada>[];
      await tester.pumpWidget(
        _app(_ConPin(inicial: _leon, alCambiar: movimientos.add)),
      );
      await tester.pump();
      final antes = tester.getCenter(find.byKey(_pin));

      await tester.drag(find.byKey(_pin), const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(movimientos, hasLength(1), reason: 'solo al soltar');
      expect(movimientos.single.longitud, greaterThan(_leon.longitud));
      expect(movimientos.single.latitud, closeTo(_leon.latitud, 0.00001));
      // El mapa no se desplazó: lo que se movió fue el pin.
      expect(tester.getCenter(find.byKey(_pin)).dx, closeTo(antes.dx + 80, 1));
    });

    testWidgets('mientras se arrastra sigue al dedo', (tester) async {
      await tester.pumpWidget(_app(_ConPin(inicial: _leon, alCambiar: (_) {})));
      await tester.pump();
      final antes = tester.getCenter(find.byKey(_pin));

      final dedo = await tester.startGesture(antes);
      await dedo.moveBy(const Offset(0, 30));
      await dedo.moveBy(const Offset(0, 30));
      await tester.pump();

      expect(tester.getCenter(find.byKey(_pin)).dy, closeTo(antes.dy + 60, 1));
      await dedo.up();
      await tester.pump();
    });

    testWidgets('arrastrarlo hacia abajo no desplaza la página', (
      tester,
    ) async {
      Coordenada? elegido;
      final desplazamiento = ScrollController();
      addTearDown(desplazamiento.dispose);
      await tester.pumpWidget(
        conTemaPista(
          ListView(
            controller: desplazamiento,
            children: [
              _ConPin(inicial: _leon, alCambiar: (p) => elegido = p),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.timedDrag(
        find.byKey(_pin),
        const Offset(0, 60),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(desplazamiento.offset, 0);
      expect(elegido!.latitud, lessThan(_leon.latitud));
    });

    for (final (nombre, norte, este) in [
      ('Mover el pin al norte', 1, 0),
      ('Mover el pin al sur', -1, 0),
      ('Mover el pin al este', 0, 1),
      ('Mover el pin al oeste', 0, -1),
    ]) {
      testWidgets('sin arrastrar: «$nombre»', (tester) async {
        Coordenada? elegido;
        await tester.pumpWidget(
          _app(_ConPin(inicial: _leon, alCambiar: (p) => elegido = p)),
        );
        await tester.pump();
        final boton = find.byWidgetPredicate(
          (w) => w is BotonCircular && w.etiqueta == nombre,
        );
        expect(tester.getSize(boton).shortestSide, greaterThanOrEqualTo(48));

        await tester.tap(boton);
        await tester.pumpAndSettle();

        final dLat = elegido!.latitud - _leon.latitud;
        final dLng = elegido!.longitud - _leon.longitud;
        expect(dLat.abs() < 1e-7 ? 0 : dLat.sign, norte);
        expect(dLng.abs() < 1e-7 ? 0 : dLng.sign, este);
        expect(find.bySemanticsLabel(nombre), findsOneWidget);
      });
    }

    testWidgets('al moverlo con un botón lo anuncia', (tester) async {
      await tester.pumpWidget(_app(_ConPin(inicial: _leon, alCambiar: (_) {})));
      await tester.pump();

      await tester.tap(find.byTooltip('Mover el pin al norte'));
      await tester.pump();

      expect(
        tester.takeAnnouncements().map((a) => a.message),
        contains('Pin movido al norte'),
      );
    });

    testWidgets('sin pin se puede poner en el centro sin tocar el mapa', (
      tester,
    ) async {
      Coordenada? elegido;
      await tester.pumpWidget(_app(_ConPin(alCambiar: (p) => elegido = p)));
      await tester.pump();
      expect(find.byKey(_pin), findsNothing);
      expect(find.byTooltip('Mover el pin al norte'), findsNothing);

      await tester.tap(find.text('Poner el pin en el centro'));
      await tester.pumpAndSettle();

      expect(elegido!.latitud, closeTo(_leon.latitud, 0.00001));
      expect(elegido!.longitud, closeTo(_leon.longitud, 0.00001));
      expect(find.byKey(_pin), findsOneWidget);
    });

    testWidgets('sin alMoverPin es de solo lectura', (tester) async {
      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();
      final antes = tester.getCenter(find.byKey(_pin));

      await tester.tapAt(tester.getCenter(find.byKey(_lienzo)));
      await _esperarToque(tester);

      expect(find.byType(BotonCircular), findsNothing);
      expect(find.text('Poner el pin en el centro'), findsNothing);
      expect(tester.getCenter(find.byKey(_pin)), antes);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un pin puesto desde fuera y lejano queda a la vista', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();

      await tester.pumpWidget(
        _app(_soloLectura(pin: const Coordenada(25.67, -100.31))),
      );
      await tester.pumpAndSettle();

      final lienzo = tester.getRect(find.byKey(_lienzo));
      expect(lienzo.contains(tester.getCenter(find.byKey(_pin))), isTrue);
    });
  });

  group('ubicación propia', () {
    testWidgets('con el dato dibuja el punto y lo dice', (tester) async {
      await tester.pumpWidget(_app(_soloLectura(miUbicacion: _leon)));
      await tester.pump();

      expect(find.byKey(_yo), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Se muestra tu ubicación')),
        findsOneWidget,
      );
    });

    testWidgets('sin proveedor no ofrece el botón', (tester) async {
      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();

      expect(find.text('Ver mi ubicación'), findsNothing);
    });

    testWidgets('solo lee la posición cuando la persona la pide', (
      tester,
    ) async {
      const lejos = Coordenada(25.67, -100.31);
      final proveedor = UbicacionFalsa(posicion: lejos);
      await tester.pumpWidget(_app(_soloLectura(proveedor: proveedor)));
      await tester.pumpAndSettle();
      expect(proveedor.consultasDePosicion, 0);
      expect(proveedor.peticionesDePermiso, 0);
      expect(find.byKey(_yo), findsNothing);

      await tester.tap(find.text('Ver mi ubicación'));
      await tester.pumpAndSettle();

      expect(proveedor.consultasDePosicion, 1);
      final centro = tester.getCenter(find.byKey(_lienzo));
      expect(tester.getCenter(find.byKey(_yo)).dx, closeTo(centro.dx, 1));
      expect(tester.getCenter(find.byKey(_yo)).dy, closeTo(centro.dy, 1));
    });

    for (final (error, mensaje) in <(ErrorUbicacion, String)>[
      (const UbicacionPermisoDenegado(), 'No nos diste permiso'),
      (const UbicacionPermisoDenegadoParaSiempre(), 'en los ajustes'),
      (const UbicacionServicioApagado(), 'está apagada'),
      (const UbicacionTiempoAgotado(), 'tardó demasiado'),
    ]) {
      testWidgets('${error.runtimeType} se explica y el mapa sigue', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            Mapa(
              teselas: _teselas,
              fuenteTeselas: TeselasLisas(),
              pin: _leon,
              alMoverPin: (_) {},
              proveedorUbicacion: UbicacionFalsa(error: error),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Ver mi ubicación'));
        await tester.pumpAndSettle();

        expect(find.textContaining(mensaje), findsOneWidget);
        expect(find.byKey(_yo), findsNothing);
        expect(find.byTooltip('Mover el pin al norte'), findsOneWidget);
        expect(find.text('Ver mi ubicación'), findsOneWidget);
      });
    }

    testWidgets('al reintentar con éxito quita el aviso', (tester) async {
      final proveedor = UbicacionFalsa(error: const UbicacionServicioApagado());
      await tester.pumpWidget(_app(_soloLectura(proveedor: proveedor)));
      await tester.pump();
      await tester.tap(find.text('Ver mi ubicación'));
      await tester.pumpAndSettle();

      proveedor.error = null;
      await tester.tap(find.text('Ver mi ubicación'));
      await tester.pumpAndSettle();

      expect(find.textContaining('está apagada'), findsNothing);
      expect(find.byKey(_yo), findsOneWidget);
    });
  });

  group('marcador en movimiento', () {
    // Unos 150 m al este: dentro de la vista, la cámara no se mueve.
    const destino = Coordenada(21.1250, -101.6845);

    Mapa chofer(Coordenada p) => _soloLectura(
      enMovimiento: MarcadorEnMovimiento(posicion: p, etiqueta: 'Chofer'),
    );

    testWidgets('lo dibuja y lo nombra', (tester) async {
      await tester.pumpWidget(_app(chofer(_leon)));
      await tester.pump();

      expect(find.byKey(_movil), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Chofer')), findsOneWidget);
    });

    testWidgets('se desliza hasta la posición nueva', (tester) async {
      await tester.pumpWidget(_app(chofer(_leon)));
      await tester.pumpAndSettle();
      final inicio = tester.getCenter(find.byKey(_movil)).dx;

      await tester.pumpWidget(_app(chofer(destino)));
      await tester.pump(const Duration(milliseconds: 60));
      final enCamino = tester.getCenter(find.byKey(_movil)).dx;
      await tester.pumpAndSettle();
      final fin = tester.getCenter(find.byKey(_movil)).dx;

      expect(fin, greaterThan(inicio));
      expect(enCamino, greaterThan(inicio));
      expect(enCamino, lessThan(fin));
    });

    testWidgets('con reducir movimiento salta sin animar', (tester) async {
      await tester.pumpWidget(_app(chofer(_leon), reducirMovimiento: true));
      await tester.pumpAndSettle();
      final inicio = tester.getCenter(find.byKey(_movil)).dx;

      await tester.pumpWidget(_app(chofer(destino), reducirMovimiento: true));
      await tester.pump();
      final alInstante = tester.getCenter(find.byKey(_movil)).dx;
      await tester.pump(const Duration(seconds: 1));

      expect(alInstante, greaterThan(inicio));
      expect(tester.getCenter(find.byKey(_movil)).dx, alInstante);
    });

    testWidgets('si sale de la vista el mapa lo sigue', (tester) async {
      await tester.pumpWidget(_app(chofer(_leon)));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_app(chofer(const Coordenada(21.20, -101.60))));
      await tester.pumpAndSettle();

      final lienzo = tester.getRect(find.byKey(_lienzo));
      expect(lienzo.contains(tester.getCenter(find.byKey(_movil))), isTrue);
    });
  });

  group('accesibilidad', () {
    testWidgets('dice si hay pin', (tester) async {
      await tester.pumpWidget(_app(_soloLectura()));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Mapa sin pin')), findsOneWidget);

      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Mapa con un pin')), findsOneWidget);
    });

    testWidgets('el nombre no dice coordenadas', (tester) async {
      await tester.pumpWidget(_app(_soloLectura(pin: _leon)));
      await tester.pump();

      expect(find.bySemanticsLabel(RegExp('101')), findsNothing);
    });

    testWidgets('la pantalla puede dar su propia descripción', (tester) async {
      await tester.pumpWidget(
        _app(_soloLectura(pin: _leon, descripcion: 'Dónde dejas tu auto')),
      );
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Dónde dejas tu auto')),
        findsOneWidget,
      );
    });

    for (final escenario in Escenario.values) {
      testWidgets('con todos sus controles no desborda ($escenario)', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            Mapa(
              teselas: _teselas,
              fuenteTeselas: TeselasSinConexion(),
              pin: _leon,
              alMoverPin: (_) {},
              miUbicacion: _leon,
              proveedorUbicacion: UbicacionFalsa(),
            ),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  });
}
