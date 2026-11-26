import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/pantalla_plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/proveedores_mantenimiento.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

const _texto = 'Tu próximo servicio ya se acerca';

Future<EventosEnVivoFake> _montar(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final eventos = EventosEnVivoFake();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioMantenimientoProvider.overrideWithValue(
          RepositorioMantenimientoFake(),
        ),
        eventosEnVivoProvider.overrideWithValue(eventos),
      ],
      child: conTemaPista(const PantallaPlanMantenimiento(vehiculoId: 5)),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

void main() {
  testWidgets('el recordatorio de este vehiculo aparece en vivo', (
    tester,
  ) async {
    final eventos = await _montar(tester);
    expect(find.textContaining(_texto), findsNothing);
    eventos.emitir('mantenimiento.recordatorio', {
      'vehiculoId': 5,
      'servicioId': 2,
      'nombre': 'Servicio 20 000 km',
      'faltanKm': 800,
      'faltanDias': 30,
      'motivo': 'km',
    });
    await tester.pumpAndSettle();
    expect(find.textContaining(_texto), findsOneWidget);
  });

  testWidgets('el recordatorio de otro vehiculo no se muestra', (tester) async {
    final eventos = await _montar(tester);
    eventos.emitir('mantenimiento.recordatorio', {'vehiculoId': 99});
    await tester.pumpAndSettle();
    expect(find.textContaining(_texto), findsNothing);
  });

  testWidgets('un evento de otro tipo no lo dispara', (tester) async {
    final eventos = await _montar(tester);
    eventos.emitir('asistencia.estado', {'vehiculoId': 5});
    await tester.pumpAndSettle();
    expect(find.textContaining(_texto), findsNothing);
  });
}
