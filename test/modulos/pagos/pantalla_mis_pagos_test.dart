import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_metodos_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_mis_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaMisPagos();

final _dos = [
  pagoDeEjemplo(id: 8, ordenId: 42, creadoEn: DateTime.utc(2026, 11, 26, 19)),
  pagoDeEjemplo(
    estado: EstadoPago.fallido,
    motivo: MotivoFalloPago.fondosInsuficientes,
    ultimos4: '9995',
  ),
];

Future<void> _montar(
  WidgetTester tester,
  RepositorioPagosFake repo, {
  EventosEnVivoFake? eventos,
}) async {
  await tester.pumpWidget(appCobro(_pantalla, repo, eventos: eventos));
  await tester.pumpAndSettle();
}

void main() {
  pruebaPagos('lista cada pago con orden, estado, tarjeta y monto', (
    tester,
  ) async {
    await _montar(tester, repoCobro(pagos: _dos));

    expect(find.text('Mis pagos'), findsWidgets);
    expect(find.text('Orden 42'), findsOneWidget);
    expect(find.text('Orden 41'), findsOneWidget);
    expect(find.textContaining('Pagado · Visa •••• 4242'), findsOneWidget);
    expect(find.textContaining('Fallido · Visa •••• 9995'), findsOneWidget);
    expect(find.text(r'$1,650.00'), findsNWidgets(2));
    expect(find.textContaining('no se cobró nada'), findsOneWidget);
  });

  pruebaPagos('el lector oye el monto con su estado', (tester) async {
    await _montar(tester, repoCobro(pagos: _dos));
    expect(
      find.bySemanticsLabel(RegExp(r'Orden 41.*\$1,650\.00, Fallido')),
      findsOneWidget,
    );
  });

  pruebaPagos('sin pagos lo dice', (tester) async {
    await _montar(tester, repoCobro());

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes pagos'), findsOneWidget);
  });

  pruebaPagos('si falla se puede reintentar', (tester) async {
    final repo = repoCobro(pagos: _dos)..falla = const SinConexion('sin red');
    await _montar(tester, repo);

    expect(find.byType(EstadoError), findsOneWidget);
    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Orden 42'), findsOneWidget);
  });

  pruebaPagos('pago.confirmado la recarga sin pasar por carga', (tester) async {
    final eventos = EventosEnVivoFake();
    final repo = repoCobro(metodos: [visaGuardada]);
    await _montar(tester, repo, eventos: eventos);
    expect(find.text('Aún no tienes pagos'), findsOneWidget);

    await repo.pagar(
      41,
      llave: 'llave-de-prueba-1',
      medio: const TarjetaGuardada(1),
    );
    eventos.emitir('pago.confirmado', {'pagoId': 1, 'ordenId': 41});
    await tester.pumpAndSettle();

    expect(find.text('Orden 41'), findsOneWidget);
  });

  pruebaPagos('pide la pagina siguiente al llegar al final', (tester) async {
    final muchos = [
      for (var i = 1; i <= 25; i++)
        pagoDeEjemplo(id: 100 + i, ordenId: 100 + i),
    ];
    final repo = repoCobro(pagos: muchos);
    await _montar(tester, repo);
    await tester.scrollUntilVisible(
      find.text('Orden 125'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(repo.paginasPedidas, [0, 1]);
    expect(find.text('Orden 125'), findsOneWidget);
  });

  pruebaPagos('tocar un pago abre su detalle', (tester) async {
    await tester.pumpWidget(
      appCobroEnrutada(repoCobro(pagos: _dos), inicial: rutaMisPagos),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Orden 41'));
    await tester.pumpAndSettle();
    expect(tester.widget<PantallaPago>(find.byType(PantallaPago)).pagoId, 7);
  });

  pruebaPagos('el boton de tarjetas abre los metodos de pago', (tester) async {
    await tester.pumpWidget(
      appCobroEnrutada(repoCobro(pagos: _dos), inicial: rutaMisPagos),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(PantallaMisPagos.botonMetodos));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMetodosPago), findsOneWidget);
  });

  testWidgets('en 320 pasa las guias y no se desborda con letra grande', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(pagos: _dos),
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
