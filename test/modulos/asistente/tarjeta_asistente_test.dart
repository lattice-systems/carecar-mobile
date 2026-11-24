import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/asistente/asistente.dart';
import 'package:carecar_mobile/modulos/asistente/dominio/repositorio_asistente.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioAsistente {
  final preguntas = <String>[];

  @override
  Future<RespuestaDelAsistente> preguntar({
    required int vehiculoId,
    required String pregunta,
  }) async {
    preguntas.add(pregunta);
    return const RespuestaDelAsistente(texto: 'Listo.', encontrado: false);
  }

  @override
  Future<void> calificar({required int consultaId, required bool util}) async {}
}

void main() {
  group('Tarjeta del asistente en el detalle (V2-M24.10)', () {
    Future<List<Uri>> montar(WidgetTester tester) async {
      final visitadas = <Uri>[];
      final enrutador = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: SingleChildScrollView(
                child: TarjetaAsistente(vehiculoId: 2),
              ),
            ),
          ),
          GoRoute(
            path: '/asistente/:id',
            builder: (_, estado) {
              visitadas.add(estado.uri);
              return const Text('Asistente');
            },
          ),
        ],
      );
      addTearDown(enrutador.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: enrutador,
          theme: TemaPista.claro(),
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
        ),
      );
      await tester.pumpAndSettle();
      return visitadas;
    }

    testWidgets('tocar la tarjeta abre el asistente del vehiculo', (
      tester,
    ) async {
      final visitadas = await montar(tester);
      await tester.tap(find.text('Pregúntale a tu auto'));
      await tester.pumpAndSettle();
      expect(visitadas.single.toString(), '/asistente/2');
    });

    testWidgets('tocar una pregunta abre el asistente con ella', (
      tester,
    ) async {
      final visitadas = await montar(tester);
      await tester.tap(find.text('¿Qué presión llevan las llantas?'));
      await tester.pumpAndSettle();
      expect(
        visitadas.single.queryParameters['pregunta'],
        '¿Qué presión llevan las llantas?',
      );
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const SingleChildScrollView(child: TarjetaAsistente(vehiculoId: 2)),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Pregunta inicial (V2-M24.10)', () {
    test('la ruta lleva la pregunta en la consulta', () {
      expect(rutaAsistente(2), '/asistente/2');
      expect(
        Uri.parse(rutaAsistente(2, pregunta: '¿Aceite?'))
            .queryParameters['pregunta'],
        '¿Aceite?',
      );
    });

    testWidgets('el asistente envia la pregunta inicial una vez', (
      tester,
    ) async {
      final repo = _Repo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositorioAsistenteProvider.overrideWithValue(repo)],
          child: conTemaPista(
            const PantallaAsistente(vehiculoId: 2, preguntaInicial: '¿Aceite?'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(repo.preguntas, ['¿Aceite?']);
      expect(find.text('¿Aceite?'), findsOneWidget);
    });
  });
}
