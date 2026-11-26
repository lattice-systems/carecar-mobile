import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/provisional/mapa_provisional.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_texto.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../ayudas/tema_pista.dart';

const _casa = DireccionGuardada(
  id: 1,
  alias: 'Casa',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  cp: '06600',
  ciudad: 'CDMX',
  ubicacion: Coordenada(21.1250, -101.6860),
);

const _direccionDelPin = Direccion(
  texto: 'Av. Reforma 100, Juárez, 06600 CDMX',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  ciudad: 'Ciudad de México',
  codigoPostal: '06600',
);

/// La pantalla se abre encima de una página «origen», como en la app.
Widget _app(
  RepositorioRecoleccionFake repo, {
  DireccionGuardada? editando,
  UbicacionFalsa? ubicacion,
  GeocodificadorFalso? geocodificador,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioRecoleccionProvider.overrideWithValue(repo),
    configuracionTeselasProvider.overrideWithValue(
      const ConfiguracionTeselas(
        urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
        atribucion: '© Mapas de prueba',
      ),
    ),
    proveedorUbicacionProvider.overrideWithValue(ubicacion ?? UbicacionFalsa()),
    geocodificadorProvider.overrideWithValue(
      geocodificador ?? GeocodificadorFalso(),
    ),
  ],
  child: conTemaPista(
    Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => PantallaDireccion(editando: editando),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    ),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

/// El campo de texto del `CampoTexto` con esa etiqueta.
Finder _campo(String etiqueta) => find.descendant(
  of: find.byWidgetPredicate((w) => w is CampoTexto && w.etiqueta == etiqueta),
  matching: find.byType(TextField),
);

Future<void> _abrir(WidgetTester tester) async {
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> _ponerPinEnElMapa(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(find.byType(MapaProvisional)));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> _escribir(
  WidgetTester tester,
  String etiqueta,
  String texto,
) async {
  final campo = _campo(etiqueta);
  await tester.enterText(campo, texto);
  await tester.pump();
}

Future<void> _llenar(WidgetTester tester) async {
  await _escribir(tester, 'Nombre', 'Casa');
  await _escribir(tester, 'Calle y número', 'Av. Reforma 100');
  await _escribir(tester, 'Colonia', 'Juárez');
  await _escribir(tester, 'Código postal', '06600');
  await _escribir(tester, 'Ciudad', 'CDMX');
}

Future<void> _guardar(WidgetTester tester) async {
  final boton = find.text('Guardar dirección');
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  _prueba('guardar sin llenar marca cada campo y no guarda', (tester) async {
    final repo = RepositorioRecoleccionFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);

    await _guardar(tester);

    expect(
      find.text('Escribe un nombre de hasta 40 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('El código postal tiene 5 dígitos.'), findsOneWidget);
    expect(find.text('Pon el pin en el mapa.'), findsOneWidget);
    expect(await repo.direcciones(), isEmpty);
    expect(find.byType(PantallaDireccion), findsOneWidget);
  });

  _prueba('con todo lleno y el pin guarda y vuelve', (tester) async {
    final repo = RepositorioRecoleccionFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);
    await _llenar(tester);
    await _ponerPinEnElMapa(tester);

    await _guardar(tester);

    final guardadas = await repo.direcciones();
    expect(guardadas.single.alias, 'Casa');
    expect(guardadas.single.cp, '06600');
    expect(find.byType(PantallaDireccion), findsNothing);
  });

  _prueba('el código postal solo acepta cinco dígitos', (tester) async {
    await tester.pumpWidget(_app(RepositorioRecoleccionFake()));
    await _abrir(tester);
    await _escribir(tester, 'Código postal', '06a6009999');
    final campo = tester.widget<TextField>(_campo('Código postal'));
    expect(campo.controller!.text, '06600');
  });

  _prueba('un pin fuera de cobertura avisa y no guarda', (tester) async {
    final repo = RepositorioRecoleccionFake();
    await tester.pumpWidget(
      _app(
        repo,
        ubicacion: UbicacionFalsa(posicion: const Coordenada(25.67, -100.31)),
      ),
    );
    await _abrir(tester);
    await _llenar(tester);
    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    await _guardar(tester);

    expect(find.text('Fuera de cobertura'), findsOneWidget);
    expect(find.textContaining('Todavía no recogemos autos'), findsOneWidget);
    expect(await repo.direcciones(), isEmpty);
    expect(find.byType(PantallaDireccion), findsOneWidget);
  });

  _prueba('un pin en la Ciudad de México queda fuera de los 15 km de León', (
    tester,
  ) async {
    final repo = RepositorioRecoleccionFake();
    await tester.pumpWidget(
      _app(
        repo,
        ubicacion: UbicacionFalsa(
          posicion: const Coordenada(19.4326, -99.1332),
        ),
      ),
    );
    await _abrir(tester);
    await _llenar(tester);
    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    await _guardar(tester);

    expect(find.text('Fuera de cobertura'), findsOneWidget);
    expect(find.textContaining('Todavía no recogemos autos'), findsOneWidget);
    expect(await repo.direcciones(), isEmpty);
  });

  _prueba('Usar mi ubicación pone el pin y completa los campos vacíos', (
    tester,
  ) async {
    const punto = Coordenada(21.1250, -101.6860);
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(),
        ubicacion: UbicacionFalsa(posicion: punto),
        geocodificador: GeocodificadorFalso(
          direccionesPorCoordenada: {punto: _direccionDelPin},
        ),
      ),
    );
    await _abrir(tester);
    await _escribir(tester, 'Colonia', 'Mi colonia');

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    final calle = tester.widget<TextField>(_campo('Calle y número'));
    final colonia = tester.widget<TextField>(_campo('Colonia'));
    expect(calle.controller!.text, 'Av. Reforma 100');
    expect(
      colonia.controller!.text,
      'Mi colonia',
      reason: 'no se pisa lo escrito',
    );
    expect(find.byIcon(LucideIcons300.mapPin), findsOneWidget);
  });

  _prueba('sin permiso de ubicación lo explica y deja poner el pin a mano', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(),
        ubicacion: UbicacionFalsa(error: const UbicacionPermisoDenegado()),
      ),
    );
    await _abrir(tester);
    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Necesitamos tu permiso'), findsOneWidget);
    expect(find.byIcon(LucideIcons300.mapPin), findsNothing);

    await _ponerPinEnElMapa(tester);
    expect(find.byIcon(LucideIcons300.mapPin), findsOneWidget);
  });

  _prueba('con la ubicación apagada lo avisa', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(),
        ubicacion: UbicacionFalsa(error: const UbicacionServicioApagado()),
      ),
    );
    await _abrir(tester);
    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Activa la ubicación'), findsOneWidget);
  });

  _prueba('buscar una dirección pone el pin y autocompleta', (tester) async {
    const punto = Coordenada(21.1250, -101.6860);
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(),
        geocodificador: GeocodificadorFalso(
          coordenadasPorDireccion: const {'Reforma 100': punto},
          direccionesPorCoordenada: {punto: _direccionDelPin},
        ),
      ),
    );
    await _abrir(tester);
    await _escribir(tester, 'Buscar dirección', 'Reforma 100');
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons300.mapPin), findsOneWidget);
    final cp = tester.widget<TextField>(_campo('Código postal'));
    expect(cp.controller!.text, '06600');
  });

  _prueba('buscar sin resultados lo dice', (tester) async {
    await tester.pumpWidget(_app(RepositorioRecoleccionFake()));
    await _abrir(tester);
    await _escribir(tester, 'Buscar dirección', 'Ninguna parte');
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No encontramos esa dirección'), findsOneWidget);
  });

  _prueba('si falla el geocodificador la búsqueda avisa', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioRecoleccionFake(),
        geocodificador: GeocodificadorFalso(
          error: const ErrorGeocodificacion('sin red'),
        ),
      ),
    );
    await _abrir(tester);
    await _escribir(tester, 'Buscar dirección', 'Reforma 100');
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pudimos buscar'), findsOneWidget);
  });

  _prueba('sin conexión al guardar lo avisa y conserva lo escrito', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(error: const SinConexion())),
    );
    await _abrir(tester);
    await _llenar(tester);
    await _ponerPinEnElMapa(tester);

    await _guardar(tester);

    expect(find.textContaining('Sin conexión'), findsOneWidget);
    expect(find.byType(Aviso), findsOneWidget);
    expect(find.text('Av. Reforma 100'), findsOneWidget);
  });

  _prueba('editar muestra los datos y guarda los cambios', (tester) async {
    final repo = RepositorioRecoleccionFake(direcciones: const [_casa]);
    await tester.pumpWidget(_app(repo, editando: _casa));
    await _abrir(tester);
    expect(find.text('Editar dirección'), findsWidgets);
    await _escribir(tester, 'Nombre', 'Casa de mamá');

    await _guardar(tester);

    expect((await repo.direcciones()).single.alias, 'Casa de mamá');
  });

  _prueba('borrar pide confirmación y borra', (tester) async {
    final repo = RepositorioRecoleccionFake(direcciones: const [_casa]);
    await tester.pumpWidget(_app(repo, editando: _casa));
    await _abrir(tester);

    await tester.tap(find.text('Borrar dirección'));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar esta dirección?'), findsOneWidget);
    expect(await repo.direcciones(), hasLength(1));

    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    expect(await repo.direcciones(), isEmpty);
    expect(find.byType(PantallaDireccion), findsNothing);
    expect(find.text('Dirección borrada'), findsOneWidget);
  });

  _prueba('cancelar el borrado no borra', (tester) async {
    final repo = RepositorioRecoleccionFake(direcciones: const [_casa]);
    await tester.pumpWidget(_app(repo, editando: _casa));
    await _abrir(tester);
    await tester.tap(find.text('Borrar dirección'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await repo.direcciones(), hasLength(1));
    expect(find.byType(PantallaDireccion), findsOneWidget);
  });

  _prueba('borrar una dirección en uso explica el 409', (tester) async {
    final repo = RepositorioRecoleccionFake(
      direcciones: const [_casa],
      idsEnUso: const {1},
    );
    await tester.pumpWidget(_app(repo, editando: _casa));
    await _abrir(tester);
    await tester.tap(find.text('Borrar dirección'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ya tiene recolecciones'), findsOneWidget);
    expect(await repo.direcciones(), hasLength(1));
    expect(find.byType(PantallaDireccion), findsOneWidget);
  });

  for (final e in Escenario.values) {
    _prueba('se ve sin desbordar ($e)', (tester) async {
      await tester.pumpWidget(
        _app(
          RepositorioRecoleccionFake(direcciones: const [_casa]),
          editando: _casa,
          escenario: e,
        ),
      );
      await _abrir(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
