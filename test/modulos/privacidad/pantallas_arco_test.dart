import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/modulos/privacidad/dominio/arco.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/pantalla_mis_datos.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/pantalla_privacidad.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/proveedores_arco.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/rutas_privacidad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'repositorio_arco_falso.dart';

typedef _Compartido = ({Uint8List bytes, String nombre, String mime});

final _resuelta = solicitudArco(
  4,
  EstadoArco.resuelta,
  resuelta: DateTime.utc(2026, 11, 25, 18, 0, 2),
  vence: DateTime.utc(2026, 12, 2, 18, 0, 2),
);

Widget _escena(
  RepositorioArcoFalso repo,
  List<_Compartido> compartidos,
  Widget hijo, {
  Future<void> Function()? falloAlCompartir,
}) => ProviderScope(
  overrides: [
    repositorioArcoProvider.overrideWithValue(repo),
    eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
    intervaloArcoProvider.overrideWithValue(const Duration(hours: 1)),
    compartirDatosProvider.overrideWithValue((bytes, nombre, mime) async {
      compartidos.add((bytes: bytes, nombre: nombre, mime: mime));
      await falloAlCompartir?.call();
    }),
  ],
  child: hijo,
);

Widget _app(
  RepositorioArcoFalso repo,
  List<_Compartido> compartidos, {
  Escenario escenario = Escenario.claro,
  Future<void> Function()? falloAlCompartir,
}) => _escena(
  repo,
  compartidos,
  conTemaPista(const PantallaMisDatos(), escenario: escenario),
  falloAlCompartir: falloAlCompartir,
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

Future<void> _dejarCorrer(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

BotonPildora _boton(WidgetTester tester, Pattern texto) =>
    tester.widget<BotonPildora>(
      find.ancestor(
        of: find.textContaining(texto),
        matching: find.byType(BotonPildora),
      ),
    );

void main() {
  group('PantallaMisDatos (V2-M22.02)', () {
    _prueba('sin solicitudes explica la copia, lo que no incluye y la ofrece', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      expect(find.text('Mis datos'), findsOneWidget);
      expect(find.textContaining('Puedes pedir una copia'), findsOneWidget);
      expect(find.textContaining('No incluye lo fiscal'), findsOneWidget);
      expect(
        _boton(tester, 'Pedir una copia de mis datos').alPresionar,
        isNotNull,
      );
    });

    _prueba('pedir la copia la deja preparandose y no deja pedir otra', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso()
        ..alPedir = solicitudArco(1, EstadoArco.pendiente)
        ..esperaAlPedir = Completer<void>();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Pedir una copia de mis datos'));
      await tester.pump();

      expect(repo.pedidos, 1);
      expect(find.text('Pidiendo…'), findsOneWidget);
      expect(_boton(tester, 'Pidiendo').alPresionar, isNull);

      repo.esperaAlPedir!.complete();
      await _dejarCorrer(tester);

      expect(find.text('Estamos preparando tu archivo'), findsOneWidget);
      expect(find.textContaining('Tarda unos segundos'), findsOneWidget);
      expect(find.text('Pedir una copia de mis datos'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp('Estamos preparando tu archivo')),
        findsOneWidget,
      );
    });

    _prueba('una pendiente al abrir se muestra preparandose', (tester) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([solicitudArco(1, EstadoArco.pendiente)]);
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      expect(find.text('Estamos preparando tu archivo'), findsOneWidget);
    });

    _prueba('una lista muestra hasta cuando y se descarga y comparte', (
      tester,
    ) async {
      final compartidos = <_Compartido>[];
      final repo = RepositorioArcoFalso()
        ..listas.add([_resuelta])
        ..archivo = Uint8List.fromList(utf8.encode('{"cliente":{"id":1}}'));
      await tester.pumpWidget(_app(repo, compartidos));
      await _dejarCorrer(tester);

      expect(find.text('Tu archivo está listo'), findsOneWidget);
      expect(find.textContaining('Disponible hasta el'), findsOneWidget);
      expect(
        find.textContaining('Contiene información personal'),
        findsOneWidget,
      );

      await tester.tap(find.text('Descargar mi archivo'));
      await _dejarCorrer(tester);

      expect(repo.descargados, [4]);
      expect(compartidos, hasLength(1));
      expect(utf8.decode(compartidos.single.bytes), '{"cliente":{"id":1}}');
      expect(compartidos.single.mime, 'application/json');
      expect(compartidos.single.nombre, 'mis-datos-carecar-2026-11-25.json');
    });

    _prueba('el nombre del archivo lleva mes y dia con dos digitos', (
      tester,
    ) async {
      final compartidos = <_Compartido>[];
      final repo = RepositorioArcoFalso()
        ..listas.add([
          solicitudArco(
            4,
            EstadoArco.resuelta,
            resuelta: DateTime(2026, 3, 5, 12),
            vence: DateTime(2026, 3, 12, 12),
          ),
        ]);
      await tester.pumpWidget(_app(repo, compartidos));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Descargar mi archivo'));
      await _dejarCorrer(tester);

      expect(compartidos.single.nombre, 'mis-datos-carecar-2026-03-05.json');
    });

    _prueba('mientras descarga no deja tocar otra vez', (tester) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([_resuelta])
        ..esperaAlDescargar = Completer<void>();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Descargar mi archivo'));
      await tester.pump();

      expect(find.text('Preparando…'), findsOneWidget);
      expect(_boton(tester, 'Preparando').alPresionar, isNull);

      repo.esperaAlDescargar!.complete();
      await _dejarCorrer(tester);
      expect(find.text('Descargar mi archivo'), findsOneWidget);
    });

    _prueba('si el archivo ya no esta, lo dice y deja pedir otra copia', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso()
        ..listas.addAll([
          [_resuelta],
          [solicitudArco(4, EstadoArco.vencida)],
        ])
        ..archivo = const ArchivoArcoNoDisponible();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Descargar mi archivo'));
      await _dejarCorrer(tester);

      // Se vuelve a preguntar y la pantalla lo dice con su estado.
      expect(
        find.text('Tu archivo ya no está disponible. Pide una copia nueva.'),
        findsOneWidget,
      );
      // Un solo mensaje: el del estado, no ademas el de «no esta».
      expect(
        find.text('El archivo ya no está disponible. Pide una copia nueva.'),
        findsNothing,
      );
      expect(find.text('Pedir una copia de mis datos'), findsOneWidget);
      expect(find.text('Descargar mi archivo'), findsNothing);
    });

    _prueba(
      'si el servidor aun la da por lista, avisa que el archivo no esta',
      (tester) async {
        final repo = RepositorioArcoFalso()
          ..listas.addAll([
            [_resuelta],
            [_resuelta],
          ])
          ..archivo = const ArchivoArcoNoDisponible();
        await tester.pumpWidget(_app(repo, []));
        await _dejarCorrer(tester);

        await tester.tap(find.text('Descargar mi archivo'));
        await _dejarCorrer(tester);

        expect(
          find.text('El archivo ya no está disponible. Pide una copia nueva.'),
          findsOneWidget,
        );
        expect(find.text('Descargar mi archivo'), findsOneWidget);
      },
    );

    _prueba('otro error al descargar o al compartir no abre nada y avisa', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([_resuelta])
        ..archivo = const ArcoSinConexion();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Descargar mi archivo'));
      await _dejarCorrer(tester);

      expect(
        find.text('No pudimos descargar tu archivo. Intenta de nuevo.'),
        findsOneWidget,
      );

      // Al compartir tambien: se cancela la hoja o falla el sistema.
      repo.archivo = Uint8List.fromList([1, 2, 3]);
      await tester.pumpWidget(
        _app(
          repo,
          [],
          falloAlCompartir: () async => throw StateError('hoja cancelada'),
        ),
      );
      await _dejarCorrer(tester);
      await tester.tap(find.text('Descargar mi archivo'));
      await _dejarCorrer(tester);
      expect(
        find.text('No pudimos descargar tu archivo. Intenta de nuevo.'),
        findsOneWidget,
      );
    });

    _prueba('una fallida avisa y deja pedir otra vez', (tester) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([solicitudArco(2, EstadoArco.fallida)]);
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      expect(
        find.text('No pudimos preparar tu archivo. Intenta de nuevo.'),
        findsOneWidget,
      );
      expect(find.text('Pedir una copia de mis datos'), findsOneWidget);
    });

    _prueba('una vencida avisa y deja pedir otra', (tester) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([solicitudArco(2, EstadoArco.vencida)]);
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      expect(
        find.text('Tu archivo ya no está disponible. Pide una copia nueva.'),
        findsOneWidget,
      );
      expect(find.text('Pedir una copia de mis datos'), findsOneWidget);
    });

    _prueba('pedir otra copia teniendo una lista la deja preparandose', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso()
        ..listas.add([_resuelta])
        ..alPedir = solicitudArco(5, EstadoArco.pendiente);
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Pedir una copia nueva'));
      await _dejarCorrer(tester);

      expect(repo.pedidos, 1);
      expect(find.text('Estamos preparando tu archivo'), findsOneWidget);
    });

    _prueba('sin conexion al pedir lo dice y deja reintentar', (tester) async {
      final repo = RepositorioArcoFalso()..alPedir = const ArcoSinConexion();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Pedir una copia de mis datos'));
      await _dejarCorrer(tester);

      expect(
        find.text('Sin conexión. Conéctate para pedir tu copia.'),
        findsOneWidget,
      );
      expect(
        _boton(tester, 'Pedir una copia de mis datos').alPresionar,
        isNotNull,
      );

      repo.alPedir = solicitudArco(1, EstadoArco.pendiente);
      await tester.tap(find.text('Pedir una copia de mis datos'));
      await _dejarCorrer(tester);

      expect(
        find.text('Sin conexión. Conéctate para pedir tu copia.'),
        findsNothing,
      );
      expect(find.text('Estamos preparando tu archivo'), findsOneWidget);
    });

    _prueba('otro error al pedir no deja la pantalla muda', (tester) async {
      final repo = RepositorioArcoFalso()..alPedir = const ArcoNoDisponible();
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      await tester.tap(find.text('Pedir una copia de mis datos'));
      await _dejarCorrer(tester);

      expect(
        find.text('No pudimos pedir tu copia. Intenta de nuevo.'),
        findsOneWidget,
      );
    });

    _prueba('si no carga, ofrece reintentar', (tester) async {
      final repo = RepositorioArcoFalso()
        ..listas.addAll([const ArcoSinConexion(), const <SolicitudDeArco>[]]);
      await tester.pumpWidget(_app(repo, []));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsNothing);
      expect(find.text('Pedir una copia de mis datos'), findsOneWidget);
    });

    _prueba('mientras carga, un esqueleto que el lector anuncia', (
      tester,
    ) async {
      final repo = _RepoLento();
      await tester.pumpWidget(_app(repo, []));
      await tester.pump();

      expect(find.bySemanticsLabel('Cargando tus solicitudes'), findsOneWidget);
      repo.completar();
      await _dejarCorrer(tester);
    });

    _prueba('claro, oscuro y letra al 200 % sin desbordes en cada estado', (
      tester,
    ) async {
      final estados = <List<SolicitudDeArco>>[
        const [],
        [solicitudArco(1, EstadoArco.pendiente)],
        [_resuelta],
        [solicitudArco(1, EstadoArco.fallida)],
        [solicitudArco(1, EstadoArco.vencida)],
      ];
      for (final escenario in Escenario.values) {
        for (final lista in estados) {
          final repo = RepositorioArcoFalso()..listas.add(lista);
          await tester.pumpWidget(_app(repo, [], escenario: escenario));
          await _dejarCorrer(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: '$escenario ${lista.firstOrNull?.estado}',
          );
        }
      }
    });

    _prueba('pasa la auditoria de accesibilidad en claro y oscuro', (
      tester,
    ) async {
      for (final escenario in [Escenario.claro, Escenario.oscuro]) {
        for (final lista in <List<SolicitudDeArco>>[
          const [],
          [_resuelta],
        ]) {
          final repo = RepositorioArcoFalso()..listas.add(lista);
          await tester.pumpWidget(_app(repo, [], escenario: escenario));
          await _dejarCorrer(tester);
          await auditarAccesibilidad(tester);
        }
      }
    });
  });

  group('PantallaPrivacidad, el centro de mis datos (V2-M22.02)', () {
    /// El centro de mis datos con rutas de mentira para el resto: aqui solo
    /// importa a donde lleva cada fila.
    Widget enrutada() => _escena(
      RepositorioArcoFalso(),
      [],
      MaterialApp.router(
        locale: idiomaBase,
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        theme: TemaPista.claro(),
        routerConfig: GoRouter(
          initialLocation: rutaPrivacidad,
          routes: [
            GoRoute(
              path: rutaPrivacidad,
              builder: (_, _) => const PantallaPrivacidad(),
            ),
            GoRoute(
              path: rutaAvisoPrivacidad,
              builder: (_, _) => const Scaffold(body: Text('aviso abierto')),
            ),
            GoRoute(
              path: rutaMisDatos,
              builder: (_, _) => const Scaffold(body: Text('datos abiertos')),
            ),
            GoRoute(
              path: rutaEliminarCuenta,
              builder: (_, _) => const Scaffold(body: Text('eliminar abierto')),
            ),
          ],
        ),
      ),
    );

    _prueba('ofrece el aviso y la descarga de mis datos', (tester) async {
      await tester.pumpWidget(
        _escena(
          RepositorioArcoFalso(),
          [],
          conTemaPista(const PantallaPrivacidad()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacidad y mis datos'), findsOneWidget);
      expect(find.text('Aviso de privacidad'), findsOneWidget);
      expect(find.text('Qué hacemos con tus datos'), findsOneWidget);
      expect(find.text('Descargar mis datos'), findsOneWidget);
      expect(find.text('Una copia de tus datos personales'), findsOneWidget);
      expect(find.text('Eliminar mi cuenta'), findsOneWidget);
      expect(
        find.text('Borra tu cuenta y tus datos personales'),
        findsOneWidget,
      );
    });

    _prueba('cada fila lleva a su pantalla', (tester) async {
      await tester.pumpWidget(enrutada());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Descargar mis datos'));
      await tester.pumpAndSettle();
      expect(find.text('datos abiertos'), findsOneWidget);

      GoRouter.of(tester.element(find.text('datos abiertos'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aviso de privacidad'));
      await tester.pumpAndSettle();
      expect(find.text('aviso abierto'), findsOneWidget);

      GoRouter.of(tester.element(find.text('aviso abierto'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar mi cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('eliminar abierto'), findsOneWidget);
    });

    _prueba('pasa la auditoria de accesibilidad', (tester) async {
      for (final escenario in [Escenario.claro, Escenario.oscuro]) {
        await tester.pumpWidget(
          _escena(
            RepositorioArcoFalso(),
            [],
            conTemaPista(const PantallaPrivacidad(), escenario: escenario),
          ),
        );
        await tester.pumpAndSettle();
        await auditarAccesibilidad(tester);
      }
    });
  });
}

/// Repositorio cuya primera lectura espera a que la prueba la complete.
class _RepoLento extends RepositorioArcoFalso {
  final _espera = Completer<List<SolicitudDeArco>>();

  void completar() => _espera.complete(const []);

  @override
  Future<List<SolicitudDeArco>> solicitudes() => _espera.future;
}
