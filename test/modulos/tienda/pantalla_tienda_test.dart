// V2-M14.01: productos compatibles con mi auto, con existencia visible,
// categorías y búsqueda.
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_tienda.dart';

void main() {
  testWidgets('abre filtrada por mi primer auto y muestra la existencia', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba();
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();

    expect(repo.consultas.last.vehiculoId, 5);
    expect(find.text('Tapetes de uso rudo'), findsOneWidget);
    expect(find.text('Champú con cera'), findsOneWidget);
    expect(find.text('Filtro de aire Jetta'), findsNothing);
    expect(find.textContaining('Quedan 3 piezas'), findsOneWidget);
    expect(find.text('Le queda a tu auto'), findsOneWidget);
    expect(find.text('Para cualquier auto'), findsOneWidget);
  });

  testWidgets('al elegir otro auto cambia lo compatible', (tester) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba();
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('VW Jetta 2018'));
    await tester.pumpAndSettle();

    expect(repo.consultas.last.vehiculoId, 6);
    expect(find.text('Filtro de aire Jetta'), findsOneWidget);
    expect(find.textContaining('Agotado'), findsOneWidget);
    expect(find.text('Tapetes de uso rudo'), findsNothing);
  });

  testWidgets('«Todos los productos» quita el filtro del auto', (tester) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba();
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Todos los productos'));
    await tester.pumpAndSettle();

    expect(repo.consultas.last.vehiculoId, isNull);
    expect(find.byType(TarjetaResumen), findsNWidgets(3));
  });

  testWidgets('un enlace con vehiculo abre filtrada por el', (tester) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba();
    await tester.pumpWidget(
      app(const PantallaTienda(vehiculoId: 6), repositorio: repo),
    );
    await tester.pumpAndSettle();

    expect(repo.consultas.last.vehiculoId, 6);
  });

  testWidgets('filtra por categoria y busca por nombre o codigo', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba();
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cuidado del auto'));
    await tester.pumpAndSettle();
    expect(repo.consultas.last.categoria, CategoriaProducto.cuidado);
    expect(find.text('Tapetes de uso rudo'), findsNothing);

    await tester.tap(find.text('Todo'));
    await tester.pumpAndSettle();
    final antes = repo.consultas.length;
    await tester.enterText(find.byType(EditableText), 'acc-tap');
    expect(repo.consultas, hasLength(antes));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(repo.consultas.last.texto, 'acc-tap');
    expect(find.text('Tapetes de uso rudo'), findsOneWidget);
    expect(find.text('Champú con cera'), findsNothing);
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    await tester.pumpWidget(
      app(const PantallaTienda(), repositorio: tiendaDePrueba()),
    );
    expect(find.bySemanticsLabel('Cargando la tienda'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('vacio explica y deja ver todo', (tester) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba(productos: [filtro]);
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    await tester.tap(find.text('Ver todos los productos'));
    await tester.pumpAndSettle();

    expect(find.text('Filtro de aire Jetta'), findsOneWidget);
  });

  testWidgets('sin conexion lo dice y reintentar recupera', (tester) async {
    pantallaAlta(tester);
    final repo = tiendaDePrueba(falla: const SinConexion());
    await tester.pumpWidget(app(const PantallaTienda(), repositorio: repo));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Tapetes de uso rudo'), findsOneWidget);
  });

  testWidgets('otro error tambien deja reintentar', (tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      app(
        const PantallaTienda(),
        repositorio: tiendaDePrueba(falla: const ErrorDelServidor('x')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('No pudimos cargar esto'), findsOneWidget);
  });

  testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
    pantallaAlta(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          const PantallaTienda(),
          repositorio: tiendaDePrueba(),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      expect(find.text('Tapetes de uso rudo'), findsOneWidget);
      await auditarAccesibilidad(tester);
    }
  });

  testWidgets('en una pantalla chica con letra grande no desborda', (
    tester,
  ) async {
    pantallaChica(tester);
    await tester.pumpWidget(
      app(
        const PantallaTienda(),
        repositorio: tiendaDePrueba(),
        escenario: Escenario.letraGrande,
        ancho: 320,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
