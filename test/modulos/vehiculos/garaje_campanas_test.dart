import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/garantia.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Solo el vehiculo 1 (Mazda CX-5) tiene una campana pendiente.
class _CampanasDelUno extends RepositorioGarantiaFake {
  @override
  Future<List<CampanaSeguridad>> campanas(int vehiculoId) async => [
    if (vehiculoId == 1)
      CampanaSeguridad(
        id: 7,
        codigo: 'RC-24-017',
        titulo: 'Bolsa de aire del conductor',
        descripcion: 'El inflador puede activarse con fuerza de más.',
        queHacer: 'Agenda una revisión.',
        gravedad: GravedadCampana.critica,
        estado: EstadoCampana.abierta,
        publicadaEn: DateTime.utc(2026, 11, 20),
      ),
  ];
}

Widget _app({Escenario escenario = Escenario.claro}) => ProviderScope(
  overrides: [
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    repositorioGarantiaProvider.overrideWithValue(_CampanasDelUno()),
    eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
  ],
  child: conTemaPista(const PantallaGaraje(), escenario: escenario),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('el auto con una campana pendiente lleva su insignia (V2-M10.02)', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(InsigniaCampanas), findsOneWidget);
    expect(find.text('Campaña de seguridad'), findsOneWidget);
  });

  _prueba('la insignia va bajo la tarjeta de su auto', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final insignia = tester.getRect(find.text('Campaña de seguridad'));
    final cx5 = tester.getRect(find.textContaining('CX-5').first);
    final mazda3 = tester.getRect(find.textContaining('Mazda 3').first);
    expect(insignia.top, greaterThan(cx5.bottom));
    expect(insignia.bottom, lessThan(mazda3.top));
  });

  for (final escenario in Escenario.values) {
    _prueba('con la insignia no desborda en $escenario', (tester) async {
      await tester.pumpWidget(_app(escenario: escenario));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
