// V2-M14.04: pagar un pedido de la tienda con la misma pantalla, el mismo
// repositorio y las mismas tarjetas de prueba que una orden (V2-M08.02), y
// verlo en Mis pagos como «Pedido N».
import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/pagos/datos/lectura_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_api.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_mis_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pagar_orden.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_datos_fiscales.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pagoDePedido = {
  'id': 12,
  'ordenId': null,
  'pedidoId': 7,
  'vehiculoId': null,
  'monto': 1700.0,
  'moneda': 'MXN',
  'medio': 'TARJETA',
  'marca': 'VISA',
  'ultimos4': '4242',
  'tipoTarjeta': 'CREDITO',
  'estado': 'PAGADO',
  'motivoFallo': null,
  'requiereAutenticacion': false,
  'referencia': 'sim_pi_abc',
  'simulado': true,
  'metodoPagoId': 1,
  'perfilFiscalId': null,
  'pagadoEn': '2026-11-26T18:00:00Z',
  'creadoEn': '2026-11-26T18:00:00Z',
};

final _pagoDeOrden = <String, Object?>{
  ..._pagoDePedido,
  'ordenId': 41,
  'pedidoId': null,
  'vehiculoId': 9,
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _conflicto(String codigo) => _json(409, {
  'timestamp': '2026-11-26T18:00:00Z',
  'status': 409,
  'error': 'Conflict',
  'message': 'No',
  'codigo': codigo,
  'path': '/api/v1/app/pedidos/7/pagos',
});

RepositorioPagosApi _repo(http.Response Function(http.Request) f) =>
    RepositorioPagosApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

const _pedidoListo = PedidoPorPagar(pedidoId: 7, total: 1700, pagable: true);

RepositorioPagosFake _repoPedido({
  PedidoPorPagar pedido = _pedidoListo,
  List<Pago> pagos = const [],
  List<MetodoPago> metodos = const [visaGuardada],
}) => RepositorioPagosFake(
  pedidos: {pedido.pedidoId: pedido},
  pagos: pagos,
  metodos: metodos,
);

Pago _pagoDelPedido({EstadoPago estado = EstadoPago.pagado}) => Pago(
  id: 12,
  ordenId: null,
  pedidoId: 7,
  vehiculoId: null,
  monto: 1700,
  medio: MedioPago.tarjeta,
  marca: 'VISA',
  ultimos4: '4242',
  estado: estado,
  requiereAutenticacion: false,
  referencia: 'sim_pi_12',
  simulado: true,
  creadoEn: DateTime.utc(2026, 11, 26, 19),
  pagadoEn: estado == EstadoPago.pagado ? DateTime.utc(2026, 11, 26, 19) : null,
);

Future<void> _montar(WidgetTester tester, RepositorioPagosFake repo) async {
  await tester.pumpWidget(
    appCobro(const PantallaPagarPedido(pedidoId: 7), repo),
  );
  await tester.pumpAndSettle();
}

Future<void> _pagar(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(FormularioPago.botonPagar));
  await tester.tap(find.byKey(FormularioPago.botonPagar));
  await tester.pumpAndSettle();
}

/// Mis pagos con las rutas de pagos y un pedido de mentira, para probar que
/// un pago de pedido lleva a su pedido.
Widget _enrutada(RepositorioPagosFake repo, {required String inicial}) =>
    ProviderScope(
      overrides: [
        repositorioPagosProvider.overrideWithValue(repo),
        repositorioDatosFiscalesProvider.overrideWithValue(
          repoDeEjemplo(perfiles: const []),
        ),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        hoyPagosProvider.overrideWithValue(() => hoyDePrueba),
        proteccionDeCapturaProvider.overrideWithValue(
          ProteccionDeCapturaFake(),
        ),
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
              path: '/tienda/pedidos/:pedidoId',
              builder: (_, state) => Scaffold(
                body: Text('pedido ${state.pathParameters['pedidoId']}'),
              ),
            ),
            ...rutasPagos,
          ],
        ),
      ),
    );

void main() {
  group('datos (V2-M14.04)', () {
    test('un Pago de pedido trae pedidoId y orden y vehiculo nulos', () {
      const lectura = LecturaPagos();

      final dePedido = lectura.pago(_pagoDePedido);
      final deOrden = lectura.pago(_pagoDeOrden);

      expect(dePedido.pedidoId, 7);
      expect(dePedido.ordenId, isNull);
      expect(dePedido.vehiculoId, isNull);
      expect(deOrden.pedidoId, isNull);
      expect(deOrden.ordenId, 41);
      expect(deOrden.vehiculoId, 9);
    });

    test('un Pago de antes de 2.25.0, sin pedidoId, se sigue leyendo', () {
      final viejo = Map.of(_pagoDeOrden)..remove('pedidoId');

      expect(const LecturaPagos().pago(viejo).pedidoId, isNull);
    });

    test(
      'paga el pedido con la llave y el mismo cuerpo que una orden',
      () async {
        late http.Request pedida;
        final pago =
            await _repo((req) {
              pedida = req;
              return _json(201, _pagoDePedido);
            }).pagarPedido(
              7,
              llave: 'llave-123456',
              medio: const TarjetaNueva(
                token: 'tok_sim_visa',
                mesVence: 12,
                anioVence: 2028,
                guardar: false,
              ),
            );

        expect(pedida.method, 'POST');
        expect(pedida.url.path, '/api/v1/app/pedidos/7/pagos');
        expect(pedida.headers['Idempotency-Key'], 'llave-123456');
        expect(jsonDecode(pedida.body), {
          'tarjeta': {
            'token': 'tok_sim_visa',
            'mesVence': 12,
            'anioVence': 2028,
          },
          'guardarTarjeta': false,
          'perfilFiscalId': null,
        });
        expect(pago.pedidoId, 7);
        expect(pago.estado, EstadoPago.pagado);
      },
    );

    test('lee lo que se cobra del pedido de la tienda', () async {
      late http.Request pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(200, {
          'id': 7,
          'estado': 'apartado',
          'total': 1700.0,
          'pagable': false,
          'pago': _pagoDePedido,
          'pagadoEn': '2026-11-26T18:00:00Z',
        });
      });

      final pedido = await repo.pedido(7);

      expect(pedida.url.path, '/api/v1/app/tienda/pedidos/7');
      expect(pedido.total, 1700);
      expect(pedido.pagable, isFalse);
      expect(pedido.pago?.pedidoId, 7);
    });

    test('sin pago el pedido lo trae nulo', () async {
      final pedido = await _repo(
        (_) => _json(200, {'id': 7, 'total': 1700.0, 'pagable': true}),
      ).pedido(7);

      expect(pedido.pagable, isTrue);
      expect(pedido.pago, isNull);
    });

    test(
      'PEDIDO_NO_PAGABLE y PAGO_EN_CURSO llegan como PagoRechazado',
      () async {
        for (final (codigo, motivo) in [
          ('PEDIDO_NO_PAGABLE', MotivoRechazoPago.pedidoNoPagable),
          ('PAGO_EN_CURSO', MotivoRechazoPago.pagoEnCurso),
        ]) {
          await expectLater(
            _repo((_) => _conflicto(codigo)).pagarPedido(
              7,
              llave: 'llave-123456',
              medio: const TarjetaGuardada(1),
            ),
            throwsA(
              isA<PagoRechazado>().having((e) => e.motivo, 'motivo', motivo),
            ),
          );
        }
      },
    );
  });

  group('el repositorio falso cobra pedidos como el simulador', () {
    test('la misma llave no cobra dos veces y queda pagado', () async {
      final repo = _repoPedido();

      final primero = await repo.pagarPedido(
        7,
        llave: 'llave-1',
        medio: const TarjetaGuardada(1),
      );
      final otraVez = await repo.pagarPedido(
        7,
        llave: 'llave-1',
        medio: const TarjetaGuardada(1),
      );

      expect(otraVez.id, primero.id);
      expect(repo.pagosActuales, hasLength(1));
      expect(primero.pedidoId, 7);
      expect(primero.ordenId, isNull);
      expect(primero.monto, 1700);
      final pedido = await repo.pedido(7);
      expect(pedido.pagable, isFalse);
      expect(pedido.pago?.id, primero.id);
    });

    test('un pedido que no se puede pagar se rechaza', () async {
      final repo = _repoPedido(
        pedido: const PedidoPorPagar(pedidoId: 7, total: 1700, pagable: false),
      );

      await expectLater(
        repo.pagarPedido(7, llave: 'llave-1', medio: const TarjetaGuardada(1)),
        throwsA(
          isA<PagoRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoPago.pedidoNoPagable,
          ),
        ),
      );
    });

    test('un 3-D Secure pendiente bloquea otro intento', () async {
      final repo = _repoPedido(
        pagos: [_pagoDelPedido(estado: EstadoPago.pendiente)],
      );

      await expectLater(
        repo.pagarPedido(7, llave: 'llave-2', medio: const TarjetaGuardada(1)),
        throwsA(
          isA<PagoRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoPago.pagoEnCurso,
          ),
        ),
      );
    });
  });

  group('pantalla de pago del pedido', () {
    pruebaPagos('muestra el total del pedido y paga con la predeterminada', (
      tester,
    ) async {
      final repo = _repoPedido();
      await _montar(tester, repo);

      expect(find.text('Pagar pedido'), findsWidgets);
      expect(find.text('Pedido 7'), findsOneWidget);
      expect(find.textContaining('Pago simulado'), findsOneWidget);
      expect(find.text(r'Pagar $1,700.00'), findsOneWidget);

      await _pagar(tester);

      expect(repo.mediosRecibidos.single, isA<TarjetaGuardada>());
      expect(repo.pagosActuales.single.pedidoId, 7);
      expect(find.text('¡Pedido pagado!'), findsOneWidget);
    });

    pruebaPagos('usa las mismas tarjetas de prueba que una orden', (
      tester,
    ) async {
      final repo = _repoPedido(metodos: const []);
      await _montar(tester, repo);

      final prueba = find.byKey(
        const ValueKey('prueba-tok_sim_fondos_insuficientes'),
      );
      await tester.ensureVisible(prueba);
      await tester.tap(prueba);
      await tester.pump();
      await escribir(tester, FormularioPago.campoVencimiento, '1228');
      await escribir(tester, FormularioPago.campoCvv, '123');
      await _pagar(tester);

      expect(find.text('No se pudo pagar'), findsOneWidget);
      expect(repo.pagosActuales.single.estado, EstadoPago.fallido);
    });

    pruebaPagos('ya pagado lo dice con la tarjeta', (tester) async {
      await _montar(tester, _repoPedido(pagos: [_pagoDelPedido()]));

      expect(find.text('Este pedido ya está pagado'), findsOneWidget);
      expect(find.textContaining('Visa •••• 4242'), findsOneWidget);
      expect(find.byKey(FormularioPago.botonPagar), findsNothing);
    });

    pruebaPagos('si ya no se puede pagar lo explica', (tester) async {
      await _montar(
        tester,
        _repoPedido(
          pedido: const PedidoPorPagar(
            pedidoId: 7,
            total: 1700,
            pagable: false,
          ),
        ),
      );

      expect(
        find.text('Este pedido ya no se puede pagar en la app'),
        findsOneWidget,
      );
      expect(find.byKey(FormularioPago.botonPagar), findsNothing);
    });

    pruebaPagos('el pago en curso se explica como del pedido', (tester) async {
      final repo = _repoPedido()
        ..fallaAlPagar = const PagoRechazado(MotivoRechazoPago.pagoEnCurso);
      await _montar(tester, repo);

      await _pagar(tester);

      expect(find.textContaining('pago de este pedido'), findsOneWidget);
    });

    pruebaPagos('sin conexion al cargar se puede reintentar', (tester) async {
      final repo = _repoPedido()..falla = const SinConexion('sin red');
      await _montar(tester, repo);

      expect(find.byType(EstadoError), findsOneWidget);
      repo.falla = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text(r'Pagar $1,700.00'), findsOneWidget);
    });

    pruebaPagos('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          appCobro(
            const PantallaPagarPedido(pedidoId: 7),
            _repoPedido(),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: escenario.name);
        await auditarAccesibilidad(tester);
      }
    });
  });

  group('Mis pagos con pagos de pedidos', () {
    pruebaPagos('un pago de pedido se ve como Pedido N y abre el pedido', (
      tester,
    ) async {
      final repo = repoCobro(pagos: [_pagoDelPedido(), pagoDeEjemplo()]);
      await tester.pumpWidget(_enrutada(repo, inicial: rutaMisPagos));
      await tester.pumpAndSettle();

      expect(find.text('Pedido 7'), findsOneWidget);
      expect(find.text('Orden 41'), findsOneWidget);

      await tester.tap(find.text('Pedido 7'));
      await tester.pumpAndSettle();

      expect(find.text('pedido 7'), findsOneWidget);
    });

    pruebaPagos('el detalle de un pago de pedido lleva al pedido', (
      tester,
    ) async {
      final repo = repoCobro(pagos: [_pagoDelPedido()]);
      await tester.pumpWidget(_enrutada(repo, inicial: rutaPago(12)));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaPago), findsOneWidget);
      expect(find.text('Pedido 7'), findsOneWidget);
      expect(find.text('Ver el ticket'), findsNothing);

      await tester.ensureVisible(find.text('Ver el pedido'));
      await tester.tap(find.text('Ver el pedido'));
      await tester.pumpAndSettle();

      expect(find.text('pedido 7'), findsOneWidget);
    });

    pruebaPagos('sin pagos de pedido sigue igual', (tester) async {
      await tester.pumpWidget(
        appCobro(const PantallaMisPagos(), repoCobro(pagos: const [])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EstadoVacio), findsOneWidget);
    });
  });
}
