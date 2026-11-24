import 'dart:async';

import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/asistente/dominio/repositorio_asistente.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/modulos/asistente/presentacion/pantalla_asistente.dart';
import 'package:carecar_mobile/modulos/asistente/presentacion/proveedores_asistente.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_mensaje.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/chip_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioAsistente {
  _Repo(this.alPreguntar);
  Future<RespuestaDelAsistente> Function(String pregunta) alPreguntar;
  final preguntas = <String>[];

  @override
  Future<RespuestaDelAsistente> preguntar({
    required int vehiculoId,
    required String pregunta,
  }) {
    preguntas.add(pregunta);
    return alPreguntar(pregunta);
  }
}

const _conCita = RespuestaDelAsistente(
  texto: 'Cada 10 000 km o un año.',
  encontrado: true,
  fuentes: [CitaDelManual(manualId: 26, pagina: 12)],
);

Widget _app(_Repo repo, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [repositorioAsistenteProvider.overrideWithValue(repo)],
      child: conTemaPista(
        const PantallaAsistente(vehiculoId: 2),
        escenario: escenario,
      ),
    );

Future<void> _preguntar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('campo-mensaje-enviar')));
  await tester.pump();
}

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  group('Pregúntale a tu auto (V2-M24.03)', () {
    _prueba(
      'sin preguntas explica que responde con el manual y avisa que es IA',
      (tester) async {
        await tester.pumpWidget(_app(_Repo((_) async => _conCita)));
        await tester.pump();

        expect(find.text('¿Qué quieres saber de tu auto?'), findsOneWidget);
        expect(find.textContaining('generadas con IA'), findsOneWidget);
        expect(find.byType(CampoMensaje), findsOneWidget);
      },
    );

    _prueba('pregunta, espera y muestra la respuesta con su pagina', (
      tester,
    ) async {
      final respuesta = Completer<RespuestaDelAsistente>();
      final repo = _Repo((_) => respuesta.future);
      await tester.pumpWidget(_app(repo));

      await _preguntar(tester, '¿Cada cuánto cambio el aceite?');
      expect(find.text('¿Cada cuánto cambio el aceite?'), findsOneWidget);
      expect(find.text('Buscando en tu manual…'), findsOneWidget);

      respuesta.complete(_conCita);
      await tester.pump();

      expect(find.text('Buscando en tu manual…'), findsNothing);
      expect(find.text('Cada 10 000 km o un año.'), findsOneWidget);
      expect(find.text('Manual, pág. 12'), findsOneWidget);
      expect(repo.preguntas, ['¿Cada cuánto cambio el aceite?']);
    });

    _prueba('si el manual no lo dice, responde sin citas', (tester) async {
      await tester.pumpWidget(
        _app(
          _Repo(
            (_) async => const RespuestaDelAsistente(
              texto: 'No encontré eso en tu manual.',
              encontrado: false,
            ),
          ),
        ),
      );

      await _preguntar(tester, '¿Tiene techo panorámico?');
      await tester.pump();

      expect(find.text('No encontré eso en tu manual.'), findsOneWidget);
      expect(find.textContaining('Manual, pág.'), findsNothing);
    });

    _prueba('sin conexion deja reintentar la misma pregunta', (tester) async {
      var intentos = 0;
      final repo = _Repo((_) async {
        intentos++;
        if (intentos == 1) throw const AsistenteSinConexion();
        return _conCita;
      });
      await tester.pumpWidget(_app(repo));

      await _preguntar(tester, '¿Aceite?');
      await tester.pump();
      expect(find.text('No se envió'), findsOneWidget);
      expect(find.textContaining('Revisa tu internet'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('No se envió'), findsNothing);
      expect(find.textContaining('Revisa tu internet'), findsNothing);
      expect(find.text('Cada 10 000 km o un año.'), findsOneWidget);
      expect(repo.preguntas, ['¿Aceite?', '¿Aceite?']);
    });

    _prueba(
      'el limite del dia y la falta de manual se explican sin reintento',
      (tester) async {
        final fallos = <FalloAsistente>[
          const AsistenteLimiteDiario(),
          const AsistenteSinManual(),
        ];
        await tester.pumpWidget(
          _app(_Repo((_) async => throw fallos.removeAt(0))),
        );

        await _preguntar(tester, 'Uno');
        await tester.pump();
        expect(find.textContaining('preguntas de hoy'), findsOneWidget);

        await _preguntar(tester, 'Dos');
        await tester.pump();
        expect(find.textContaining('aún no tiene un manual'), findsOneWidget);
        expect(find.text('Reintentar'), findsNothing);
      },
    );

    _prueba('se ve en claro, oscuro y letra grande sin desbordar', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          _app(_Repo((_) async => _conCita), escenario: escenario),
        );
        await _preguntar(tester, '¿Qué presión llevan las llantas?');
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Preguntas sugeridas (V2-M24.08)', () {
    _prueba('con la conversacion vacia muestra de 4 a 6 sugerencias', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_Repo((_) async => _conCita)));
      await tester.pump();

      final total = find.byType(ChipPista).evaluate().length;
      expect(total, inInclusiveRange(4, 6));
      expect(find.text('¿Qué presión llevan las llantas?'), findsOneWidget);
    });

    _prueba('tocar una la envia como pregunta y las sugerencias se van', (
      tester,
    ) async {
      final repo = _Repo((_) async => _conCita);
      await tester.pumpWidget(_app(repo));
      await tester.pump();

      await tester.tap(find.text('¿Cuánto aceite le cabe al motor?'));
      await tester.pump();
      await tester.pump();

      expect(repo.preguntas, ['¿Cuánto aceite le cabe al motor?']);
      expect(find.byType(ChipPista), findsNothing);
      expect(find.text('Cada 10 000 km o un año.'), findsOneWidget);
    });

    _prueba('las sugerencias caben en claro, oscuro y letra grande', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          _app(_Repo((_) async => _conCita), escenario: escenario),
        );
        await tester.pump();
        expect(find.byType(ChipPista), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Agendar desde la respuesta (V2-M24.06)', () {
    Widget conRutas(_Repo repo, List<Uri> visitadas) {
      final enrutador = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const PantallaAsistente(vehiculoId: 2),
          ),
          GoRoute(
            path: '/garaje/:id/manual',
            builder: (_, estado) {
              visitadas.add(estado.uri);
              return const Text('Manual');
            },
          ),
          GoRoute(
            path: '/citas/agendar',
            builder: (_, estado) {
              visitadas.add(estado.uri);
              return const Text('Agendar cita');
            },
          ),
        ],
      );
      addTearDown(enrutador.dispose);
      return ProviderScope(
        overrides: [repositorioAsistenteProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          routerConfig: enrutador,
          theme: TemaPista.claro(),
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
        ),
      );
    }

    _prueba('cada respuesta trae Agendar revision y abre la cita precargada', (
      tester,
    ) async {
      final visitadas = <Uri>[];
      await tester.pumpWidget(
        conRutas(_Repo((_) async => _conCita), visitadas),
      );
      await _preguntar(tester, '¿Por qué vibra el volante?');
      await tester.pump();

      expect(find.text('Agendar revisión'), findsOneWidget);
      await tester.tap(find.text('Agendar revisión'));
      await tester.pumpAndSettle();

      expect(find.text('Agendar cita'), findsOneWidget);
      expect(visitadas.single.queryParameters, {
        'vehiculo': '2',
        'motivo': 'revision',
      });
    });

    _prueba('tocar la cita abre el manual en esa pagina (V2-M24.04)', (
      tester,
    ) async {
      final visitadas = <Uri>[];
      await tester.pumpWidget(
        conRutas(_Repo((_) async => _conCita), visitadas),
      );
      await _preguntar(tester, '¿Aceite?');
      await tester.pump();

      await tester.tap(find.text('Manual, pág. 12'));
      await tester.pumpAndSettle();

      expect(find.text('Manual'), findsOneWidget);
      expect(visitadas.single.toString(), '/garaje/2/manual?pagina=12');
    });

    _prueba('un fallo del asistente no ofrece agendar', (tester) async {
      await tester.pumpWidget(
        conRutas(_Repo((_) async => throw const AsistenteLimiteDiario()), []),
      );
      await _preguntar(tester, 'Uno');
      await tester.pump();
      expect(find.text('Agendar revisión'), findsNothing);
    });
  });
}
