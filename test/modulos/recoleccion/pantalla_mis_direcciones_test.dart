import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/direccion_guardada.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
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

const _oficina = DireccionGuardada(
  id: 2,
  alias: 'Oficina',
  calle: 'Insurgentes 1',
  colonia: 'Roma',
  cp: '06700',
  ciudad: 'CDMX',
  ubicacion: Coordenada(19.42, -99.16),
);

Widget _app(
  RepositorioRecoleccionFake repo, {
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
    geocodificadorProvider.overrideWithValue(GeocodificadorFalso()),
  ],
  child: conTemaPista(const PantallaMisDirecciones(), escenario: escenario),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

void main() {
  _prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioRecoleccionFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(find.bySemanticsLabel('Cargando tus direcciones'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  _prueba('sin direcciones explica y ofrece agregar', (tester) async {
    await tester.pumpWidget(_app(RepositorioRecoleccionFake()));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes direcciones'), findsOneWidget);
    expect(find.text('Agregar dirección'), findsOneWidget);
  });

  _prueba('lista el alias y la dirección de cada una', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(direcciones: const [_casa, _oficina])),
    );
    await tester.pumpAndSettle();
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Av. Reforma 100, Juárez, 06600 CDMX'), findsOneWidget);
    expect(find.text('Oficina'), findsOneWidget);
  });

  _prueba('un error de red muestra sin conexión y reintenta', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(
      tester.widget<EstadoError>(find.byType(EstadoError)).causa,
      CausaError.sinConexion,
    );
  });

  _prueba('un error del servidor muestra el error genérico', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(error: const ErrorDelServidor('x'))),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<EstadoError>(find.byType(EstadoError)).causa,
      CausaError.generico,
    );
  });

  _prueba('Agregar dirección abre el formulario de alta', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(direcciones: const [_casa])),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar dirección'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDireccion), findsOneWidget);
    expect(find.text('Nueva dirección'), findsWidgets);
  });

  _prueba('tocar una dirección abre su edición con los datos', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioRecoleccionFake(direcciones: const [_casa])),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    expect(find.text('Editar dirección'), findsWidgets);
    expect(find.text('Av. Reforma 100'), findsOneWidget);
    expect(find.text('Borrar dirección'), findsOneWidget);
  });

  for (final e in Escenario.values) {
    _prueba('se ve sin desbordar con datos ($e)', (tester) async {
      await tester.pumpWidget(
        _app(
          RepositorioRecoleccionFake(direcciones: const [_casa, _oficina]),
          escenario: e,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Casa'), findsOneWidget);
    });

    _prueba('se ve sin desbordar vacía ($e)', (tester) async {
      await tester.pumpWidget(_app(RepositorioRecoleccionFake(), escenario: e));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
