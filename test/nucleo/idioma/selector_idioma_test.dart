import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/nucleo/idioma/selector_idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ayudas/tema_pista.dart';

/// Una app minima que sigue el idioma elegido, como hace `main.dart`.
Widget _app(ProviderContainer contenedor) => UncontrolledProviderScope(
  container: contenedor,
  child: Consumer(
    builder: (context, ref, _) => MaterialApp(
      theme: TemaPista.claro(),
      locale: ref.watch(idiomaElegidoProvider),
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      localeResolutionCallback: resolverIdioma,
      home: const Scaffold(body: SelectorIdioma()),
    ),
  ),
);

Future<ProviderContainer> _contenedor(Map<String, Object> guardado) async {
  SharedPreferences.setMockInitialValues(guardado);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [preferenciasProvider.overrideWithValue(prefs)],
  );
}

void main() {
  testWidgets('sin eleccion sigue el idioma del sistema', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'MX')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final c = await _contenedor({});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));
    expect(c.read(idiomaElegidoProvider), isNull);
    expect(find.text('Automático (idioma del sistema)'), findsOneWidget);
  });

  testWidgets('con el sistema en ingles la app sale en ingles', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final c = await _contenedor({});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('con un idioma del sistema que no traducimos sale en espanol', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final c = await _contenedor({});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));
    expect(find.text('Idioma'), findsOneWidget);
  });

  testWidgets('elegir English cambia la app al instante y se recuerda', (
    tester,
  ) async {
    final c = await _contenedor({});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(c.read(idiomaElegidoProvider), const Locale('en'));
    expect(find.text('Language'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(claveIdiomaElegido), 'en');
  });

  testWidgets('la eleccion guardada se aplica al abrir la app', (tester) async {
    final c = await _contenedor({claveIdiomaElegido: 'en'});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));
    expect(c.read(idiomaElegidoProvider), const Locale('en'));
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('volver a automatico borra la eleccion', (tester) async {
    final c = await _contenedor({claveIdiomaElegido: 'en'});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Automatic (system language)').last);
    await tester.pumpAndSettle();

    expect(c.read(idiomaElegidoProvider), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(claveIdiomaElegido), isFalse);
  });

  testWidgets('un idioma guardado que ya no existe se ignora', (tester) async {
    final c = await _contenedor({claveIdiomaElegido: 'fr'});
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));
    expect(c.read(idiomaElegidoProvider), isNull);
  });

  testWidgets('el selector se ve en claro, oscuro y letra grande', (
    tester,
  ) async {
    for (final e in Escenario.values) {
      await tester.pumpWidget(
        ProviderScope(
          child: conTemaPista(const SelectorIdioma(), escenario: e),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Idioma'), findsOneWidget);
    }
  });
}
