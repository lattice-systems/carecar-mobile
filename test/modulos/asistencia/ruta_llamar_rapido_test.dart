import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<List<Uri>> _montar(
  WidgetTester tester, {
  Aseguradora? aseguradora,
  bool abre = true,
  double letra = 1,
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.platformDispatcher.textScaleFactorTestValue = letra;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final llamadas = <Uri>[];
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        aseguradoraProvider.overrideWithValue(aseguradora),
        abrirLlamadaProvider.overrideWithValue((uri) async {
          llamadas.add(uri);
          return abre;
        }),
      ],
    ),
  );
  await tester.pumpAndSettle();
  enrutadorDe(tester).go(rutaLlamarRapido);
  await tester.pumpAndSettle();
  return llamadas;
}

void main() {
  testWidgets('muestra el 911, la agencia y la aseguradora', (tester) async {
    await _montar(tester);
    expect(find.byType(PantallaLlamarRapido), findsOneWidget);
    expect(find.text('Emergencias'), findsOneWidget);
    expect(find.text('La agencia'), findsOneWidget);
    expect(find.text('Mi aseguradora'), findsOneWidget);
  });

  testWidgets('un toque en el 911 abre el marcador con tel:911', (
    tester,
  ) async {
    final llamadas = await _montar(tester);
    await tester.tap(find.text('Emergencias'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:911')]);
  });

  testWidgets('sin aseguradora explica como agregarla y no llama', (
    tester,
  ) async {
    final llamadas = await _montar(tester);
    expect(
      find.textContaining('Aún no registras tu aseguradora'),
      findsWidgets,
    );
    await tester.tap(find.text('Mi aseguradora'));
    await tester.pumpAndSettle();
    expect(llamadas, isEmpty);
  });

  testWidgets('con aseguradora registrada la llama por su nombre', (
    tester,
  ) async {
    final llamadas = await _montar(
      tester,
      aseguradora: const Aseguradora(
        nombre: 'Seguros Sol',
        telefono: '800 111 2222',
      ),
    );
    await tester.tap(find.text('Seguros Sol'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:8001112222')]);
  });

  testWidgets('si el marcador no abre avisa el numero para marcarlo a mano', (
    tester,
  ) async {
    await _montar(tester, abre: false);
    await tester.tap(find.text('Emergencias'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Marca 911 a mano'), findsOneWidget);
  });

  testWidgets('con letra al 200 % en pantalla chica no desborda', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _montar(tester, letra: 2);
    expect(tester.takeException(), isNull);
  });
}
