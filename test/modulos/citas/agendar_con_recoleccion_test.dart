import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes. El fake deja sin cupo los dias que terminan en 0 o 5.
final _hoy = DateTime(2026, 11, 23);

const _casa = DireccionGuardada(
  id: 1,
  alias: 'Casa',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  cp: '06600',
  ciudad: 'CDMX',
  ubicacion: Coordenada(21.1250, -101.6860),
);

const _lejos = DireccionGuardada(
  id: 2,
  alias: 'Monterrey',
  calle: 'Calle 1',
  colonia: 'Centro',
  cp: '64000',
  ciudad: 'Monterrey',
  ubicacion: Coordenada(25.67, -100.31),
);

/// Anota con que direccion se agendo.
class _RepoEspia extends RepositorioCitasFake {
  _RepoEspia({super.direccionesFueraDeCobertura});

  final direcciones = <int?>[];

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
    int? direccionRecoleccionId,
    int? promocionId,
  }) {
    direcciones.add(direccionRecoleccionId);
    return super.agendar(
      vehiculoId: vehiculoId,
      franja: franja,
      motivo: motivo,
      direccionRecoleccionId: direccionRecoleccionId,
      promocionId: promocionId,
    );
  }
}

class _RepoQueFalla extends RepositorioCitasFake {
  _RepoQueFalla(this._fallo);

  final Object _fallo;

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
    int? direccionRecoleccionId,
    int? promocionId,
  }) => Future.error(_fallo);
}

Widget _app(
  RepositorioCitasFake citas, {
  List<DireccionGuardada> direcciones = const [_casa],
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioCitasProvider.overrideWithValue(citas),
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    repositorioRecoleccionProvider.overrideWithValue(
      RepositorioRecoleccionFake(direcciones: direcciones),
    ),
    relojCitasProvider.overrideWithValue(() => _hoy),
    configuracionTeselasProvider.overrideWithValue(
      const ConfiguracionTeselas(
        urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
        atribucion: '© Mapas de prueba',
      ),
    ),
  ],
  child: conTemaPista(const PantallaAgendarCita(), escenario: escenario),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 9000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _llenarFormulario(WidgetTester tester) async {
  await _tocar(tester, find.text('Mazda CX-5 2024'));
  await _tocar(tester, find.bySemanticsLabel('26 de noviembre'));
  await _tocar(tester, find.text('09:00 · 3 lugares'));
  await _tocar(tester, find.text('Mantenimiento'));
}

Future<void> _pedirRecoleccion(WidgetTester tester, String alias) async {
  await _tocar(tester, find.text('Que recojan mi auto'));
  await _tocar(tester, find.text(alias));
}

void main() {
  _prueba('el formulario ofrece llevar el auto o que lo recojan', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo llega tu auto al taller?'), findsOneWidget);
    expect(find.text('Lo llevo yo'), findsOneWidget);
    expect(find.text('Que recojan mi auto'), findsOneWidget);
  });

  _prueba('pedir recolección sin elegir dirección no deja continuar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _tocar(tester, find.text('Que recojan mi auto'));
    await _tocar(tester, find.text('Revisar y confirmar'));
    expect(find.text('Resumen de tu cita'), findsNothing);
  });

  _prueba('con dirección elegida muestra costo y franjas antes de seguir', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Casa');
    expect(find.text('Costo y horario'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
    expect(
      find.text('jueves, 26 de noviembre, de 07:00 a 09:00'),
      findsOneWidget,
    );
  });

  _prueba('sin día elegido la cotización espera el día', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _pedirRecoleccion(tester, 'Casa');
    expect(
      find.text('Elige día y horario para cotizar la recolección.'),
      findsOneWidget,
    );
  });

  _prueba('una dirección fuera de cobertura no deja continuar', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioCitasFake(), direcciones: const [_casa, _lejos]),
    );
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Monterrey');
    expect(find.text('Fuera de cobertura'), findsOneWidget);
    await _tocar(tester, find.text('Revisar y confirmar'));
    expect(find.text('Resumen de tu cita'), findsNothing);
  });

  _prueba('el resumen muestra la recolección con su costo', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Casa');
    await _tocar(tester, find.text('Revisar y confirmar'));

    expect(find.text('Resumen de tu cita'), findsOneWidget);
    expect(find.text('Recolección'), findsOneWidget);
    expect(find.textContaining('Casa · Av. Reforma 100'), findsOneWidget);
    expect(find.text('Recogemos tu auto'), findsOneWidget);
    expect(find.text('Te lo entregamos'), findsOneWidget);
    expect(find.text('Costo de la recolección'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
  });

  _prueba('sin recolección el resumen no habla de ella', (tester) async {
    await tester.pumpWidget(_app(RepositorioCitasFake()));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _tocar(tester, find.text('Revisar y confirmar'));
    expect(find.text('Resumen de tu cita'), findsOneWidget);
    expect(find.text('Recolección'), findsNothing);
  });

  _prueba('confirmar manda la dirección y muestra la recolección', (
    tester,
  ) async {
    final repo = _RepoEspia();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Casa');
    await _tocar(tester, find.text('Revisar y confirmar'));
    await _tocar(tester, find.text('Confirmar cita'));

    expect(repo.direcciones, [1]);
    expect(find.text('Cita confirmada'), findsOneWidget);
    expect(find.text('Recolección a domicilio'), findsOneWidget);
    expect(find.text('Recogemos tu auto'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
  });

  _prueba('sin recolección confirmar no manda dirección', (tester) async {
    final repo = _RepoEspia();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _tocar(tester, find.text('Revisar y confirmar'));
    await _tocar(tester, find.text('Confirmar cita'));
    expect(repo.direcciones, [null]);
    expect(find.text('Recolección a domicilio'), findsNothing);
  });

  _prueba('si la cobertura cambió al confirmar lo explica', (tester) async {
    await tester.pumpWidget(
      _app(_RepoEspia(direccionesFueraDeCobertura: const {1})),
    );
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Casa');
    await _tocar(tester, find.text('Revisar y confirmar'));
    await _tocar(tester, find.text('Confirmar cita'));
    expect(
      find.textContaining('ya no está en nuestra zona de cobertura'),
      findsOneWidget,
    );
    expect(find.text('Confirmar cita'), findsOneWidget);
  });

  _prueba('una dirección que ya no existe se explica', (tester) async {
    await tester.pumpWidget(
      _app(_RepoQueFalla(const NoEncontrado('no existe'))),
    );
    await tester.pumpAndSettle();
    await _llenarFormulario(tester);
    await _pedirRecoleccion(tester, 'Casa');
    await _tocar(tester, find.text('Revisar y confirmar'));
    await _tocar(tester, find.text('Confirmar cita'));
    expect(find.textContaining('No encontramos esa dirección'), findsOneWidget);
  });

  for (final e in [Escenario.oscuro, Escenario.letraGrande]) {
    _prueba('formulario, resumen y confirmación sin desbordes ($e)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(RepositorioCitasFake(), escenario: e));
      await tester.pumpAndSettle();
      await _llenarFormulario(tester);
      await _pedirRecoleccion(tester, 'Casa');
      await _tocar(tester, find.text('Revisar y confirmar'));
      await _tocar(tester, find.text('Confirmar cita'));
      expect(find.text('Cita confirmada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
