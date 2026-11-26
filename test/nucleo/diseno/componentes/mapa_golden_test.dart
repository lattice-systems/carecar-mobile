import 'package:carecar_mobile/nucleo/diseno/componentes/mapa.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fuentes_golden.dart';
import '../../../ayudas/tema_pista.dart';

/// Golden del componente `Mapa` (V2-T02.09) en claro, oscuro y letra al 200 %:
/// pin, ubicación propia, marcador en movimiento y todos sus controles. Las
/// teselas son cuadros dibujados en memoria.
void main() {
  prepararFuentesGolden();

  for (final escenario in Escenario.values) {
    testWidgets('Mapa en ${escenario.name}', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        conTemaPista(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Mapa(
                teselas: const ConfiguracionTeselas(
                  urlPlantilla: 'https://teselas.invalid/{z}/{x}/{y}.png',
                  atribucion: '© colaboradores de OpenStreetMap',
                ),
                fuenteTeselas: TeselasLisas(),
                pin: const Coordenada(21.1250, -101.6860),
                alMoverPin: (_) {},
                miUbicacion: const Coordenada(21.1243, -101.6871),
                enMovimiento: const MarcadorEnMovimiento(
                  posicion: Coordenada(21.1256, -101.6849),
                  etiqueta: 'Chofer',
                ),
                proveedorUbicacion: UbicacionFalsa(),
              ),
            ),
          ),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/mapa_${escenario.name}.png'),
      );
    });
  }
}
