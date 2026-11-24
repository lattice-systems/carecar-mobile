import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

const _casa = DireccionGuardada(
  id: 1,
  alias: 'Casa',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  cp: '06600',
  ciudad: 'CDMX',
  ubicacion: Coordenada(19.4326, -99.1332),
);

const _lejos = DireccionGuardada(
  id: 2,
  alias: 'Monterrey',
  calle: 'Calle 1',
  colonia: 'Centro',
  cp: '64000',
  ciudad: 'Monterrey',
  ubicacion: Coordenada(25.67, -100.31),
);

/// Anfitrión con el estado que el flujo de agendar guardaría.
class _Anfitrion extends StatefulWidget {
  const _Anfitrion({this.fecha, this.pedidaAlInicio = false});

  final DateTime? fecha;
  final bool pedidaAlInicio;

  @override
  State<_Anfitrion> createState() => _EstadoAnfitrion();
}

class _EstadoAnfitrion extends State<_Anfitrion> {
  late bool _pedida = widget.pedidaAlInicio;
  int? _direccion;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: SeleccionRecoleccion(
      pedida: _pedida,
      direccionId: _direccion,
      fecha: widget.fecha,
      alCambiarPedida: (v) => setState(() => _pedida = v),
      alElegirDireccion: (id) => setState(() => _direccion = id),
    ),
  );
}

Widget _app(
  RepositorioRecoleccionFake repo, {
  DateTime? fecha,
  bool pedida = false,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [repositorioRecoleccionProvider.overrideWithValue(repo)],
  child: conTemaPista(
    _Anfitrion(fecha: fecha, pedidaAlInicio: pedida),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

final _dia = DateTime(2026, 11, 26);

void main() {
  _prueba('por omisión lo llevo yo y no se pide nada al servidor', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo llega tu auto al taller?'), findsOneWidget);
    expect(find.text('Lo llevo yo'), findsOneWidget);
    expect(find.text('Que recojan mi auto'), findsOneWidget);
    expect(find.text('Casa'), findsNothing);
    expect(find.byType(Esqueleto), findsNothing);
  });

  _prueba('Que recojan mi auto lista las direcciones guardadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(direcciones: const [_casa])),
    );
    await tester.tap(find.text('Que recojan mi auto'));
    await tester.pumpAndSettle();
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Administrar mis direcciones'), findsOneWidget);
    expect(find.text('Elige una dirección para ver el costo.'), findsOneWidget);
  });

  _prueba('sin direcciones ofrece agregar una', (tester) async {
    await tester.pumpWidget(_app(RepositorioRecoleccionFake(), pedida: true));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes direcciones guardadas.'), findsOneWidget);
    expect(find.text('Agregar dirección'), findsOneWidget);
  });

  _prueba('con dirección pero sin día pide elegir día y horario', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(direcciones: const [_casa]),
        pedida: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    expect(
      find.text('Elige día y horario para cotizar la recolección.'),
      findsOneWidget,
    );
  });

  _prueba('elegida la dirección muestra costo y franjas', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(
          direcciones: const [_casa],
          costoPorTraslado: 150,
        ),
        fecha: _dia,
        pedida: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();

    expect(find.text('Costo y horario'), findsOneWidget);
    expect(
      find.text('jueves, 26 de noviembre, de 07:00 a 09:00'),
      findsOneWidget,
    );
    expect(
      find.text('jueves, 26 de noviembre, de 17:00 a 19:00'),
      findsOneWidget,
    );
    expect(find.text(r'$150.00'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
    expect(find.textContaining('Elegida · Av. Reforma 100'), findsOneWidget);
  });

  _prueba('mientras cotiza muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(direcciones: const [_casa]),
        fecha: _dia,
        pedida: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pump();
    expect(
      find.bySemanticsLabel('Calculando el costo de la recolección'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  _prueba('una dirección fuera de cobertura lo avisa en vez del costo', (
    tester,
  ) async {
    // El fake la guarda porque el borrador original se creó dentro de la zona;
    // se siembra directamente para simular que la cobertura cambió.
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(direcciones: const [_lejos]),
        fecha: _dia,
        pedida: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monterrey'));
    await tester.pumpAndSettle();
    expect(find.text('Fuera de cobertura'), findsOneWidget);
    expect(find.text('Costo y horario'), findsNothing);
  });

  _prueba('si falla la cotización por red ofrece reintentar', (tester) async {
    final repo = _RepoQueFallaAlCotizar(const [_casa]);
    await tester.pumpWidget(_app(repo, fecha: _dia, pedida: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    expect(find.text('No pudimos cotizar la recolección'), findsOneWidget);

    repo.falla = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Costo y horario'), findsOneWidget);
  });

  _prueba('volver a Lo llevo yo oculta direcciones y costo', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(direcciones: const [_casa]),
        fecha: _dia,
        pedida: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lo llevo yo'));
    await tester.pumpAndSettle();
    expect(find.text('Casa'), findsNothing);
  });

  for (final e in Escenario.values) {
    _prueba('se ve sin desbordar con costo ($e)', (tester) async {
      await tester.pumpWidget(
        _app(
          RepositorioRecoleccionFake(direcciones: const [_casa]),
          fecha: _dia,
          pedida: true,
          escenario: e,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Casa'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

class _RepoQueFallaAlCotizar extends RepositorioRecoleccionFake {
  _RepoQueFallaAlCotizar(List<DireccionGuardada> direcciones)
    : super(direcciones: direcciones);

  bool falla = true;

  @override
  Future<CotizacionRecoleccion> cotizar({
    required int direccionId,
    required DateTime fecha,
  }) {
    if (falla) throw const SinConexion();
    return super.cotizar(direccionId: direccionId, fecha: fecha);
  }
}
