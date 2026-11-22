import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/auditoria_accesibilidad.dart';
import '../ayudas/tema_pista.dart';

const _modelos = [
  ModeloVigente(
    id: 1,
    nombre: 'CX-5',
    marca: 'Mazda',
    anio: 2024,
    version: 'Signature',
    precioDesde: 450000,
  ),
];

/// Auditoria de las pantallas v2 que ya existen. Cada historia de pantalla
/// nueva suma aqui la suya.
void main() {
  group('PantallaCatalogo', () {
    for (final escenario in Escenario.values) {
      testWidgets('pasa la auditoria en ${escenario.name}', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [catalogoProvider.overrideWith((ref) async => _modelos)],
            child: conTemaPista(const PantallaCatalogo(), escenario: escenario),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // A letra grande solo se exige que no se desborde: las guias de zona
        // tactil y contraste ya se miden en claro y oscuro.
        if (escenario != Escenario.letraGrande) {
          await auditarAccesibilidad(tester);
        }
      });
    }
  });
}
