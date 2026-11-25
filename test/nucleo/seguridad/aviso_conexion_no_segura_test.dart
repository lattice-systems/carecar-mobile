import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/seguridad/aviso_conexion_no_segura.dart';
import 'package:carecar_mobile/nucleo/seguridad/estado_de_conexion_segura.dart';
import 'package:carecar_mobile/nucleo/seguridad/proveedores_seguridad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contenido con estado propio, para comprobar que el aviso no lo reinicia.
class _Contador extends StatefulWidget {
  const _Contador();

  @override
  State<_Contador> createState() => _ContadorState();
}

class _ContadorState extends State<_Contador> {
  int _veces = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => _veces++),
    child: Text('contenido de la app $_veces'),
  );
}

Future<void> _montar(
  WidgetTester tester,
  EstadoDeConexionSegura estado, {
  String idioma = 'es',
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
      overrides: [estadoConexionSeguraProvider.overrideWithValue(estado)],
      child: MaterialApp(
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        locale: Locale(idioma),
        builder: (context, child) => AvisoConexionNoSegura(child: child!),
        home: const Scaffold(body: Center(child: _Contador())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const titulo = 'No pudimos verificar que la conexión sea segura';
  late EstadoDeConexionSegura estado;

  setUp(() => estado = EstadoDeConexionSegura());
  tearDown(() => estado.dispose());

  group('AvisoConexionNoSegura (V2-M22.15)', () {
    testWidgets('sin problema no muestra aviso', (tester) async {
      await _montar(tester, estado);

      expect(find.text(titulo), findsNothing);
      expect(find.text('contenido de la app 0'), findsOneWidget);
    });

    testWidgets('un certificado rechazado avisa y no bloquea la app', (
      tester,
    ) async {
      await _montar(tester, estado);

      estado.actualizar(false);
      await tester.pumpAndSettle();

      expect(find.text(titulo), findsOneWidget);
      expect(find.textContaining('datos móviles'), findsOneWidget);
      expect(find.text('contenido de la app 0'), findsOneWidget);
    });

    testWidgets('se quita cuando una respuesta vuelve a validar', (
      tester,
    ) async {
      await _montar(tester, estado);
      estado.actualizar(false);
      await tester.pumpAndSettle();

      estado.actualizar(true);
      await tester.pumpAndSettle();

      expect(find.text(titulo), findsNothing);
    });

    testWidgets('el contenido conserva su estado al aparecer y quitarse', (
      tester,
    ) async {
      // Sin el Navigator de MaterialApp.builder, que ya se protege solo con una
      // llave global: aquí el contenido no tiene ninguna que lo salve.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [estadoConexionSeguraProvider.overrideWithValue(estado)],
          child: MaterialApp(
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            locale: const Locale('es'),
            home: const AvisoConexionNoSegura(
              child: Scaffold(body: Center(child: _Contador())),
            ),
          ),
        ),
      );
      await tester.tap(find.text('contenido de la app 0'));
      await tester.pump();
      expect(find.text('contenido de la app 1'), findsOneWidget);

      estado.actualizar(false);
      await tester.pumpAndSettle();
      expect(find.text('contenido de la app 1'), findsOneWidget);

      estado.actualizar(true);
      await tester.pumpAndSettle();
      expect(find.text('contenido de la app 1'), findsOneWidget);
    });

    testWidgets('el contenido no repite el margen de la barra de estado', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.view.padding = const FakeViewPadding(top: 40);
      addTearDown(tester.view.resetPadding);
      double? margen;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [estadoConexionSeguraProvider.overrideWithValue(estado)],
          child: MaterialApp(
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            locale: const Locale('es'),
            builder: (context, child) => AvisoConexionNoSegura(child: child!),
            home: Builder(
              builder: (context) {
                margen = MediaQuery.paddingOf(context).top;
                return const Scaffold(body: Text('contenido de la app'));
              },
            ),
          ),
        ),
      );
      expect(margen, 40, reason: 'sin aviso, la app ve el margen del sistema');

      estado.actualizar(false);
      await tester.pumpAndSettle();

      expect(margen, 0, reason: 'el aviso ya cubrió la barra de estado');
    });

    testWidgets('se anuncia al lector de pantalla', (tester) async {
      await _montar(tester, estado);
      estado.actualizar(false);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.liveRegion == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('en inglés', (tester) async {
      await _montar(tester, estado, idioma: 'en');
      estado.actualizar(false);
      await tester.pumpAndSettle();

      expect(
        find.text('We could not verify that the connection is secure'),
        findsOneWidget,
      );
      expect(find.text(titulo), findsNothing);
    });

    testWidgets('con letra grande y modo oscuro no desborda', (tester) async {
      await _montar(tester, estado, brillo: Brightness.dark, letra: 2);
      estado.actualizar(false);
      await tester.pumpAndSettle();

      expect(find.text(titulo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
