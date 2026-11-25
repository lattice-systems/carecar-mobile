import 'dart:io';

import 'package:carecar_mobile/nucleo/diseno/tokens/tipografia.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes empaquetadas para que las capturas usen sus glifos y pesos.
void prepararFuentesGolden() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const inter = [
      'assets/fonts/Inter-400.ttf',
      'assets/fonts/Inter-500.ttf',
      'assets/fonts/Inter-600.ttf',
      'assets/fonts/Inter-700.ttf',
    ];
    const jetBrainsMono = [
      'assets/fonts/JetBrainsMono-400.ttf',
      'assets/fonts/JetBrainsMono-700.ttf',
    ];
    final directorioAssets = Platform.environment['UNIT_TEST_ASSETS'];
    if (directorioAssets == null) {
      throw StateError('Ejecuta los golden con flutter test desde CareCar.');
    }

    // En pruebas, Ahem puede resolver un nombre ausente antes de que el
    // motor llegue a la fuente de respaldo indicada por el token.
    await _cargarFuentes(Tipografia.respaldoTexto.first, inter);
    await _cargarFuentes(Tipografia.familiaTexto, inter);
    await _cargarFuentes(Tipografia.respaldoCifras.first, jetBrainsMono);
    await _cargarFuentes(Tipografia.familiaCifras, jetBrainsMono);
    await _cargarFuentes('MaterialIcons', [
      '$directorioAssets/fonts/MaterialIcons-Regular.otf',
    ]);
  });
}

Future<void> _cargarFuentes(String familia, List<String> rutas) {
  final cargador = FontLoader(familia);
  for (final ruta in rutas) {
    cargador.addFont(File(ruta).readAsBytes().then(ByteData.sublistView));
  }
  return cargador.load();
}
