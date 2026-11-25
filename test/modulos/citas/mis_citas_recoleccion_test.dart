import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes 23 de noviembre de 2026, a mediodia.
final _ahora = DateTime(2026, 11, 23, 12);

RecoleccionAgendada _recoleccion({
  EstadoTraslado recoger = EstadoTraslado.programado,
  EstadoTraslado entregar = EstadoTraslado.programado,
}) => RecoleccionAgendada(
  direccionId: 1,
  costoTotal: 300,
  traslados: [
    TrasladoAgendado(
      id: 5,
      tipo: TipoTraslado.recoger,
      costo: 150,
      fecha: DateTime(2026, 11, 26),
      ventanaInicio: '07:00',
      ventanaFin: '09:00',
      estado: recoger,
    ),
    TrasladoAgendado(
      id: 6,
      tipo: TipoTraslado.entregar,
      costo: 150,
      fecha: DateTime(2026, 11, 26),
      ventanaInicio: '17:00',
      ventanaFin: '19:00',
      estado: entregar,
    ),
  ],
);

CitaCliente _cita(
  int id, {
  EstadoDeCita estado = EstadoDeCita.confirmada,
  int dia = 26,
  RecoleccionAgendada? recoleccion,
}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  franjaId: id,
  fecha: DateTime(2026, 11, dia),
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: estado,
  recoleccion: recoleccion,
);

Widget _app(List<CitaCliente> citas, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [
        repositorioCitasProvider.overrideWithValue(
          RepositorioCitasFake(citas: citas, reloj: () => _ahora),
        ),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        relojCitasProvider.overrideWithValue(() => _ahora),
      ],
      child: conTemaPista(const PantallaMisCitas(), escenario: escenario),
    );

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

void main() {
  group('seguimiento del chofer desde Mis citas (V2-M17.03)', () {
    _prueba('una cita con recoleccion muestra sus traslados', (tester) async {
      await tester.pumpWidget(_app([_cita(1, recoleccion: _recoleccion())]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recolección ·'), findsOneWidget);
      expect(find.text('Recogemos tu auto'), findsOneWidget);
      expect(find.text('Te lo entregamos'), findsOneWidget);
      expect(find.text('Checklist al recoger'), findsNothing);
    });

    _prueba('una cita sin recoleccion no trae el grupo', (tester) async {
      await tester.pumpWidget(_app([_cita(1)]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recolección ·'), findsNothing);
      expect(find.text('Recogemos tu auto'), findsNothing);
    });

    _prueba('cada cita con recoleccion lleva su propio encabezado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app([
          _cita(1, recoleccion: _recoleccion()),
          _cita(2, dia: 27, recoleccion: _recoleccion()),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Recolección ·'), findsNWidgets(2));
    });

    _prueba('una cita cancelada no muestra traslados', (tester) async {
      await tester.pumpWidget(
        _app([
          _cita(1, estado: EstadoDeCita.cancelada, recoleccion: _recoleccion()),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recogemos tu auto'), findsNothing);
    });

    _prueba('con el auto recogido ofrece el checklist de recoger', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app([
          _cita(1, recoleccion: _recoleccion(recoger: EstadoTraslado.recogido)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checklist al recoger'), findsOneWidget);
      expect(find.text('Checklist al entregar'), findsNothing);
    });

    _prueba('una cita pasada con recoleccion tambien la muestra', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app([
          _cita(
            2,
            estado: EstadoDeCita.atendida,
            dia: 10,
            recoleccion: _recoleccion(
              recoger: EstadoTraslado.entregado,
              entregar: EstadoTraslado.entregado,
            ),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Comparar recoger y entregar'), findsOneWidget);
    });

    for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
      _prueba('cabe sin desbordar en $escenario', (tester) async {
        await tester.pumpWidget(
          _app([
            _cita(
              1,
              recoleccion: _recoleccion(
                recoger: EstadoTraslado.entregado,
                entregar: EstadoTraslado.entregado,
              ),
            ),
          ], escenario: escenario),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Recolección ·'), findsOneWidget);
      });
    }
  });
}
