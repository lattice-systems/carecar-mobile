import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/widgets/widgets.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Puerto falso: guarda lo que se instalo y deja "tocar" un atajo a mano.
class _PuertoFalso implements PuertoAccesosRapidos {
  void Function(AccesoRapido)? alElegirAcceso;
  final instalaciones = <List<AtajoDeIcono>>[];
  Object? fallo;

  @override
  void alElegir(void Function(AccesoRapido acceso) callback) {
    alElegirAcceso = callback;
  }

  @override
  Future<void> instalar(List<AtajoDeIcono> atajos) async {
    if (fallo != null) throw fallo!;
    instalaciones.add(atajos);
  }
}

GoRouter _enrutador() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
    GoRoute(path: '/citas/agendar', builder: (_, _) => const Text('agendar')),
    GoRoute(path: '/garaje', builder: (_, _) => const Text('garaje')),
    GoRoute(path: '/asistencia/guias', builder: (_, _) => const Text('guias')),
  ],
);

Future<GoRouter> _montar(
  WidgetTester tester,
  _PuertoFalso puerto, {
  Locale idioma = const Locale('es'),
}) async {
  tester.platformDispatcher.localesTestValue = [idioma];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final enrutador = _enrutador();
  addTearDown(enrutador.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        puertoAccesosRapidosProvider.overrideWithValue(puerto),
        enrutadorProvider.overrideWithValue(enrutador),
      ],
      child: MaterialApp.router(
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        localeResolutionCallback: resolverIdioma,
        routerConfig: enrutador,
        builder: (context, child) => InstaladorDeAccesosRapidos(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return enrutador;
}

void main() {
  testWidgets('instala Agendar, Mi auto y SOS con titulos en espanol', (
    tester,
  ) async {
    final puerto = _PuertoFalso();
    await _montar(tester, puerto);
    expect(puerto.instalaciones, isNotEmpty);
    final atajos = puerto.instalaciones.last;
    expect(atajos.map((a) => a.acceso), AccesoRapido.values);
    expect(atajos.map((a) => a.titulo), ['Agendar cita', 'Mi auto', 'SOS']);
  });

  testWidgets('los titulos siguen al idioma del sistema', (tester) async {
    final puerto = _PuertoFalso();
    await _montar(tester, puerto, idioma: const Locale('en'));
    expect(puerto.instalaciones.last.map((a) => a.titulo), [
      'Book appointment',
      'My car',
      'SOS',
    ]);
  });

  testWidgets('tocar Agendar abre la agenda de citas', (tester) async {
    final puerto = _PuertoFalso();
    final enrutador = await _montar(tester, puerto);
    puerto.alElegirAcceso!(AccesoRapido.agendar);
    await tester.pumpAndSettle();
    expect(enrutador.routeInformationProvider.value.uri.path, '/citas/agendar');
    expect(find.text('agendar'), findsOneWidget);
  });

  testWidgets('tocar Mi auto abre el garaje', (tester) async {
    final puerto = _PuertoFalso();
    await _montar(tester, puerto);
    puerto.alElegirAcceso!(AccesoRapido.miAuto);
    await tester.pumpAndSettle();
    expect(find.text('garaje'), findsOneWidget);
  });

  testWidgets('tocar SOS abre la asistencia', (tester) async {
    final puerto = _PuertoFalso();
    await _montar(tester, puerto);
    puerto.alElegirAcceso!(AccesoRapido.sos);
    await tester.pumpAndSettle();
    expect(find.text('guias'), findsOneWidget);
  });

  testWidgets('si el sistema no deja instalar atajos la app sigue igual', (
    tester,
  ) async {
    final puerto = _PuertoFalso()..fallo = StateError('sin atajos');
    await _montar(tester, puerto);
    expect(tester.takeException(), isNull);
    expect(find.text('inicio'), findsOneWidget);
  });
}
