import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// V2-M06.06 · que el enganche exista, y siga existiendo.
///
/// Esta prueba es la que faltaba. Los recordatorios funcionaban en la v1 y
/// nadie noto que al migrar se quedaran sin disparador, porque **ninguna
/// prueba cubria el enganche**: las del servicio pasaban en verde mientras la
/// app no lo llamaba nunca.
///
/// Por eso no prueba al servicio, que ya esta probado. Prueba que la pantalla
/// lo llame.
void main() {
  final ahora = DateTime(2026, 12, 1, 9);

  CitaCliente cita({
    int id = 5,
    EstadoDeCita estado = EstadoDeCita.confirmada,
  }) => CitaCliente(
    id: id,
    vehiculoId: 1,
    fecha: DateTime(2026, 12, 20),
    horaInicio: '10:00',
    horaFin: '11:00',
    estado: estado,
    vehiculoNombre: 'Jetta 2021',
  );

  testWidgets('abrir «Mis citas» pone al día los recordatorios', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final espia = _RecordatoriosEspia();
    final citas = [cita(), cita(id: 7, estado: EstadoDeCita.cancelada)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositorioCitasProvider.overrideWithValue(
            RepositorioCitasFake(citas: citas, reloj: () => ahora),
          ),
          repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
          relojCitasProvider.overrideWithValue(() => ahora),
          recordatoriosDeCitaProvider.overrideWithValue(espia),
        ],
        child: conTemaPista(const PantallaMisCitas()),
      ),
    );
    await tester.pumpAndSettle();

    // La lista llego y la pantalla la paso tal cual: decidir cuales se
    // programan y cuales se cancelan es del servicio, no de la pantalla.
    expect(espia.sincronizadas, hasLength(1));
    expect(espia.sincronizadas.single.map((c) => c.id), [5, 7]);
  });
}

/// Un [RecordatoriosDeCita] que solo apunta lo que le piden.
class _RecordatoriosEspia implements RecordatoriosDeCita {
  final sincronizadas = <List<CitaCliente>>[];
  final confirmadas = <int>[];
  final canceladas = <int>[];

  @override
  Future<void> alConfirmar(CitaAgendada cita, {String? vehiculo}) async =>
      confirmadas.add(cita.id);

  @override
  Future<void> alAgendar(CitaCliente cita, {String? vehiculo}) async =>
      confirmadas.add(cita.id);

  @override
  Future<void> alCancelar(int citaId) async => canceladas.add(citaId);

  @override
  Future<void> sincronizar(List<CitaCliente> citas) async =>
      sincronizadas.add(citas);
}
