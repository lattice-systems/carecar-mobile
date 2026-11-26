// V2-M14.02 (apartar, vigencia y rechazos) y V2-M14.03 (instalar en mi cita
// al apartar).
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_fake.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_tienda.dart';

Future<void> _montar(
  WidgetTester tester,
  RepositorioTiendaFake repo, {
  List<CitaCliente> citas = const [],
  Escenario escenario = Escenario.claro,
  bool conProducto = true,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    app(
      const PantallaCarrito(),
      repositorio: repo,
      citas: citas,
      escenario: escenario,
    ),
  );
  if (conProducto) carritoDe(tester, PantallaCarrito).agregar(tapetes, 2);
  await tester.pumpAndSettle();
}

Carrito _carrito(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PantallaCarrito)))
        .read(carritoProvider);

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('vacio lo explica y lleva a la tienda', (tester) async {
    await _montar(tester, tiendaDePrueba(), conProducto: false);

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Tu carrito está vacío'), findsOneWidget);
  });

  testWidgets('muestra el total, que se paga en caja y la vigencia', (
    tester,
  ) async {
    await _montar(tester, tiendaDePrueba());

    expect(find.bySemanticsLabel(r'Total: $1,700.00'), findsOneWidget);
    expect(find.text('No se cobra en la app: pagas en caja.'), findsOneWidget);
    expect(find.textContaining('dura 48 horas'), findsOneWidget);
  });

  testWidgets('apartar reserva, vacia el carrito y dice cuando vence', (
    tester,
  ) async {
    final repo = tiendaDePrueba();
    await _montar(tester, repo);

    await _tocar(tester, 'Apartar');

    expect(find.text('Productos apartados'), findsOneWidget);
    expect(find.textContaining('vence el'), findsOneWidget);
    expect(find.textContaining('28 nov'), findsOneWidget);
    expect(repo.carritosRecibidos.single.entrega, EntregaPedido.mostrador);
    expect(repo.llavesRecibidas.single.length, inInclusiveRange(8, 64));
    expect(repo.productosActuales.first.existencia, 1);
    expect(_carrito(tester).vacio, isTrue);
  });

  testWidgets('reintentar el mismo carrito reusa la llave y no duplica', (
    tester,
  ) async {
    final repo = tiendaDePrueba()..perderRespuestaAlApartar = true;
    await _montar(tester, repo);

    await _tocar(tester, 'Apartar');
    expect(find.textContaining('no se apartará dos veces'), findsOneWidget);
    await _tocar(tester, 'Entendido');
    expect(_carrito(tester).piezas, 2);
    await _tocar(tester, 'Apartar');

    expect(repo.llavesRecibidas, hasLength(2));
    expect(repo.llavesRecibidas.toSet(), hasLength(1));
    expect(repo.pedidosActuales, hasLength(1));
    expect(find.text('Productos apartados'), findsOneWidget);
  });

  testWidgets('si el carrito cambia, la llave tambien', (tester) async {
    final repo = tiendaDePrueba()..fallaAlGuardar = const SinConexion();
    await _montar(tester, repo);

    await _tocar(tester, 'Apartar');
    await _tocar(tester, 'Entendido');
    carritoDe(tester, PantallaCarrito).cantidad(1, 1);
    await tester.pumpAndSettle();
    await _tocar(tester, 'Apartar');

    expect(repo.llavesRecibidas.toSet(), hasLength(2));
  });

  testWidgets('quitar saca el producto', (tester) async {
    await _montar(tester, tiendaDePrueba());

    await _tocar(tester, 'Quitar');

    expect(find.byType(EstadoVacio), findsOneWidget);
  });

  const rechazos = {
    MotivoRechazoPedido.sinExistencia: 'Ya no alcanzan las piezas',
    MotivoRechazoPedido.citaNoDisponible: 'cancelada o ya pasó',
    MotivoRechazoPedido.limiteApartados: '3 pedidos sin entregar',
    MotivoRechazoPedido.productoIncompatible: 'no le queda al auto',
  };
  for (final MapEntry(key: motivo, value: texto) in rechazos.entries) {
    testWidgets('el rechazo ${motivo.name} se explica y conserva el carrito', (
      tester,
    ) async {
      final repo = tiendaDePrueba()..fallaAlGuardar = PedidoRechazado(motivo);
      await _montar(tester, repo);

      await _tocar(tester, 'Apartar');

      expect(find.text('No se pudo apartar'), findsOneWidget);
      expect(find.textContaining(texto), findsOneWidget);
      expect(
        find.text('Mis pedidos'),
        motivo == MotivoRechazoPedido.limiteApartados
            ? findsOneWidget
            : findsNothing,
      );
      await _tocar(tester, 'Entendido');
      expect(_carrito(tester).piezas, 2);
    });
  }

  testWidgets('instalar en mi cita ofrece solo confirmadas futuras', (
    tester,
  ) async {
    final repo = tiendaDePrueba();
    await _montar(
      tester,
      repo,
      citas: [
        cita(id: 40, dia: 30, vehiculoId: 6),
        cita(),
        cita(id: 2, dia: 20),
        cita(id: 3, dia: 29, estado: EstadoDeCita.cancelada),
      ],
    );

    await _tocar(tester, 'Instalar en mi cita');

    expect(find.textContaining('28 nov, 09:00'), findsOneWidget);
    expect(find.textContaining('30 nov, 09:00'), findsOneWidget);
    expect(find.textContaining('20 nov'), findsNothing);
    expect(find.textContaining('29 nov'), findsNothing);
    expect(find.textContaining('día siguiente a tu cita'), findsOneWidget);
    // Sin cita elegida todavía no se puede apartar.
    await _tocar(tester, 'Apartar');
    expect(repo.carritosRecibidos, isEmpty);

    await tester.tap(find.textContaining('28 nov, 09:00'));
    await tester.pumpAndSettle();
    await _tocar(tester, 'Apartar');

    expect(repo.carritosRecibidos.single.entrega, EntregaPedido.cita);
    expect(repo.carritosRecibidos.single.citaId, 31);
  });

  testWidgets('sin citas ofrece agendar', (tester) async {
    await _montar(tester, tiendaDePrueba());

    await _tocar(tester, 'Instalar en mi cita');

    expect(find.textContaining('No tienes citas'), findsOneWidget);
    expect(find.text('Agendar cita'), findsOneWidget);
  });

  testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await _montar(
        tester,
        tiendaDePrueba(),
        citas: [cita()],
        escenario: escenario,
      );
      await _tocar(tester, 'Instalar en mi cita');
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
        const PantallaCarrito(),
        repositorio: tiendaDePrueba(),
        escenario: Escenario.letraGrande,
        ancho: 320,
      ),
    );
    carritoDe(tester, PantallaCarrito).agregar(tapetes, 2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
