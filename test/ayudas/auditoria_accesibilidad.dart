import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Auditoria automatica de accesibilidad para una pantalla ya montada
/// (V2-M20.02, V2-M20.03 y V2-M20.08). Cada historia de pantalla la llama
/// despues de `pumpWidget` y `pumpAndSettle`:
///
/// ```dart
/// await auditarAccesibilidad(tester);
/// ```
///
/// Revisa zona tactil de 48 (Android) y 44 (iOS), etiqueta en todo control
/// tocable y contraste de texto. Lo que no se puede automatizar, la prueba con
/// TalkBack y VoiceOver, sigue en la lista de la historia.
///
/// Ojo con la zona tactil: las guias de Flutter ignoran los nodos pegados al
/// borde de la pantalla, porque pueden estar medio fuera. Un boton en la
/// esquina no se mide.
Future<void> auditarAccesibilidad(WidgetTester tester) async {
  final semantica = tester.ensureSemantics();
  try {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  } finally {
    semantica.dispose();
  }
}

/// Ancho de un teléfono chico, para comprobar que nada se corta (V2-M20.03).
const anchoTelefonoChico = 320.0;

/// Pone la vista en el ancho de un teléfono chico. El alto es grande a
/// propósito: así las listas construyen y se miden todas sus filas.
void telefonoChicoYAlto(WidgetTester tester, {double alto = 12000}) {
  tester.view.physicalSize = Size(anchoTelefonoChico, alto);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
