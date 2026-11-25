import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/orden_taller.dart';
import 'package:carecar_mobile/modulos/taller/dominio/repositorio_taller.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_adicionales.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/provisional/lienzo_firma_provisional.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_taller.dart';

Widget _app(
  RepositorioTallerFake repo, {
  Escenario escenario = Escenario.claro,
}) => appTaller(
  const PantallaAdicionales(ordenId: 41),
  repo,
  escenario: escenario,
);

Boton _boton(WidgetTester tester, String texto) => tester.widget<Boton>(
  find.ancestor(of: find.text(texto), matching: find.byType(Boton)),
);

Future<void> _firmar(WidgetTester tester) async {
  final trazo = await tester.startGesture(
    tester.getCenter(find.byKey(LienzoFirmaProvisional.area)),
  );
  for (var i = 0; i < 6; i++) {
    await trazo.moveBy(const Offset(25, 3));
    await tester.pump();
  }
  await trazo.up();
  await tester.pumpAndSettle();
}

void main() {
  pruebaTaller('cotiza cada trabajo por concepto con sus totales', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    expect(find.text('Cambio de balatas delanteras'), findsOneWidget);
    expect(find.text('Lavado de motor'), findsOneWidget);
    expect(find.text(r'$450.00'), findsOneWidget);
    expect(find.text(r'$1,200.50'), findsOneWidget);
    expect(find.text(r'$1,650.50'), findsOneWidget);
    expect(find.text('Total estimado'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsNWidgets(2));
    expect(find.text(r'$1,850.50'), findsOneWidget);
    expect(find.text('Aprobar'), findsNWidgets(2));
    expect(find.text('Rechazar'), findsNWidgets(2));
  });

  pruebaTaller('aprobar pide la firma y recalcula el total', (tester) async {
    final repo = RepositorioTallerFake();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aprobar').first);
    await tester.pumpAndSettle();
    expect(find.text('Firma para aprobar'), findsOneWidget);
    expect(_boton(tester, 'Aprobar con mi firma').alPresionar, isNull);

    await _firmar(tester);
    expect(_boton(tester, 'Aprobar con mi firma').alPresionar, isNotNull);
    await tester.tap(find.text('Aprobar con mi firma'));
    await tester.pumpAndSettle();

    expect(repo.respuestas, hasLength(1));
    final (ordenId, adicionalId, aprobado, firma) = repo.respuestas.single;
    expect((ordenId, adicionalId, aprobado), (41, 11, true));
    expect(firma, pngDePrueba);
    expect(find.text('Aprobado'), findsOneWidget);
    expect(
      find.textContaining('Aprobaste «Cambio de balatas delanteras»'),
      findsOneWidget,
    );
    expect(find.text(r'$2,932.50'), findsOneWidget);
    expect(find.text('Aprobar'), findsOneWidget);
  });

  pruebaTaller('rechazar tambien se firma y no suma al total', (tester) async {
    final repo = RepositorioTallerFake();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rechazar').last);
    await tester.pumpAndSettle();
    expect(find.text('Firma para rechazar'), findsOneWidget);
    await _firmar(tester);
    await tester.tap(find.text('Rechazar con mi firma'));
    await tester.pumpAndSettle();

    expect(repo.respuestas.single.$2, 12);
    expect(repo.respuestas.single.$3, isFalse);
    expect(find.text('Rechazado'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsNWidgets(2));
  });

  pruebaTaller('borrar deja la firma vacia', (tester) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aprobar').first);
    await tester.pumpAndSettle();
    await _firmar(tester);
    await tester.tap(find.text('Borrar firma'));
    await tester.pumpAndSettle();

    expect(_boton(tester, 'Aprobar con mi firma').alPresionar, isNull);
  });

  pruebaTaller('cerrar la hoja sin firmar no responde', (tester) async {
    final repo = RepositorioTallerFake();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aprobar').first);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(repo.respuestas, isEmpty);
    expect(find.text('Aprobar'), findsNWidgets(2));
  });

  for (final (falla, texto) in [
    (const AdicionalYaRespondido(), 'Ese trabajo ya tenía respuesta'),
    (const OrdenCerrada(), 'La orden ya está terminada'),
    (const SinConexion(), 'Sin conexión. Tu respuesta no se envió.'),
  ]) {
    pruebaTaller('si falla la respuesta lo explica: $texto', (tester) async {
      final repo = RepositorioTallerFake()..fallaAlResponder = falla;
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aprobar').first);
      await tester.pumpAndSettle();
      await _firmar(tester);
      await tester.tap(find.text('Aprobar con mi firma'));
      await tester.pumpAndSettle();

      expect(find.textContaining(texto), findsOneWidget);
      expect(find.text('Aprobar'), findsNWidgets(2));
    });
  }

  pruebaTaller('sin trabajos adicionales lo explica', (tester) async {
    final orden = ordenDeEjemplo();
    await tester.pumpWidget(
      _app(
        RepositorioTallerFake(
          ordenes: [
            OrdenEnVivo(
              id: orden.id,
              vehiculoId: orden.vehiculoId,
              vehiculo: orden.vehiculo,
              etapa: orden.etapa,
              avance: orden.avance,
              etapas: orden.etapas,
              inspeccion: orden.inspeccion,
              evidencias: orden.evidencias,
              adicionales: const [],
              totalOrden: orden.totalOrden,
              totalAdicionalesAprobados: 0,
              totalAdicionalesPendientes: 0,
              totalEstimado: orden.totalOrden,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    pruebaTaller('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioTallerFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
