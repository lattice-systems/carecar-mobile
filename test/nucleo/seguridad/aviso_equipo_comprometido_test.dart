import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/seguridad/aviso_equipo_comprometido.dart';
import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:carecar_mobile/nucleo/seguridad/proveedores_seguridad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _montar(
  WidgetTester tester,
  PoliticaDatosLocales politica, {
  Brightness brillo = Brightness.light,
  double letra = 1,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  tester.platformDispatcher.textScaleFactorTestValue = letra;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [politicaDatosLocalesProvider.overrideWithValue(politica)],
      child: MaterialApp(
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        locale: const Locale('es'),
        builder: (context, child) => AvisoEquipoComprometido(child: child!),
        home: const Scaffold(body: Text('contenido de la app')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const titulo = 'Este equipo parece modificado';

  testWidgets('equipo integro no muestra aviso', (tester) async {
    await _montar(tester, PoliticaDatosLocales(EstadoIntegridad.integro));
    expect(find.text(titulo), findsNothing);
    expect(find.text('contenido de la app'), findsOneWidget);
  });

  testWidgets('equipo comprometido avisa y no bloquea la app', (tester) async {
    await _montar(tester, PoliticaDatosLocales(EstadoIntegridad.comprometido));
    expect(find.text(titulo), findsOneWidget);
    expect(find.text('contenido de la app'), findsOneWidget);
  });

  testWidgets('se puede cerrar el aviso', (tester) async {
    await _montar(tester, PoliticaDatosLocales(EstadoIntegridad.comprometido));
    await tester.tap(find.byTooltip('Cerrar aviso'));
    await tester.pumpAndSettle();
    expect(find.text(titulo), findsNothing);
    expect(find.text('contenido de la app'), findsOneWidget);
  });

  testWidgets('aparece si la deteccion llega despues', (tester) async {
    final politica = PoliticaDatosLocales();
    await _montar(tester, politica);
    expect(find.text(titulo), findsNothing);
    politica.actualizar(EstadoIntegridad.comprometido);
    await tester.pumpAndSettle();
    expect(find.text(titulo), findsOneWidget);
  });

  for (final brillo in Brightness.values) {
    testWidgets('legible en ${brillo.name} con letra al 200 %', (tester) async {
      await _montar(
        tester,
        PoliticaDatosLocales(EstadoIntegridad.comprometido),
        brillo: brillo,
        letra: 2,
      );
      expect(find.text(titulo), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('contenido de la app'), findsOneWidget);
    });
  }
}
