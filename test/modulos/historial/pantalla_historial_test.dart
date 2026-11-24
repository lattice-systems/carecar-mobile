import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/pantalla_historial.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/proveedores_historial.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

Widget _app(
  RepositorioHistorialFake repo, {
  int tamano = 20,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    repositorioHistorialProvider.overrideWithValue(repo),
    tamanoPaginaHistorialProvider.overrideWithValue(tamano),
  ],
  child: conTemaPista(
    const PantallaHistorial(vehiculoId: 1),
    escenario: escenario,
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('muestra cada orden con su total y su estatus', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.text('Historial'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsOneWidget);
    expect(find.text(r'$1,200.00'), findsOneWidget);
    expect(find.text(r'$801.00'), findsOneWidget);
    expect(find.textContaining('Terminado ·'), findsNWidgets(2));
    expect(find.textContaining('Entregado ·'), findsOneWidget);
    expect(find.textContaining('Cerrada el'), findsNWidgets(3));
  });

  _prueba('filtra por año con los años que tienen servicios', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);

    await tester.tap(find.text('2025'));
    await tester.pumpAndSettle();

    expect(find.text(r'$801.00'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsNothing);

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    expect(find.text(r'$1,282.00'), findsOneWidget);
  });

  _prueba('al llegar al final pide la pagina siguiente', (tester) async {
    final repo = RepositorioHistorialFake();
    await tester.pumpWidget(_app(repo, tamano: 2));
    await tester.pumpAndSettle();

    expect(repo.paginasPedidas, [(null, 0), (null, 1)]);
    expect(find.text(r'$801.00'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  _prueba('sin servicios lo explica', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake(ordenes: const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no hay servicios'), findsOneWidget);
  });

  _prueba('sin conexion ofrece reintentar', (tester) async {
    final repo = RepositorioHistorialFake()..falla = const SinConexion();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text(r'$1,282.00'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    _prueba('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioHistorialFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Historial'), findsOneWidget);
    });
  }
}
