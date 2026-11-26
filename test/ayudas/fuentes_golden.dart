import 'dart:io';

import 'package:carecar_mobile/nucleo/diseno/tokens/tipografia.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes empaquetadas para que las capturas usen sus glifos y pesos.
void prepararFuentesGolden() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Los mismos pesos que declara `pubspec.yaml`: con uno de más la captura
    // pintaría una letra que la app no trae.
    const geist = [
      'assets/fonts/Geist-400.ttf',
      'assets/fonts/Geist-500.ttf',
      'assets/fonts/Geist-600.ttf',
    ];
    const geistMono = ['assets/fonts/GeistMono-500.ttf'];
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

    await _cargarFuentes(Tipografia.familiaTexto, geist);
    await _cargarFuentes(Tipografia.familiaCifras, geistMono);
    await _cargarFuentes(Tipografia.respaldoTexto.first, inter);
    await _cargarFuentes(Tipografia.respaldoCifras.first, jetBrainsMono);
    // El set de íconos de la app (V2-T02.07): sin cargarlo salen cuadros.
    await _cargarFuentes('packages/lucide_icons_flutter/Lucide300', [
      '$directorioAssets/packages/lucide_icons_flutter/assets/build_font/'
          'LucideVariable-w300.ttf',
    ]);
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
