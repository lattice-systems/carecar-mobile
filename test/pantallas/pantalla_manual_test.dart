import '../ayudas/envolver_con_shad.dart';

import 'dart:async';

import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:carecar_mobile/pantallas/pantalla_manual.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ManualesPrueba implements ServicioManuales {
  int llamadas = 0;
  final espera = Completer<DocumentoManual>();
  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) {
    llamadas++;
    if (llamadas == 1) return espera.future;
    throw const FalloManual(
      'El manual de este vehículo todavía no está disponible.',
    );
  }
}

void main() {
  testWidgets('carga, informa fallo y permite reintentar o volver al detalle', (
    tester,
  ) async {
    final servicio = _ManualesPrueba();
    await tester.pumpWidget(
      MaterialAppConShad(
        theme: TemaCareCar.claro,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Detalle'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaManual(
                    vehiculo: const Vehiculo(
                      id: 1,
                      vin: 'A',
                      modelo: 'March',
                      anio: 2020,
                    ),
                    servicio: servicio,
                    alCerrarSesion: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Detalle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Cargando manual…'), findsOneWidget);
    servicio.espera.completeError(Exception('fallo local'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo cargar el PDF. Intenta de nuevo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(
      find.text('El manual de este vehículo todavía no está disponible.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Volver al detalle'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);
  });
}
