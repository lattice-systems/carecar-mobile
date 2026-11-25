import 'package:carecar_mobile/modulos/galeria/presentacion/seccion_galeria.dart';
import 'package:carecar_mobile/modulos/galeria/presentacion/secciones_portada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fuentes_golden.dart';
import '../../../ayudas/tema_pista.dart';

/// Golden de los componentes de estilo portada en claro, oscuro y letra al 200 %.
void main() {
  prepararFuentesGolden();

  final secciones = seccionesPortada();
  const nombres = {
    'Boton pildora': 'boton_pildora',
    'Cabecera de portada': 'cabecera_portada',
    'Estante': 'estante',
    'Grupo de lista': 'grupo_lista',
  };

  for (final SeccionGaleria seccion in secciones) {
    for (final escenario in Escenario.values) {
      final archivo =
          'goldens/${nombres[seccion.titulo]}_${escenario.name}.png';
      testWidgets('${seccion.titulo} en ${escenario.name}', (tester) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          conTemaPista(
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Builder(builder: seccion.construir),
              ),
            ),
            escenario: escenario,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await expectLater(find.byType(Scaffold), matchesGoldenFile(archivo));
      });
    }
  }
}
