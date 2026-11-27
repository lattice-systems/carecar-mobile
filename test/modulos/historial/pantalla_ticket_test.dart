import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/dominio/ticket_servicio.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/pantalla_ticket.dart';
import 'package:carecar_mobile/modulos/historial/presentacion/proveedores_historial.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

Widget _app(
  RepositorioHistorialFake repo, {
  Future<void> Function(Uint8List, String)? compartir,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: [
    repositorioHistorialProvider.overrideWithValue(repo),
    compartirTicketProvider.overrideWithValue(
      compartir ?? (bytes, nombre) async {},
    ),
  ],
  child: conTemaPista(
    const PantallaTicket(servicioId: 21),
    escenario: escenario,
    ancho: ancho,
  ),
);

/// El ticket dentro de un enrutador, con una pantalla de pago de mentira para
/// probar que el boton lleva a pagar la orden (V2-M08.02).
Widget _appEnrutada(RepositorioHistorialFake repo) => ProviderScope(
  overrides: [
    repositorioHistorialProvider.overrideWithValue(repo),
    compartirTicketProvider.overrideWithValue((bytes, nombre) async {}),
  ],
  child: MaterialApp.router(
    locale: idiomaBase,
    localizationsDelegates: delegadasDeIdioma,
    supportedLocales: idiomasSoportados,
    theme: TemaPista.claro(),
    routerConfig: GoRouter(
      initialLocation: '/ticket',
      routes: [
        GoRoute(
          path: '/ticket',
          builder: (_, _) => const PantallaTicket(servicioId: 21),
        ),
        GoRoute(
          path: '/pagar-orden/:ordenId',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                Text('pagar ${state.pathParameters['ordenId']}'),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('volver'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);

/// El ticket de ejemplo con su pago o la opcion de pagarlo.
TicketServicio _conPago({PagoDelTicket? pago, bool pagable = false}) {
  final e = ticketDeEjemplo;
  return TicketServicio(
    id: e.id,
    vehiculoId: e.vehiculoId,
    fecha: e.fecha,
    fechaCierre: e.fechaCierre,
    kilometraje: e.kilometraje,
    estatus: e.estatus,
    manoDeObra: e.manoDeObra,
    refacciones: e.refacciones,
    totalManoDeObra: e.totalManoDeObra,
    totalRefacciones: e.totalRefacciones,
    subtotal: e.subtotal,
    iva: e.iva,
    total: e.total,
    pago: pago,
    pagable: pagable,
  );
}

final _pagoConTarjeta = PagoDelTicket(
  id: 7,
  enCaja: false,
  referencia: 'sim_pi_abc123',
  marca: 'VISA',
  ultimos4: '4242',
  pagadoEn: DateTime.utc(2026, 11, 26, 18),
);

const _pagoEnCaja = PagoDelTicket(id: 8, enCaja: true, referencia: 'CAJA-0042');

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('muestra mano de obra y refacciones con cantidad por precio', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.text('Ticket'), findsOneWidget);
    expect(find.text('Cambio de aceite'), findsOneWidget);
    expect(find.text(r'1 × $450.00'), findsOneWidget);
    expect(find.text('Filtro de aceite'), findsOneWidget);
    expect(find.text(r'2 × $175.50'), findsOneWidget);
    expect(find.text(r'$351.00'), findsOneWidget);
    expect(find.text(r'4 × $120.25'), findsOneWidget);
    expect(find.text(r'$481.00'), findsOneWidget);
  });

  _prueba('dice cuantos puntos de lealtad dio la orden', (tester) async {
    final e = ticketDeEjemplo;
    final conPuntos = TicketServicio(
      id: e.id,
      vehiculoId: e.vehiculoId,
      fecha: e.fecha,
      fechaCierre: e.fechaCierre,
      kilometraje: e.kilometraje,
      estatus: e.estatus,
      manoDeObra: e.manoDeObra,
      refacciones: e.refacciones,
      totalManoDeObra: e.totalManoDeObra,
      totalRefacciones: e.totalRefacciones,
      subtotal: e.subtotal,
      iva: e.iva,
      total: e.total,
      puntosGanados: 128,
    );
    await tester.pumpWidget(
      _app(RepositorioHistorialFake(tickets: {21: conPuntos})),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Ganaste 128 puntos de lealtad con este servicio.'),
      findsOneWidget,
    );
  });

  _prueba('sin puntos de lealtad no dice nada de ellos', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.textContaining('puntos de lealtad'), findsNothing);
  });

  _prueba('la mano de obra mas las refacciones dan el total', (tester) async {
    await tester.pumpWidget(_app(RepositorioHistorialFake()));
    await tester.pumpAndSettle();

    expect(find.text(r'$832.00'), findsOneWidget);
    expect(find.text(r'$1,105.17'), findsOneWidget);
    expect(find.text(r'$176.83'), findsOneWidget);
    expect(find.text(r'$1,282.00'), findsOneWidget);
    expect(find.text('Los precios incluyen IVA.'), findsOneWidget);
    expect(find.textContaining('no cuadran'), findsNothing);
  });

  _prueba('comparte el PDF del ticket con su nombre', (tester) async {
    final repo = RepositorioHistorialFake();
    Uint8List? compartido;
    String? nombre;
    await tester.pumpWidget(
      _app(
        repo,
        compartir: (bytes, archivo) async {
          compartido = bytes;
          nombre = archivo;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartir PDF'));
    await tester.pumpAndSettle();

    expect(repo.pdfsPedidos, [21]);
    expect(nombre, 'ticket-21.pdf');
    expect(String.fromCharCodes(compartido!.take(5)), '%PDF-');
  });

  _prueba('si no se puede compartir lo avisa', (tester) async {
    await tester.pumpWidget(
      _app(
        RepositorioHistorialFake(),
        compartir: (bytes, archivo) async => throw const SinConexion(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartir PDF'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos descargar el PDF. Intenta de nuevo.'),
      findsOneWidget,
    );
  });

  _prueba('sin conexion ofrece reintentar', (tester) async {
    final repo = RepositorioHistorialFake()..falla = const SinConexion();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Cambio de aceite'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    _prueba('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioHistorialFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });
  }

  group('pago de la orden (V2-M08.02)', () {
    _prueba('pagada con tarjeta dice Pagado, con que y su referencia', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          RepositorioHistorialFake(
            tickets: {21: _conPago(pago: _pagoConTarjeta)},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pago'), findsOneWidget);
      expect(find.text('Pagado'), findsOneWidget);
      expect(find.textContaining('Visa •••• 4242 · '), findsOneWidget);
      expect(find.text('sim_pi_abc123'), findsOneWidget);
      expect(find.text('Referencia'), findsOneWidget);
      expect(find.byKey(const Key('ticket_pagar')), findsNothing);
    });

    _prueba('pagada en caja lo dice con su referencia', (tester) async {
      await tester.pumpWidget(
        _app(
          RepositorioHistorialFake(tickets: {21: _conPago(pago: _pagoEnCaja)}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En caja'), findsOneWidget);
      expect(find.text('CAJA-0042'), findsOneWidget);
    });

    _prueba('sin pago no muestra el grupo de pago', (tester) async {
      await tester.pumpWidget(_app(RepositorioHistorialFake()));
      await tester.pumpAndSettle();

      expect(find.text('Pago'), findsNothing);
      expect(find.text('Pagado'), findsNothing);
    });

    _prueba('si se puede pagar, el boton lleva a pagar la orden y al volver '
        'se recarga', (tester) async {
      final repo = RepositorioHistorialFake(
        tickets: {21: _conPago(pagable: true)},
      );
      await tester.pumpWidget(_appEnrutada(repo));
      await tester.pumpAndSettle();

      final pagar = find.byKey(const Key('ticket_pagar'));
      await tester.ensureVisible(pagar);
      await tester.tap(pagar);
      await tester.pumpAndSettle();
      expect(find.text('pagar 21'), findsOneWidget);

      repo.cambiarTicket(_conPago(pago: _pagoConTarjeta));
      await tester.tap(find.text('volver'));
      await tester.pumpAndSettle();

      expect(find.text('Pagado'), findsOneWidget);
      expect(find.byKey(const Key('ticket_pagar')), findsNothing);
    });

    _prueba('sin enrutador no ofrece pagar aunque se pueda', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioHistorialFake(tickets: {21: _conPago(pagable: true)})),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ticket_pagar')), findsNothing);
    });
  });

  testWidgets('el ticket pagado pasa las guias de accesibilidad en 320', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(
          RepositorioHistorialFake(
            tickets: {21: _conPago(pago: _pagoConTarjeta)},
          ),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      if (escenario != Escenario.letraGrande) {
        await auditarAccesibilidad(tester);
      }
    }
  });
}
