import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/repositorio_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../ayudas/tema_pista.dart';

ProximoServicio _proximo({
  int faltanKm = 1000,
  int faltanDias = 25,
  MotivoProximo motivo = MotivoProximo.km,
}) => ProximoServicio(
  servicioId: 2,
  nombre: 'Servicio de 10,000 km',
  kmObjetivo: 10000,
  fechaEstimada: DateTime(2026, 12, 16),
  faltanKm: faltanKm,
  faltanDias: faltanDias,
  motivo: motivo,
);

Widget _tarjeta(
  ProximoServicio proximo, {
  double? avance,
  VoidCallback? alToque,
  Escenario escenario = Escenario.claro,
}) => conTemaPista(
  SingleChildScrollView(
    child: TarjetaProximoServicio(
      proximo: proximo,
      avance: avance,
      alToque: alToque,
    ),
  ),
  escenario: escenario,
);

/// El inicio con la tarjeta ligada al proveedor, dentro de un enrutador para
/// comprobar a dónde lleva el toque.
Widget _inicio(RepositorioMantenimiento repo) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                TarjetaProximoServicioDelAuto(vehiculoId: 5),
                Text('fin de la lista'),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/mantenimiento/:vehiculoId',
        builder: (_, estado) =>
            Text('plan del ${estado.pathParameters['vehiculoId']}'),
      ),
    ],
  );
  return ProviderScope(
    overrides: [repositorioMantenimientoProvider.overrideWithValue(repo)],
    child: MaterialApp.router(
      locale: idiomaBase,
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      theme: TemaPista.claro(),
      routerConfig: router,
    ),
  );
}

void main() {
  group('TarjetaProximoServicio', () {
    testWidgets('dice qué toca, por qué y cuánto falta, con su barra', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_tarjeta(_proximo(), avance: 0.8));

      expect(find.text('Servicio de 10,000 km'), findsOneWidget);
      expect(find.text('Te toca por kilometraje'), findsOneWidget);
      expect(find.textContaining('Faltan 1,000 km · hacia el'), findsOneWidget);
      // El lector oye un solo nodo con el avance en porcentaje.
      expect(tester.getSemantics(find.byType(TarjetaResumen)).value, '80 %');
      semantica.dispose();
    });

    testWidgets('sin avance de km, lo que falta va como detalle', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        _tarjeta(_proximo(motivo: MotivoProximo.tiempo, faltanDias: 20)),
      );

      expect(find.text('Te toca por tiempo transcurrido'), findsOneWidget);
      expect(find.textContaining('Faltan 1,000 km'), findsOneWidget);
      expect(tester.getSemantics(find.byType(TarjetaResumen)).value, isEmpty);
      semantica.dispose();
    });

    testWidgets('cuando ya toca lo dice con el km que se pasó', (tester) async {
      await tester.pumpWidget(
        _tarjeta(_proximo(faltanKm: 0, faltanDias: 3), avance: 1),
      );

      expect(find.textContaining('Ya te toca'), findsOneWidget);
      expect(find.textContaining('Faltan'), findsNothing);
    });

    testWidgets('con alToque es un botón con chevron; sin él es informativa', (
      tester,
    ) async {
      var toques = 0;
      await tester.pumpWidget(_tarjeta(_proximo(), alToque: () => toques++));

      expect(find.byIcon(LucideIcons300.chevronRight), findsOneWidget);
      await tester.tap(find.text('Servicio de 10,000 km'));
      expect(toques, 1);

      await tester.pumpWidget(_tarjeta(_proximo()));
      expect(find.byIcon(LucideIcons300.chevronRight), findsNothing);
    });

    for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
      testWidgets('se pinta sin desbordes en $escenario', (tester) async {
        await tester.pumpWidget(
          _tarjeta(_proximo(), avance: 0.4, escenario: escenario),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Servicio de 10,000 km'), findsOneWidget);
      });
    }
  });

  group('TarjetaProximoServicioDelAuto', () {
    testWidgets('mientras carga reserva el lugar con un esqueleto', (
      tester,
    ) async {
      await tester.pumpWidget(_inicio(RepositorioMantenimientoFake()));

      expect(find.byType(Esqueleto), findsOneWidget);
      expect(find.text('Servicio de 10,000 km'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(Esqueleto), findsNothing);
    });

    testWidgets('con plan muestra el próximo servicio y su avance', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_inicio(RepositorioMantenimientoFake()));
      await tester.pumpAndSettle();

      expect(find.text('Servicio de 10,000 km'), findsOneWidget);
      expect(find.textContaining('Faltan 1,000 km · hacia el'), findsOneWidget);
      // 9,000 km entre el servicio hecho de 5,000 y el de 10,000.
      expect(tester.getSemantics(find.byType(TarjetaResumen)).value, '80 %');
      semantica.dispose();
    });

    testWidgets('si el plan falla, no ocupa lugar ni deja un esqueleto', (
      tester,
    ) async {
      await tester.pumpWidget(
        _inicio(RepositorioMantenimientoFake(error: const SinConexion())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TarjetaResumen), findsNothing);
      expect(find.byType(Esqueleto), findsNothing);
      expect(find.text('fin de la lista'), findsOneWidget);
    });

    testWidgets('si no hay próximo servicio estimado, no ocupa lugar', (
      tester,
    ) async {
      final base = RepositorioMantenimientoFake.planDeEjemplo();
      await tester.pumpWidget(
        _inicio(
          RepositorioMantenimientoFake(
            plan: PlanMantenimiento(
              vehiculoId: base.vehiculoId,
              servicios: base.servicios,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TarjetaResumen), findsNothing);
      expect(find.text('fin de la lista'), findsOneWidget);
    });

    testWidgets('al tocarla abre el plan de mantenimiento de ese auto', (
      tester,
    ) async {
      await tester.pumpWidget(_inicio(RepositorioMantenimientoFake()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Servicio de 10,000 km'));
      await tester.pumpAndSettle();

      expect(find.text('plan del 5'), findsOneWidget);
    });
  });
}
