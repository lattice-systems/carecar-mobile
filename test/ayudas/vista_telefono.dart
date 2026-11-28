import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pone la vista de la prueba del tamaño de un teléfono común (412 × 915).
///
/// La vista por omisión (800 × 600) es más baja que cualquier teléfono: una
/// pantalla con portada, como el acceso, deja el botón fuera y el toque no
/// llega. Se restablece sola al terminar la prueba.
void vistaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
