import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/pantalla_seguimiento_traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/proveedores_recoleccion.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/provisional/mapa_provisional.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/rutas_recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/linea_de_tiempo.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

TrasladoDetalle _traslado({
  EstadoTraslado estado = EstadoTraslado.programado,
  String tipo = 'recoger',
  bool conChofer = false,
}) => TrasladoDetalle(
  id: 5,
  citaId: 9,
  tipo: tipo,
  estado: estado,
  costo: 150,
  fecha: DateTime(2026, 12),
  ventanaInicio: '07:00',
  ventanaFin: '09:00',
  ubicacionChofer: conChofer
      ? UbicacionChofer(
          lat: 19.43,
          lng: -99.13,
          actualizadaEn: DateTime.utc(2026, 12, 1, 13, 5),
        )
      : null,
);

Future<(EventosEnVivoFake, RepositorioRecoleccionFake)> _montar(
  WidgetTester tester, {
  RepositorioRecoleccionFake? repo,
  Brightness brillo = Brightness.light,
  Size tamano = const Size(800, 1800),
  double escala = 1,
  bool esperar = true,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final canal = EventosEnVivoFake();
  final fake = repo ?? RepositorioRecoleccionFake(traslados: [_traslado()]);
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const PantallaSeguimientoTraslado(trasladoId: 5),
      ),
      GoRoute(
        path: rutaChecklistTraslado(5),
        builder: (_, _) => const Scaffold(body: Text('checklist abierto')),
      ),
    ],
  );
  addTearDown(enrutador.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventosEnVivoProvider.overrideWithValue(canal),
        repositorioRecoleccionProvider.overrideWithValue(fake),
        configuracionTeselasProvider.overrideWithValue(
          const ConfiguracionTeselas(
            urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
            atribucion: '© Mapas de prueba',
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: enrutador,
        theme: brillo == Brightness.dark
            ? TemaPista.oscuro()
            : TemaPista.claro(),
        locale: const Locale('es'),
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(escala),
            disableAnimations: true,
          ),
          child: child!,
        ),
      ),
    ),
  );
  if (esperar) {
    await tester.pumpAndSettle();
  }
  return (canal, fake);
}

void main() {
  testWidgets('muestra los seis pasos del traslado de recoger', (tester) async {
    await _montar(tester);

    expect(find.byType(LineaDeTiempo), findsOneWidget);
    expect(find.text('Recogemos tu auto'), findsWidgets);
    for (final texto in [
      'Programado',
      'Chofer en camino',
      'Auto recogido',
      'En el taller',
      'De regreso a tu domicilio',
      'Auto entregado',
    ]) {
      expect(find.text(texto), findsWidgets, reason: texto);
    }
    expect(find.byType(MapaProvisional), findsNothing);
  });

  testWidgets('un traslado de entregar lo dice en el titulo', (tester) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [_traslado(tipo: 'entregar')],
      ),
    );

    expect(find.text('Entregamos tu auto'), findsWidgets);
  });

  testWidgets('en camino con ubicacion muestra el mapa del chofer', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [
          _traslado(estado: EstadoTraslado.enCamino, conChofer: true),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(MapaProvisional), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping), findsOneWidget);
    expect(find.text('Dónde va el chofer'), findsOneWidget);
    expect(find.textContaining('Ubicación actualizada a las'), findsOneWidget);
  });

  testWidgets('recogido no muestra el mapa aunque haya ubicacion vieja', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [
          _traslado(estado: EstadoTraslado.recogido, conChofer: true),
        ],
      ),
    );

    expect(find.byType(MapaProvisional), findsNothing);
  });

  testWidgets('los eventos mueven el estado y el chofer sin recargar', (
    tester,
  ) async {
    final (canal, _) = await _montar(tester);
    expect(find.byType(MapaProvisional), findsNothing);

    canal.emitir('traslado.estado', {'trasladoId': 5, 'estado': 'en_camino'});
    canal.emitir('traslado.ubicacion', {
      'trasladoId': 5,
      'lat': 19.5,
      'lng': -99.2,
      'actualizadaEn': '2026-12-01T13:10:00Z',
    });
    await tester.pump();
    await tester.pump();

    expect(find.byType(MapaProvisional), findsOneWidget);

    canal.emitir('traslado.estado', {'trasladoId': 5, 'estado': 'recogido'});
    await tester.pump();
    await tester.pump();

    expect(find.byType(MapaProvisional), findsNothing);
  });

  testWidgets('un traslado cancelado cierra la linea en Cancelado', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [_traslado(estado: EstadoTraslado.cancelado)],
      ),
    );

    expect(find.text('Cancelado'), findsWidgets);
    expect(find.text('Auto entregado'), findsNothing);
    expect(find.text('Ver checklist del auto'), findsNothing);
  });

  testWidgets('Ver checklist abre el checklist del traslado', (tester) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [_traslado(estado: EstadoTraslado.recogido)],
      ),
    );

    await tester.ensureVisible(find.text('Ver checklist del auto'));
    await tester.tap(find.text('Ver checklist del auto'));
    await tester.pumpAndSettle();

    expect(find.text('checklist abierto'), findsOneWidget);
  });

  testWidgets('programado no ofrece checklist todavia', (tester) async {
    await _montar(tester);

    expect(find.text('Ver checklist del auto'), findsNothing);
  });

  testWidgets('Actualizar consulta de nuevo el traslado', (tester) async {
    final repo = RepositorioRecoleccionFake(traslados: [_traslado()]);
    await _montar(tester, repo: repo);
    repo.traslados[5] = _traslado(estado: EstadoTraslado.enTaller);

    await tester.ensureVisible(find.text('Actualizar'));
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();

    expect(repo.consultasTraslado, 2);
    expect(find.text('En el taller'), findsWidgets);
  });

  testWidgets('cargando muestra un esqueleto anunciado', (tester) async {
    final espera = Completer<void>();
    final manejador = tester.ensureSemantics();
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [_traslado()],
        espera: espera.future,
      ),
      esperar: false,
    );
    await tester.pump();

    expect(
      find.bySemanticsLabel('Cargando el seguimiento del traslado'),
      findsOneWidget,
    );
    espera.complete();
    await tester.pumpAndSettle();
    manejador.dispose();
  });

  testWidgets('un traslado que no existe lo explica', (tester) async {
    await _montar(tester, repo: RepositorioRecoleccionFake());

    expect(find.text('No encontramos este traslado'), findsOneWidget);
  });

  testWidgets('sin conexion ofrece reintentar y recupera', (tester) async {
    var falla = true;
    final repo = _RepoIntermitente(
      _traslado(),
      () => falla ? const SinConexion() : null,
    );
    await _montar(tester, repo: repo);

    expect(find.text('Reintentar'), findsOneWidget);
    falla = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Recogemos tu auto'), findsWidgets);
  });

  testWidgets('abre el canal solo con la pantalla puesta', (tester) async {
    final (canal, _) = await _montar(tester);
    expect(canal.escuchas, 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    expect(canal.escuchas, 0);
  });

  testWidgets('aguanta letra al 200 % en pantalla chica y en oscuro', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        traslados: [
          _traslado(estado: EstadoTraslado.enCamino, conChofer: true),
        ],
      ),
      brillo: Brightness.dark,
      tamano: const Size(320, 568),
      escala: 2,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(LineaDeTiempo), findsOneWidget);
  });

  testWidgets('el titulo no queda tapado al desplazar', (tester) async {
    await _montar(tester, tamano: const Size(360, 480));

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    final barra = tester
        .widget<Material>(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byType(Material),
          ),
        )
        .color!;
    expect(barra.a, 1);
  });
}

class _RepoIntermitente extends RepositorioRecoleccionFake {
  _RepoIntermitente(this._traslado, this._error)
    : super(traslados: [_traslado]);

  final TrasladoDetalle _traslado;
  final Object? Function() _error;

  @override
  Future<TrasladoDetalle> traslado(int id) async {
    final error = _error();
    if (error != null) throw error;
    return _traslado;
  }
}
