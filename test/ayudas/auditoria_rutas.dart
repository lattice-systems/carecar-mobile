import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'api_falsa.dart';
import 'app_enrutada.dart';
import 'auditoria_accesibilidad.dart';

/// Monta la app con el enrutador real, en español, sin animaciones y con
/// sesión, lista para recorrer sus pantallas.
Future<void> montarParaAuditar(
  WidgetTester tester, {
  ApiFalsa? api,
  List<Override> overrides = const [],
}) async {
  telefonoChicoYAlto(tester, alto: 4000);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final apiUsada = api ?? ApiFalsa();
  final sesion = ControladorSesion(apiUsada, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: apiUsada,
      controlador: sesion,
      overrides: overrides,
    ),
  );
  await tester.pumpAndSettle();
}

/// En 320 de ancho siete días no caben a 48: se aceptan unos 40 de ancho con
/// 48 de alto (excepción de V2-M20.08, ver la ficha de M20).
const _toqueDeCalendario = MinimumTapTargetGuideline(
  size: Size(40, 48),
  link: 'https://www.w3.org/TR/WCAG22/#target-size-minimum',
);

/// Recorre `rutas` (V2-M20.02, 03 y 08) en 320 de ancho: claro y oscuro con
/// las guías de zona táctil, etiqueta y contraste, y letra al 200 % sin
/// desbordes. Cada ruta dice qué pantalla debe abrir, para que un enlace roto
/// no pase como pantalla accesible. Reúne todas las faltas antes de fallar.
Future<void> auditarRutas(
  WidgetTester tester,
  Map<String, Type> rutas, {
  bool conCalendario = false,
}) async {
  final faltas = <String>[];
  final semantica = tester.ensureSemantics();
  const variantes = [
    ('claro', Brightness.light, 1.0),
    ('oscuro', Brightness.dark, 1.0),
    ('letra 200 %', Brightness.light, 2.0),
  ];
  final alFallar = FlutterError.onError;
  var donde = '';
  FlutterError.onError = (detalle) =>
      faltas.add('$donde: ${detalle.exceptionAsString().split('\n').first}');
  try {
    for (final (nombre, brillo, letra) in variantes) {
      tester.platformDispatcher.platformBrightnessTestValue = brillo;
      tester.platformDispatcher.textScaleFactorTestValue = letra;
      for (final MapEntry(key: ruta, value: pantalla) in rutas.entries) {
        donde = '$ruta en $nombre';
        enrutadorDe(tester).go('/');
        await tester.pumpAndSettle();
        enrutadorDe(tester).go(ruta);
        await tester.pumpAndSettle();
        if (find.byType(pantalla).evaluate().isEmpty ||
            pantallaDeAcceso.evaluate().isNotEmpty) {
          faltas.add('$donde: no abrió $pantalla');
          continue;
        }
        if (letra != 1) continue;
        for (final guia in [
          if (conCalendario)
            _toqueDeCalendario
          else ...[
            androidTapTargetGuideline,
            iOSTapTargetGuideline,
          ],
          labeledTapTargetGuideline,
          textContrastGuideline,
        ]) {
          final resultado = await guia.evaluate(tester);
          if (!resultado.passed) faltas.add('$donde: ${resultado.reason}');
        }
      }
    }
  } finally {
    FlutterError.onError = alFallar;
    semantica.dispose();
  }
  expect(faltas, isEmpty, reason: faltas.join('\n'));
}
