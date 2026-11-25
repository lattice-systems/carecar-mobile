import 'dart:convert';

import 'package:carecar_mobile/nucleo/diseno/tokens/tipografia.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes empaquetadas para que las capturas usen sus glifos y pesos.
void prepararFuentesGolden() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final json = await rootBundle.loadString('FontManifest.json');
    final familias = {
      for (final familia
          in (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>())
        familia['family'] as String: (familia['fonts'] as List<dynamic>)
            .cast<Map<String, dynamic>>(),
    };

    // En pruebas, Ahem puede resolver un nombre ausente antes de que el
    // motor llegue a la fuente de respaldo indicada por el token.
    familias.putIfAbsent(
      Tipografia.familiaTexto,
      () => familias[Tipografia.respaldoTexto.first]!,
    );
    familias.putIfAbsent(
      Tipografia.familiaCifras,
      () => familias[Tipografia.respaldoCifras.first]!,
    );

    for (final familia in familias.entries) {
      final cargador = FontLoader(familia.key);
      for (final fuente in familia.value) {
        cargador.addFont(rootBundle.load(fuente['asset'] as String));
      }
      await cargador.load();
    }
  });
}
