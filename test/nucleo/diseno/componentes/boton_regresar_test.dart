import 'dart:async';

import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_portada.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _app(GoRouter router, {double escala = 1}) => MaterialApp.router(
  routerConfig: router,
  locale: idiomaBase,
  localizationsDelegates: delegadasDeIdioma,
  supportedLocales: idiomasSoportados,
  theme: TemaPista.claro(),
  builder: (context, hijo) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(escala)),
    child: hijo!,
  ),
);

GoRouter _enRaiz({required Widget pantalla}) => GoRouter(
  initialLocation: '/modulo',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const Scaffold(body: Text('Inicio de prueba')),
    ),
    GoRoute(path: '/modulo', builder: (_, _) => pantalla),
  ],
);

Widget _conEncabezado() => Scaffold(
  body: CustomScrollView(
    slivers: [
      const EncabezadoGrande(titulo: 'Mi garaje', conRegreso: true),
      SliverList.list(children: const [SizedBox(height: 900)]),
    ],
  ),
);

Widget _conBarra() => Scaffold(
  extendBodyBehindAppBar: true,
  appBar: const BarraPortada(titulo: 'Mantenimiento'),
  body: const SizedBox.expand(),
);

void main() {
  testWidgets('sin pantalla anterior, Regresar lleva al inicio', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_enRaiz(pantalla: _conEncabezado())));
    await tester.pumpAndSettle();
    expect(find.text('Mi garaje'), findsOneWidget);
    await tester.tap(find.byType(BotonRegresar));
    await tester.pumpAndSettle();
    expect(find.text('Inicio de prueba'), findsOneWidget);
  });

  testWidgets('con pantalla anterior, Regresar la recupera', (tester) async {
    final router = _enRaiz(pantalla: _conEncabezado());
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();
    router.go('/');
    await tester.pumpAndSettle();
    unawaited(router.push('/modulo'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    await tester.tap(find.byType(BotonRegresar));
    await tester.pumpAndSettle();
    expect(find.text('Inicio de prueba'), findsOneWidget);
  });

  testWidgets('se anuncia como boton «Regresar»', (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(_app(_enRaiz(pantalla: _conEncabezado())));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(BotonRegresar)),
      containsSemantics(label: 'Regresar', isButton: true, isEnabled: true),
    );
    semantica.dispose();
  });

  testWidgets('mide al menos 48 x 48 y no desborda con letra al 200 %', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_enRaiz(pantalla: _conEncabezado()), escala: 2),
    );
    await tester.pumpAndSettle();
    final caja = tester.getSize(find.byType(BotonRegresar));
    expect(caja.width, greaterThanOrEqualTo(48));
    expect(caja.height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('la barra de portada tambien trae Regresar', (tester) async {
    await tester.pumpWidget(_app(_enRaiz(pantalla: _conBarra())));
    await tester.pumpAndSettle();
    expect(find.byType(BotonRegresar), findsOneWidget);
    await tester.tap(find.byType(BotonRegresar));
    await tester.pumpAndSettle();
    expect(find.text('Inicio de prueba'), findsOneWidget);
  });

  testWidgets('el encabezado sin conRegreso no lo muestra', (tester) async {
    await tester.pumpWidget(
      _app(
        _enRaiz(
          pantalla: const Scaffold(
            body: CustomScrollView(slivers: [EncabezadoGrande(titulo: 'Otra')]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BotonRegresar), findsNothing);
  });
}
