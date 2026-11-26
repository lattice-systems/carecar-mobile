import 'dart:async';

import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Object?> _cargar(ImageProvider imagen) {
  final fin = Completer<Object?>();
  imagen
      .resolve(ImageConfiguration.empty)
      .addListener(
        ImageStreamListener(
          (info, _) => fin.complete(info.image.width),
          onError: (e, _) => fin.complete(e),
        ),
      );
  return fin.future;
}

void main() {
  testWidgets('la tesela lisa es un cuadro de 256 sin red', (tester) async {
    final fuente = TeselasLisas();

    expect(await _cargar(fuente.tesela(x: 1, y: 2, zoom: 3)), 256);
    expect(fuente.pedidas, 1);
  });

  testWidgets('la fuente sin conexión falla al cargar', (tester) async {
    final fuente = TeselasSinConexion();

    expect(await _cargar(fuente.tesela(x: 1, y: 2, zoom: 3)), isA<Exception>());
  });

  testWidgets('con conexión de vuelta vuelve a entregar cuadros', (
    tester,
  ) async {
    final fuente = TeselasSinConexion()..hayConexion = true;

    expect(await _cargar(fuente.tesela(x: 4, y: 5, zoom: 6)), 256);
  });
}
