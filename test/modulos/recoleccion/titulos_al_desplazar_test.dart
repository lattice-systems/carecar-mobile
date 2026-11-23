import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/direccion_guardada.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

final _direcciones = [
  for (var i = 1; i <= 8; i++)
    DireccionGuardada(
      id: i,
      alias: 'Dirección $i',
      calle: 'Calle $i',
      colonia: 'Colonia',
      cp: '06600',
      ciudad: 'CDMX',
      ubicacion: Coordenada(19.4326, -99.1332),
    ),
];

Widget _app(Widget pantalla, Escenario escenario) => ProviderScope(
  overrides: [
    repositorioRecoleccionProvider.overrideWithValue(
      RepositorioRecoleccionFake(direcciones: _direcciones),
    ),
    configuracionTeselasProvider.overrideWithValue(
      const ConfiguracionTeselas(
        urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
        atribucion: '© Mapas de prueba',
      ),
    ),
  ],
  child: conTemaPista(pantalla, escenario: escenario),
);

/// Pantalla chica, se desplaza al fondo y el titulo contraido debe seguir
/// siendo lo que recibe el toque en su centro: nada pasa por encima.
void _prueba(String nombre, Widget Function() pantalla, String titulo) {
  for (final escenario in Escenario.values) {
    testWidgets(
      '$nombre: el titulo no queda tapado al desplazar ($escenario)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(pantalla(), escenario));
        await tester.pumpAndSettle();
        for (final dy in [-250.0, -600.0, -2000.0]) {
          await tester.drag(find.byType(CustomScrollView).first, Offset(0, dy));
          await tester.pumpAndSettle();
          expect(find.text(titulo).hitTestable(), findsOneWidget);
        }
      },
    );
  }
}

void main() {
  _prueba(
    'mis direcciones',
    () => const PantallaMisDirecciones(),
    'Mis direcciones',
  );
  _prueba(
    'nueva dirección',
    () => const PantallaDireccion(),
    'Nueva dirección',
  );
}
