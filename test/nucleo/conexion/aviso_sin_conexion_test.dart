import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/conexion/aviso_sin_conexion.dart';
import 'package:carecar_mobile/nucleo/conexion/senal_de_conexion.dart';
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

/// V2-M21.04 · el aviso discreto de que la agencia no contesta.
void main() {
  final aviso = find.byKey(const Key('aviso_sin_conexion'));

  Future<SenalDeConexion> montar(
    WidgetTester tester, {
    double letra = 1,
    Brightness brillo = Brightness.light,
  }) async {
    tester.platformDispatcher.platformBrightnessTestValue = brillo;
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final senal = SenalDeConexion();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [senalDeConexionProvider.overrideWithValue(senal)],
        child: MaterialApp(
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          locale: const Locale('es'),
          home: const AvisoSinConexion(child: _Contador()),
        ),
      ),
    );
    return senal;
  }

  testWidgets('en línea no se ve nada', (tester) async {
    await montar(tester);
    expect(aviso, findsNothing);
    expect(find.text('contenido de la app 0'), findsOneWidget);
  });

  testWidgets('sin conexión aparece, y se va con la siguiente respuesta', (
    tester,
  ) async {
    final senal = await montar(tester);

    senal.fallo(const SinConexion(null));
    await tester.pumpAndSettle();
    expect(aviso, findsOneWidget);

    senal.acerto();
    await tester.pumpAndSettle();
    expect(aviso, findsNothing);
  });

  testWidgets('el contenido no pierde su estado al aparecer el aviso', (
    tester,
  ) async {
    final senal = await montar(tester);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text('contenido de la app 1'), findsOneWidget);

    senal.fallo(const SinConexion(null));
    await tester.pumpAndSettle();

    // Es la razón de que el aviso sea un hijo más de la columna y no un
    // envoltorio: si reiniciara la pantalla, perder la red perdería lo que la
    // persona llevaba escrito.
    expect(find.text('contenido de la app 1'), findsOneWidget);
  });

  testWidgets('con letra al 200 % cabe y no desborda', (tester) async {
    final senal = await montar(tester, letra: 2);
    senal.fallo(const SinConexion(null));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(aviso, findsOneWidget);
  });

  testWidgets('en oscuro también se ve', (tester) async {
    final senal = await montar(tester, brillo: Brightness.dark);
    senal.fallo(const SinConexion(null));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(aviso, findsOneWidget);
  });
}
