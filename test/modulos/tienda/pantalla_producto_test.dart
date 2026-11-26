// V2-M14.01 (compatibilidad y existencia) y V2-M14.03 (instalar en mi próxima
// cita desde el producto).
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_tienda.dart';

Carrito _carrito(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PantallaProducto)))
        .read(carritoProvider);

Future<void> _montar(
  WidgetTester tester, {
  int productoId = 1,
  List<CitaCliente> citas = const [],
  Escenario escenario = Escenario.claro,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    app(
      PantallaProducto(productoId: productoId),
      repositorio: tiendaDePrueba(),
      citas: citas,
      escenario: escenario,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra precio, existencia y que le queda a mi auto', (
    tester,
  ) async {
    await _montar(tester);

    expect(find.text('Tapetes de uso rudo'), findsOneWidget);
    expect(find.textContaining(r'$850.00'), findsOneWidget);
    expect(find.textContaining('Quedan 3 piezas'), findsOneWidget);
    expect(find.text('Le queda a tu Nissan March 2020'), findsOneWidget);
    expect(find.text('2017 a 2022'), findsOneWidget);
  });

  testWidgets('dice cuando no le queda y no deja pedir lo agotado', (
    tester,
  ) async {
    await _montar(tester, productoId: 3);

    expect(find.text('No le queda a tu Nissan March 2020'), findsOneWidget);
    expect(find.textContaining('Agotado'), findsOneWidget);
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    expect(_carrito(tester).vacio, isTrue);
  });

  testWidgets('agrega al carrito', (tester) async {
    await _montar(tester);

    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();

    expect(_carrito(tester).renglones.single.cantidad, 1);
    expect(find.text('Agregado. Llevas 1 de este producto.'), findsOneWidget);
    expect(find.text('Ver carrito (1)'), findsOneWidget);
  });

  testWidgets('al llegar al maximo no dice que agrego', (tester) async {
    await _montar(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Agregar al carrito'));
      await tester.pumpAndSettle();
    }

    expect(_carrito(tester).piezas, 3);
    expect(
      find.text('Ya llevas 3, el máximo de este producto.'),
      findsOneWidget,
    );
  });

  testWidgets('sin citas por venir lo explica y ofrece agendar', (
    tester,
  ) async {
    await _montar(
      tester,
      citas: [
        cita(dia: 20),
        cita(id: 2, estado: EstadoDeCita.cancelada),
      ],
    );

    await tester.tap(find.text('Instalar en mi próxima cita'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No tienes citas'), findsOneWidget);
    expect(find.text('Agendar cita'), findsOneWidget);
    expect(_carrito(tester).vacio, isTrue);
  });

  testWidgets('si ninguna cita es de un auto compatible lo dice', (
    tester,
  ) async {
    await _montar(tester, citas: [cita(vehiculoId: 6)]);

    await tester.tap(find.text('Instalar en mi próxima cita'));
    await tester.pumpAndSettle();

    expect(
      find.text('No le queda al auto de ninguna de tus próximas citas.'),
      findsOneWidget,
    );
    expect(_carrito(tester).vacio, isTrue);
  });

  testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await _montar(tester, escenario: escenario);
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });

  testWidgets('en una pantalla chica con letra grande no desborda', (
    tester,
  ) async {
    pantallaChica(tester);
    await tester.pumpWidget(
      app(
        const PantallaProducto(productoId: 1),
        repositorio: tiendaDePrueba(),
        escenario: Escenario.letraGrande,
        ancho: 320,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('un producto retirado lo explica', (tester) async {
    await _montar(tester, productoId: 99);

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Ese producto ya no está'), findsOneWidget);
  });

  testWidgets('sin conexion deja reintentar', (tester) async {
    final repo = tiendaDePrueba(falla: const SinConexion());
    await tester.pumpWidget(
      app(const PantallaProducto(productoId: 1), repositorio: repo),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Tapetes de uso rudo'), findsOneWidget);
  });
}
