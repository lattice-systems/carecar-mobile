import 'package:carecar_mobile/api/modelos/modelo_catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/navegacion/enlaces.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_tienda.dart';

Future<ControladorSesion> _montar(
  WidgetTester tester, {
  bool conSesion = true,
  bool conCatalogo = true,
}) async {
  pantallaAlta(tester);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa();
  if (conCatalogo) {
    api.modelosCatalogo = const [ModeloCatalogo(id: 1, modelo: 'CX-5')];
  }
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      idioma: const Locale('es'),
      overrides: sustitutos(
        repositorio: tiendaDePrueba(pedidos: [pedido()]),
        // La más próxima es del Jetta, al que no le quedan los tapetes.
        citas: [cita(id: 40, dia: 27, vehiculoId: 6), cita()],
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sesion;
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  enrutadorDe(tester).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el catalogo abre la tienda', (tester) async {
    await _montar(tester);
    await _ir(tester, rutaCatalogo);

    await _tocar(tester, 'Tienda');

    expect(find.byType(PantallaTienda), findsOneWidget);
  });

  testWidgets('con el catalogo vacio la tienda sigue a la mano', (
    tester,
  ) async {
    await _montar(tester, conCatalogo: false);
    await _ir(tester, rutaCatalogo);

    await _tocar(tester, 'Tienda');

    expect(find.byType(PantallaTienda), findsOneWidget);
  });

  testWidgets('de la tienda al producto, al carrito y al pedido', (
    tester,
  ) async {
    await _montar(tester);
    await _ir(tester, rutaTienda);

    await _tocar(tester, 'Tapetes de uso rudo');
    expect(find.byType(PantallaProducto), findsOneWidget);

    await _tocar(tester, 'Instalar en mi próxima cita');
    expect(find.byType(PantallaCarrito), findsOneWidget);
    // La cita más próxima ya viene elegida.
    expect(find.text('Elegida'), findsOneWidget);
    final carrito = ProviderScope.containerOf(
      tester.element(find.byType(PantallaCarrito)),
    ).read(carritoProvider);
    expect(carrito.citaId, 31);

    await _tocar(tester, 'Apartar');
    await _tocar(tester, 'Pagar en caja');
    expect(find.byType(PantallaPedido), findsOneWidget);
  });

  testWidgets('Mis pedidos se abre desde la tienda', (tester) async {
    await _montar(tester);
    await _ir(tester, rutaTienda);

    await tester.tap(find.byTooltip('Mis pedidos'));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaMisPedidos), findsOneWidget);
  });

  testWidgets('el enlace profundo de un pedido lo abre', (tester) async {
    await _montar(tester);
    final interna = EnlacesApp.aRutaInterna(
      Uri.parse('carecar://tienda/pedidos/7'),
    );
    expect('$interna', rutaPedido(7));

    await _ir(tester, '$interna');

    expect(
      tester.widget<PantallaPedido>(find.byType(PantallaPedido)).pedidoId,
      7,
    );
  });

  testWidgets('un id que no es numero cae en no encontrado', (tester) async {
    await _montar(tester);

    await _ir(tester, '$rutaMisPedidos/abc');

    expect(find.text('No encontramos ese pedido'), findsOneWidget);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);

    await _ir(tester, rutaTienda);

    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('cerrar sesion vacia el carrito', (tester) async {
    final sesion = await _montar(tester);
    await _ir(tester, rutaTienda);
    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(PantallaTienda)),
    );
    contenedor.read(carritoProvider.notifier).agregar(tapetes, 1);
    await tester.pumpAndSettle();
    expect(find.text('Ver carrito (1)'), findsOneWidget);

    await sesion.cerrarSesion();
    await tester.pumpAndSettle();

    expect(contenedor.read(carritoProvider).vacio, isTrue);
  });
}
