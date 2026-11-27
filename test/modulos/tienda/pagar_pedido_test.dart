// V2-M14.04: pagar mi pedido de la tienda en la app. El pedido dice si se
// puede pagar y con qué se pagó, uno pagado solo se cancela en el mostrador,
// el carrito y el apartado ofrecen pagar ahora o en caja, y `pago.confirmado`
// con `pedidoId` recarga el pedido y la lista sin pasar por carga.
import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/tienda/datos/lectura_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_api.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_fake.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_tienda.dart';

const _pedidoJson = <String, Object?>{
  'id': 7,
  'estado': 'listo',
  'entrega': 'mostrador',
  'total': 1700,
  'creadoEn': '2026-11-26T18:00:00Z',
  'venceEn': '2026-11-28T18:00:00Z',
  'renglones': [
    {
      'productoId': 1,
      'nombre': 'Tapetes de uso rudo',
      'cantidad': 2,
      'precio': 850,
      'importe': 1700,
    },
  ],
};

const _pagoJson = <String, Object?>{
  'id': 12,
  'ordenId': null,
  'pedidoId': 7,
  'vehiculoId': null,
  'monto': 1700.0,
  'moneda': 'MXN',
  'medio': 'TARJETA',
  'marca': 'MASTERCARD',
  'ultimos4': '4444',
  'tipoTarjeta': 'CREDITO',
  'estado': 'PAGADO',
  'motivoFallo': null,
  'requiereAutenticacion': false,
  'referencia': 'sim_pi_abc',
  'simulado': true,
  'metodoPagoId': null,
  'perfilFiscalId': null,
  'pagadoEn': '2026-11-26T19:00:00Z',
  'creadoEn': '2026-11-26T19:00:00Z',
};

// El paso actual de la línea de tiempo «respira» sin fin: no se puede esperar
// a que la pantalla se asiente.
Future<void> _asentar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.tap(find.text(texto));
  await _asentar(tester);
}

Future<void> _detalle(
  WidgetTester tester,
  RepositorioTiendaFake repo, {
  EventosEnVivoFake? eventos,
  Escenario escenario = Escenario.claro,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    app(
      const PantallaPedido(pedidoId: 7),
      repositorio: repo,
      eventos: eventos,
      escenario: escenario,
    ),
  );
  await _asentar(tester);
}

/// Las rutas de la tienda y un pago de mentira en `/pagar-pedido/{id}`: el
/// pago real es de `pagos` y se prueba allá.
Future<void> _enrutada(
  WidgetTester tester,
  RepositorioTiendaFake repo, {
  required String inicial,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        duenoSesionTiendaProvider.overrideWithValue('cliente'),
        ...sustitutos(repositorio: repo),
      ],
      child: MaterialApp.router(
        locale: idiomaBase,
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        theme: TemaPista.claro(),
        routerConfig: GoRouter(
          initialLocation: inicial,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('inicio')),
            ),
            ...rutasTienda,
            GoRoute(
              path: '/pagar-pedido/:pedidoId',
              builder: (_, state) => Scaffold(
                body: Text('pago ${state.pathParameters['pedidoId']}'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await _asentar(tester);
}

/// Sale de la pantalla de pago de mentira, como al tocar «Listo».
Future<void> _volverDelPago(WidgetTester tester, int pedidoId) async {
  GoRouter.of(tester.element(find.text('pago $pedidoId'))).pop();
  await _asentar(tester);
}

void main() {
  group('datos', () {
    test('un pedido sin pago trae pago y pagadoEn nulos', () {
      final p = const LecturaTienda().pedido({
        ..._pedidoJson,
        'pagable': true,
        'pago': null,
        'pagadoEn': null,
      });

      expect(p.pagable, isTrue);
      expect(p.pago, isNull);
      expect(p.pagadoEn, isNull);
      expect(p.pagado, isFalse);
    });

    test('un pedido pagado trae el pago con marca y últimos 4', () {
      final p = const LecturaTienda().pedido({
        ..._pedidoJson,
        'pagable': false,
        'pago': _pagoJson,
        'pagadoEn': '2026-11-26T19:00:00Z',
      });

      expect(p.pagado, isTrue);
      expect(p.pagadoEn, DateTime.utc(2026, 11, 26, 19));
      expect(p.pago?.id, 12);
      expect(p.pago?.marca, 'MASTERCARD');
      expect(p.pago?.ultimos4, '4444');
      expect(p.pagable, isFalse);
    });

    test('un pedido de antes de 2.25.0 no se paga en la app', () {
      final p = const LecturaTienda().pedido(_pedidoJson);

      expect(p.pagable, isFalse);
      expect(p.pagado, isFalse);
    });

    test('cancelar uno pagado llega como rechazo pagado (PEDIDO_PAGADO)', () {
      final repo = RepositorioTiendaApi(
        ClienteApi(
          config: ApiConfig.para('http://local/api/v1/app'),
          obtenerToken: () async => 'token',
          http: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'timestamp': 't',
                'status': 409,
                'error': 'Conflict',
                'message': 'Ya está pagado',
                'codigo': 'PEDIDO_PAGADO',
                'path': '/tienda/pedidos/7/cancelar',
              }),
              409,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
          ),
        ),
      );

      expect(
        repo.cancelar(7),
        throwsA(
          isA<PedidoRechazado>().having(
            (r) => r.motivo,
            'motivo',
            MotivoRechazoPedido.pagado,
          ),
        ),
      );
    });

    test('el falso no cancela uno pagado y sí cambia su instalación', () async {
      final repo = tiendaDePrueba(pedidos: [pedido(pagado: true)]);

      await expectLater(
        repo.cancelar(7),
        throwsA(
          isA<PedidoRechazado>().having(
            (r) => r.motivo,
            'motivo',
            MotivoRechazoPedido.pagado,
          ),
        ),
      );
      final cambiado = await repo.cambiarInstalacion(7, 31);
      expect(cambiado.pagado, isTrue);
      expect(cambiado.entrega, EntregaPedido.cita);
    });
  });

  group('dominio', () {
    test('uno pagado sigue abierto pero no se cancela en la app', () {
      final pagado = pedido(estado: EstadoPedido.listo, pagado: true);
      final sinPagar = pedido(pagable: true);

      expect(pagado.abierto, isTrue);
      expect(pagado.pagado, isTrue);
      expect(pagado.cancelableEnLaApp, isFalse);
      expect(sinPagar.cancelableEnLaApp, isTrue);
      expect(pedido(estado: EstadoPedido.entregado).cancelableEnLaApp, isFalse);
    });
  });

  group('el detalle del pedido', () {
    testWidgets('si se puede pagar ofrece «Pagar \$total» y pagar en caja', (
      tester,
    ) async {
      await _detalle(tester, tiendaDePrueba(pedidos: [pedido(pagable: true)]));

      expect(find.byKey(PantallaPedido.botonPagar), findsOneWidget);
      expect(find.text(r'Pagar $1,700.00'), findsOneWidget);
      expect(
        find.text('Paga en la app desde tu pedido o en caja al recoger.'),
        findsOneWidget,
      );
      expect(find.text('Cancelar pedido'), findsOneWidget);
    });

    testWidgets('si no se puede pagar no ofrece el botón y dice caja', (
      tester,
    ) async {
      await _detalle(tester, tiendaDePrueba(pedidos: [pedido()]));

      expect(find.byKey(PantallaPedido.botonPagar), findsNothing);
      expect(
        find.text('No se cobra en la app: pagas en caja.'),
        findsOneWidget,
      );
    });

    testWidgets('pagado dice con qué, ya no vence y se cancela en mostrador', (
      tester,
    ) async {
      await _detalle(
        tester,
        tiendaDePrueba(
          pedidos: [pedido(estado: EstadoPedido.listo, pagado: true)],
        ),
      );

      expect(find.text('Pagado con Visa •••• 4242'), findsOneWidget);
      expect(find.textContaining('Ya no vence'), findsOneWidget);
      expect(find.textContaining('Vence el'), findsNothing);
      expect(find.byKey(PantallaPedido.botonPagar), findsNothing);
      expect(find.text('Cancelar pedido'), findsNothing);
      expect(
        find.text(
          'Ya está pagado: si necesitas cancelarlo, hazlo en el mostrador.',
        ),
        findsOneWidget,
      );
      // La instalación todavía se puede cambiar.
      expect(find.text('Instalar en mi cita'), findsOneWidget);
    });

    testWidgets('entregado y pagado conserva con qué se pagó', (tester) async {
      await _detalle(
        tester,
        tiendaDePrueba(
          pedidos: [pedido(estado: EstadoPedido.entregado, pagado: true)],
        ),
      );

      expect(find.text('Pagado con Visa •••• 4242'), findsOneWidget);
      expect(find.textContaining('hazlo en el mostrador'), findsNothing);
    });

    testWidgets('PEDIDO_PAGADO al cancelar se explica y recarga', (
      tester,
    ) async {
      final repo = tiendaDePrueba(pedidos: [pedido(pagable: true)]);
      await _detalle(tester, repo);
      repo
        ..pedidosActuales = [pedido(pagado: true)]
        ..fallaAlGuardar = const PedidoRechazado(MotivoRechazoPedido.pagado);

      await _tocar(tester, 'Cancelar pedido');
      await _tocar(tester, 'Sí, cancelar');

      expect(find.textContaining('cancélalo en el mostrador'), findsOneWidget);
      await _tocar(tester, 'Entendido');
      expect(find.text('Cancelar pedido'), findsNothing);
      expect(find.text('Pagado con Visa •••• 4242'), findsOneWidget);
    });

    testWidgets('pago.confirmado de su pedido lo recarga sin pasar por carga', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = tiendaDePrueba(pedidos: [pedido(pagable: true)]);
      await _detalle(tester, repo, eventos: eventos);
      repo.pedidosActuales = [pedido(pagado: true)];

      eventos.emitir('pago.confirmado', {
        'pagoId': 5,
        'ordenId': 41,
        'pedidoId': null,
        'estado': 'PAGADO',
      });
      await _asentar(tester);
      expect(find.text('Pagado con Visa •••• 4242'), findsNothing);

      eventos.emitir('pago.confirmado', {
        'pagoId': 6,
        'ordenId': null,
        'pedidoId': 99,
        'estado': 'PAGADO',
      });
      await _asentar(tester);
      expect(find.text('Pagado con Visa •••• 4242'), findsNothing);

      eventos.emitir('pago.confirmado', {
        'pagoId': 12,
        'ordenId': null,
        'pedidoId': 7,
        'estado': 'PAGADO',
      });
      await tester.pump();
      expect(find.byType(Esqueleto), findsNothing);
      await _asentar(tester);
      expect(find.text('Pagado con Visa •••• 4242'), findsOneWidget);
      expect(find.byKey(PantallaPedido.botonPagar), findsNothing);
    });

    testWidgets('«Pagar» abre el pago del pedido y al volver lo recarga', (
      tester,
    ) async {
      final repo = tiendaDePrueba(pedidos: [pedido(pagable: true)]);
      await _enrutada(tester, repo, inicial: rutaPedido(7));

      await tester.tap(find.byKey(PantallaPedido.botonPagar));
      await _asentar(tester);
      expect(find.text('pago 7'), findsOneWidget);

      repo.pedidosActuales = [pedido(pagado: true)];
      await _volverDelPago(tester, 7);

      expect(find.byType(PantallaPedido), findsOneWidget);
      expect(find.text('Pagado con Visa •••• 4242'), findsOneWidget);
    });

    testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        for (final p in [pedido(pagable: true), pedido(pagado: true)]) {
          await _detalle(
            tester,
            tiendaDePrueba(pedidos: [p]),
            escenario: escenario,
          );
          expect(tester.takeException(), isNull, reason: escenario.name);
          await auditarAccesibilidad(tester);
        }
      }
    });

    testWidgets('en una pantalla chica con letra grande no desborda', (
      tester,
    ) async {
      pantallaChica(tester);
      await tester.pumpWidget(
        app(
          const PantallaPedido(pedidoId: 7),
          repositorio: tiendaDePrueba(pedidos: [pedido(pagable: true)]),
          escenario: Escenario.letraGrande,
          ancho: 320,
        ),
      );
      await _asentar(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('Mis pedidos', () {
    testWidgets('uno pagado dice Pagado en vez de cuándo vence', (
      tester,
    ) async {
      pantallaAlta(tester);
      await tester.pumpWidget(
        app(
          const PantallaMisPedidos(),
          repositorio: tiendaDePrueba(
            pedidos: [pedido(pagado: true), pedido(id: 8, pagable: true)],
          ),
        ),
      );
      await _asentar(tester);

      expect(find.text('Pagado'), findsOneWidget);
      expect(find.textContaining('Vence el'), findsOneWidget);
    });

    testWidgets('pago.confirmado de un pedido la recarga sin pasar por carga', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = tiendaDePrueba(pedidos: [pedido(pagable: true)]);
      pantallaAlta(tester);
      await tester.pumpWidget(
        app(const PantallaMisPedidos(), repositorio: repo, eventos: eventos),
      );
      await _asentar(tester);
      expect(find.text('Pagado'), findsNothing);
      repo.pedidosActuales = [pedido(pagado: true)];

      eventos.emitir('pago.confirmado', {
        'pagoId': 12,
        'ordenId': null,
        'pedidoId': 7,
        'estado': 'PAGADO',
      });
      await tester.pump();
      expect(find.byType(Esqueleto), findsNothing);
      await _asentar(tester);

      expect(find.text('Pagado'), findsOneWidget);
    });
  });

  group('el carrito y el apartado', () {
    testWidgets('el carrito dice que se paga en la app o en caja', (
      tester,
    ) async {
      pantallaAlta(tester);
      await tester.pumpWidget(
        app(const PantallaCarrito(), repositorio: tiendaDePrueba()),
      );
      carritoDe(tester, PantallaCarrito).agregar(tapetes, 2);
      await tester.pumpAndSettle();

      expect(
        find.text('Paga en la app desde tu pedido o en caja al recoger.'),
        findsOneWidget,
      );
      expect(find.text('No se cobra en la app: pagas en caja.'), findsNothing);
    });

    Future<void> apartar(
      WidgetTester tester,
      RepositorioTiendaFake repo,
    ) async {
      await _enrutada(tester, repo, inicial: rutaCarrito);
      carritoDe(tester, PantallaCarrito).agregar(tapetes, 2);
      await _asentar(tester);
      await _tocar(tester, 'Apartar');
    }

    testWidgets('al apartar ofrece «Pagar ahora» y «Pagar en caja»', (
      tester,
    ) async {
      await apartar(tester, tiendaDePrueba());

      expect(find.text('Productos apartados'), findsOneWidget);
      expect(find.textContaining('Págalo ahora en la app'), findsOneWidget);
      expect(find.text('Pagar ahora'), findsOneWidget);
      expect(find.text('Pagar en caja'), findsOneWidget);
    });

    testWidgets('«Pagar ahora» abre el pago y al volver queda en el pedido', (
      tester,
    ) async {
      final repo = tiendaDePrueba();
      await apartar(tester, repo);

      await _tocar(tester, 'Pagar ahora');
      expect(find.text('pago 1'), findsOneWidget);

      final apartado = repo.pedidosActuales.single;
      repo.pedidosActuales = [
        Pedido(
          id: apartado.id,
          estado: apartado.estado,
          entrega: apartado.entrega,
          total: apartado.total,
          creadoEn: apartado.creadoEn,
          renglones: apartado.renglones,
          pagadoEn: pagadoEnPrueba,
          pago: PagoDePedido(
            id: 12,
            marca: 'MASTERCARD',
            ultimos4: '4444',
            pagadoEn: pagadoEnPrueba,
          ),
        ),
      ];
      await _volverDelPago(tester, 1);

      expect(find.byType(PantallaPedido), findsOneWidget);
      expect(find.text('Pagado con Mastercard •••• 4444'), findsOneWidget);
    });

    testWidgets('«Pagar en caja» abre el pedido sin cobrar', (tester) async {
      await apartar(tester, tiendaDePrueba());

      await _tocar(tester, 'Pagar en caja');

      expect(find.byType(PantallaPedido), findsOneWidget);
      expect(find.textContaining('pago '), findsNothing);
      expect(find.byKey(PantallaPedido.botonPagar), findsOneWidget);
    });

    testWidgets('el cierre no desborda con letra grande', (tester) async {
      pantallaAlta(tester);
      await tester.pumpWidget(
        app(
          const PantallaCarrito(),
          repositorio: tiendaDePrueba(),
          escenario: Escenario.letraGrande,
        ),
      );
      carritoDe(tester, PantallaCarrito).agregar(tapetes, 2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apartar'));
      await tester.pumpAndSettle();

      expect(find.text('Pagar ahora'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await auditarAccesibilidad(tester);
    });
  });
}
