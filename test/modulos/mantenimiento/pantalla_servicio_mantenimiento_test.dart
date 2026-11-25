import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/repositorio_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/pantalla_servicio_mantenimiento.dart';
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
  int servicioId = 2,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [repositorioMantenimientoProvider.overrideWithValue(repo)],
  child: conTemaPista(
    PantallaServicioMantenimiento(vehiculoId: 5, servicioId: servicioId),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

PlanMantenimiento _planCon(List<ServicioMantenimiento> servicios) {
  final base = RepositorioMantenimientoFake.planDeEjemplo();
  return PlanMantenimiento(
    vehiculoId: base.vehiculoId,
    kmActual: base.kmActual,
    kmActualizadoEn: base.kmActualizadoEn,
    kmFuente: base.kmFuente,
    servicios: servicios,
    proximo: base.proximo,
  );
}

void main() {
  _prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(find.bySemanticsLabel('Cargando el servicio'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  _prueba('muestra el servicio, su estado y lo que incluye', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();

    expect(find.text('Servicio de 10,000 km'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
    expect(find.text('10,000 km · 12 meses'), findsOneWidget);
    expect(find.text('Qué incluye'), findsOneWidget);
    expect(find.text('Cambio de aceite y filtro'), findsOneWidget);
    expect(find.text('Revisión de frenos'), findsOneWidget);
    expect(find.text('Rotación de llantas'), findsOneWidget);
  });

  _prueba('el precio va como estimado con la leyenda no vinculante', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();

    expect(find.text('Precio estimado'), findsOneWidget);
    expect(find.text(r'$1,850.00'), findsOneWidget);
    expect(find.text('Estimación no vinculante'), findsOneWidget);
  });

  _prueba('un servicio sin conceptos lo dice', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioMantenimientoFake(
          plan: _planCon(const [
            ServicioMantenimiento(
              id: 2,
              nombre: 'Servicio de 10,000 km',
              km: 10000,
              meses: 12,
              precioEstimado: 1850,
              conceptos: [],
              estado: EstadoServicio.pendiente,
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Este servicio no trae conceptos detallados.'),
      findsOneWidget,
    );
  });

  _prueba('un servicio pendiente se puede agendar', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(), servicioId: 3),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Agendar este servicio'), findsOneWidget);
  });

  _prueba('un servicio hecho dice cuándo y no ofrece agendar', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(), servicioId: 1),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hecho'), findsOneWidget);
    expect(find.textContaining('Hecho el'), findsOneWidget);
    expect(find.text('Agendar este servicio'), findsNothing);
    // El precio sigue con su leyenda.
    expect(find.text('Estimación no vinculante'), findsOneWidget);
  });

  _prueba('un servicio que ya no está en el plan lo explica', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(), servicioId: 99),
    );
    await tester.pumpAndSettle();

    expect(find.text('No encontramos este servicio'), findsOneWidget);
    expect(find.text('Agendar este servicio'), findsNothing);
  });

  _prueba('un error de red muestra sin conexión', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioMantenimientoFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Sin conexion'), findsOneWidget);
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
      expect(find.text('Estimación no vinculante'), findsOneWidget);
    });
  }

  _prueba('pasa la auditoría de accesibilidad', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await tester.pumpAndSettle();
    await auditarAccesibilidad(tester);
  });
}
