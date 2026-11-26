import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/repositorio_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/pantalla_plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/proveedores_mantenimiento.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

Widget _app(
  RepositorioMantenimiento repo, {
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [repositorioMantenimientoProvider.overrideWithValue(repo)],
  child: conTemaPista(
    const PantallaPlanMantenimiento(vehiculoId: 5),
    escenario: escenario,
  ),
);

/// Pantalla alta: el plan es una lista perezosa y lo de abajo no se construye
/// si no cabe.
void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

PlanMantenimiento _plan({
  ProximoServicio? proximo,
  List<ServicioMantenimiento>? servicios,
  int? kmActual = 9000,
}) {
  final base = RepositorioMantenimientoFake.planDeEjemplo();
  return PlanMantenimiento(
    vehiculoId: base.vehiculoId,
    kmActual: kmActual,
    kmActualizadoEn: kmActual == null ? null : base.kmActualizadoEn,
    kmFuente: kmActual == null ? null : base.kmFuente,
    promedioKmDiario: base.promedioKmDiario,
    servicios: servicios ?? base.servicios,
    proximo: proximo,
  );
}

void main() {
  _prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(
      find.bySemanticsLabel('Cargando tu plan de mantenimiento'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  _prueba('el próximo servicio es el héroe con km, fecha y motivo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();

    expect(find.text('Mantenimiento'), findsOneWidget);
    // Título del héroe y fila de la lista.
    expect(find.text('Servicio de 10,000 km'), findsNWidgets(2));
    expect(find.textContaining('Te toca por kilometraje'), findsOneWidget);
    expect(find.textContaining('Faltan 1,000 km · hacia el'), findsOneWidget);
    expect(find.text('Agendar este servicio'), findsOneWidget);
    expect(find.text('Registrar km'), findsOneWidget);
  });

  _prueba('si llegó primero el tiempo el motivo lo dice', (tester) async {
    final base = RepositorioMantenimientoFake.planDeEjemplo();
    final p = base.proximo!;
    await tester.pumpWidget(
      _app(
        RepositorioMantenimientoFake(
          plan: _plan(
            proximo: ProximoServicio(
              servicioId: p.servicioId,
              nombre: p.nombre,
              kmObjetivo: p.kmObjetivo,
              fechaEstimada: p.fechaEstimada,
              faltanKm: 400,
              faltanDias: 3,
              motivo: MotivoProximo.tiempo,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Te toca por tiempo transcurrido'),
      findsOneWidget,
    );
  });

  _prueba('cuando ya toca lo dice sin números negativos', (tester) async {
    final base = RepositorioMantenimientoFake.planDeEjemplo();
    final p = base.proximo!;
    await tester.pumpWidget(
      _app(
        RepositorioMantenimientoFake(
          plan: _plan(
            kmActual: 10200,
            proximo: ProximoServicio(
              servicioId: p.servicioId,
              nombre: p.nombre,
              kmObjetivo: p.kmObjetivo,
              fechaEstimada: p.fechaEstimada,
              faltanKm: -200,
              faltanDias: 0,
              motivo: MotivoProximo.km,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Ya te toca'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
  });

  _prueba('sin próximo estimado invita a registrar el kilometraje', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(plan: _plan(kmActual: null))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin próximo servicio estimado'), findsOneWidget);
    expect(
      find.textContaining('Registra tu kilometraje para calcular'),
      findsOneWidget,
    );
    expect(find.text('Agendar este servicio'), findsNothing);
    expect(find.text('Registrar km'), findsOneWidget);
  });

  _prueba('la lista muestra el estado de cada servicio', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();

    expect(find.text('Plan de servicios'), findsOneWidget);
    expect(find.text('Servicio de 5,000 km'), findsOneWidget);
    // El estado va en el texto de la fila para que lo lea el lector de
    // pantalla; el icono y su color lo refuerzan.
    expect(find.textContaining('Hecho el'), findsOneWidget);
    expect(find.text('Próximo · 10,000 km · 12 meses'), findsOneWidget);
    expect(find.text('Pendiente · 15,000 km · 18 meses'), findsOneWidget);
  });

  _prueba('un servicio vencido se marca como vencido', (tester) async {
    final base = RepositorioMantenimientoFake.planDeEjemplo();
    final servicios = [
      for (final s in base.servicios)
        s.id == 2
            ? ServicioMantenimiento(
                id: s.id,
                nombre: s.nombre,
                km: s.km,
                meses: s.meses,
                precioEstimado: s.precioEstimado,
                conceptos: s.conceptos,
                estado: EstadoServicio.vencido,
              )
            : s,
    ];
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(plan: _plan(servicios: servicios))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vencido · 10,000 km · 12 meses'), findsOneWidget);
  });

  _prueba('muestra el km vigente con quién lo registró', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();

    expect(find.text('Tu kilometraje'), findsOneWidget);
    expect(find.text('9,000 km'), findsOneWidget);
    expect(find.textContaining('Registrado por el taller el'), findsOneWidget);
    expect(find.text('Promedio: 40 km al día'), findsOneWidget);
  });

  _prueba('un km del cliente se rotula como registrado por ti', (tester) async {
    final repo = RepositorioMantenimientoFake();
    await repo.registrarKm(5, 9300);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.text('9,300 km'), findsOneWidget);
    expect(find.textContaining('Registrado por ti el'), findsOneWidget);
  });

  _prueba('sin plan para el modelo lo explica', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioMantenimientoFake(
          plan: const PlanMantenimiento(vehiculoId: 5, servicios: []),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay plan para tu auto'), findsOneWidget);
    expect(find.text('Agendar este servicio'), findsNothing);
  });

  _prueba('un error de red muestra sin conexión y reintenta', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  _prueba('cualquier otro error muestra el error genérico', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(error: StateError('falló'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('No pudimos cargar esto'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    _prueba('se ve sin desbordes ($escenario)', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioMantenimientoFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Agendar este servicio'), findsOneWidget);
    });
  }

  _prueba('pasa la auditoría de accesibilidad', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();
    await auditarAccesibilidad(tester);
  });
}
