import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_metodos_pago.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaMetodosPago();

const _debito = MetodoPago(
  id: 3,
  marca: 'VISA',
  ultimos4: '5556',
  tipo: TipoTarjeta.debito,
  mesVence: 6,
  anioVence: 2029,
  vencida: false,
  predeterminado: false,
);

Future<void> _montar(WidgetTester tester, RepositorioPagosFake repo) async {
  await tester.pumpWidget(appCobro(_pantalla, repo));
  await tester.pumpAndSettle();
}

Future<void> _abrir(WidgetTester tester, int metodoId) async {
  await tester.tap(find.byKey(ValueKey('metodo-$metodoId')));
  await tester.pumpAndSettle();
}

List<String> _titulos(WidgetTester tester) => tester
    .widget<GrupoLista>(find.byType(GrupoLista))
    .filas
    .map((f) => f.titulo)
    .toList();

void main() {
  pruebaPagos('lista marca, ultimos 4, vencimiento y tipo; la predeterminada '
      'primero y la vencida marcada', (tester) async {
    await _montar(
      tester,
      repoCobro(metodos: [masterVencida, _debito, visaGuardada]),
    );

    expect(_titulos(tester), [
      'Visa •••• 4242',
      'Mastercard •••• 4444',
      'Visa •••• 5556',
    ]);
    expect(find.text('Vence 12/28 · Crédito'), findsOneWidget);
    expect(find.text('Vence 06/29 · Débito'), findsOneWidget);
    expect(find.widgetWithText(Insignia, 'Predeterminada'), findsOneWidget);
    expect(find.widgetWithText(Insignia, 'Vencida'), findsOneWidget);
    expect(find.textContaining('últimos 4'), findsOneWidget);
  });

  pruebaPagos('el lector oye cual es la predeterminada', (tester) async {
    await _montar(tester, repoCobro(metodos: [visaGuardada, _debito]));
    expect(
      find.bySemanticsLabel(RegExp(r'^Visa •••• 4242\..*\. Predeterminada$')),
      findsOneWidget,
    );
  });

  pruebaPagos('se puede usar otra como predeterminada', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada, _debito]);
    await _montar(tester, repo);

    await _abrir(tester, 3);
    await tester.tap(find.byKey(PantallaMetodosPago.botonPredeterminar));
    await tester.pumpAndSettle();

    expect(_titulos(tester).first, 'Visa •••• 5556');
    expect(
      repo.metodosActuales.firstWhere((m) => m.id == 3).predeterminado,
      isTrue,
    );
  });

  pruebaPagos('la predeterminada solo ofrece borrarse', (tester) async {
    await _montar(tester, repoCobro(metodos: [visaGuardada, _debito]));

    await _abrir(tester, 1);

    expect(find.byKey(PantallaMetodosPago.botonPredeterminar), findsNothing);
    expect(find.byKey(PantallaMetodosPago.botonBorrar), findsOneWidget);
  });

  pruebaPagos('borrar pide confirmar y cancelar no borra', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada, _debito]);
    await _montar(tester, repo);

    await _abrir(tester, 3);
    await tester.tap(find.byKey(PantallaMetodosPago.botonBorrar));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar esta tarjeta?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.borrados, isEmpty);
    expect(_titulos(tester), hasLength(2));
  });

  pruebaPagos('al confirmar se borra y sale de la lista', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada, _debito]);
    await _montar(tester, repo);

    await _abrir(tester, 3);
    await tester.tap(find.byKey(PantallaMetodosPago.botonBorrar));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();

    expect(repo.borrados, [3]);
    expect(_titulos(tester), ['Visa •••• 4242']);
  });

  pruebaPagos('sin tarjetas explica como guardar una', (tester) async {
    await _montar(tester, repoCobro());

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes tarjetas guardadas'), findsOneWidget);
  });

  pruebaPagos('si falla se puede reintentar', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada])
      ..falla = const SinConexion('sin red');
    await _montar(tester, repo);

    expect(find.byType(EstadoError), findsOneWidget);
    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(_titulos(tester), ['Visa •••• 4242']);
  });

  testWidgets('en 320 pasa las guias y no se desborda con letra grande', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(metodos: [visaGuardada, masterVencida, _debito]),
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
