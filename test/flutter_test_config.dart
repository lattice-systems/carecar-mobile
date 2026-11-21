import 'dart:async';

import 'package:carecar_mobile/widgets/movimiento.dart';

/// Apaga las animaciones infinitas en todas las pruebas.
Future<void> testExecutable(FutureOr<void> Function() pruebas) async {
  Movimiento.continuo = false;
  await pruebas();
}
