import 'dart:ui' show Size;

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grafica.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_valuacion.dart';

const _pantalla = PantallaValorVehiculo(vehiculoId: 5);

void main() {
  testWidgets('un punto por mes con estimacion, su tabla y su rango', (
    tester,
  ) async {
    pantallaAlta(tester);
    // Sin agosto ni octubre: no se inventan.
    await tester.pumpWidget(
      app(
        _pantalla,
        repositorio: RepositorioValuacionFake(
          puntos: [punto(7, 118000), punto(9, 115000), punto(11, 110000)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final grafica = tester.widget<Grafica>(find.byType(Grafica));
    expect(grafica.tipo, TipoGrafica.lineas);
    expect(grafica.puntos.map((p) => p.valor), [118000, 115000, 110000]);
    expect(find.text(leyenda), findsOneWidget);
    expect(find.text(r'$108,000 a $128,000, con 47,000 km'), findsOneWidget);
    expect(find.text('noviembre de 2026'), findsOneWidget);
    expect(find.textContaining('agosto'), findsNothing);

    await tester.tap(find.text('Ver como tabla'));
    await tester.pumpAndSettle();
    expect(find.text(r'$115,000'), findsOneWidget);
  });

  testWidgets('con un solo mes muestra su valor y explica la tendencia', (
    tester,
  ) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      app(
        _pantalla,
        repositorio: RepositorioValuacionFake(puntos: [punto(11, 110000)]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Grafica), findsNothing);
    expect(find.text(r'$110,000'), findsOneWidget);
    expect(find.textContaining('La tendencia aparece'), findsOneWidget);
    expect(find.byType(GrupoLista), findsOneWidget);
    expect(find.text(leyenda), findsOneWidget);
  });

  testWidgets('sin estimaciones ofrece la calculadora, con la leyenda', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(_pantalla, repositorio: RepositorioValuacionFake()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Ir a la calculadora'), findsOneWidget);
    expect(find.text(leyenda), findsOneWidget);
  });

  testWidgets('mientras carga lo anuncia, con la leyenda', (tester) async {
    await tester.pumpWidget(
      app(_pantalla, repositorio: RepositorioValuacionFake()),
    );
    expect(find.bySemanticsLabel('Cargando la valuación'), findsOneWidget);
    expect(find.text(leyenda), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('sin conexion deja reintentar, con la leyenda', (tester) async {
    // Alta: con el encabezado en tarjeta, «Reintentar» queda fuera de los 600
    // de alto de la pantalla de pruebas.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = RepositorioValuacionFake(
      puntos: [punto(11, 110000)],
      falla: const SinConexion(),
    );
    await tester.pumpWidget(app(_pantalla, repositorio: repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text(leyenda), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text(r'$110,000'), findsOneWidget);
  });

  testWidgets('un auto ajeno se explica', (tester) async {
    await tester.pumpWidget(
      app(
        _pantalla,
        repositorio: RepositorioValuacionFake(falla: const NoEncontrado('x')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No encontramos ese auto'), findsOneWidget);
  });

  testWidgets('claro, oscuro y letra al 200 % con las guias', (tester) async {
    pantallaAlta(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          _pantalla,
          repositorio: RepositorioValuacionFake(
            puntos: [punto(9, 115000), punto(11, 110000)],
          ),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      expect(find.byType(Grafica), findsOneWidget);
      await auditarAccesibilidad(tester);
    }
  });

  testWidgets('en 320 de ancho pasa las guias en los tres escenarios', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          _pantalla,
          repositorio: RepositorioValuacionFake(
            puntos: [punto(9, 115000), punto(11, 110000)],
          ),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });
}
