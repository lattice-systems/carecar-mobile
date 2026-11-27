import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/confirmar_con_el_banco.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaPago(pagoId: 7);

void main() {
  pruebaPagos('muestra estado, monto, tarjeta, fecha y referencia', (
    tester,
  ) async {
    await tester.pumpWidget(
      appCobro(_pantalla, repoCobro(pagos: [pagoDeEjemplo()])),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Insignia, 'Pagado'), findsOneWidget);
    expect(find.text(r'$1,650.00'), findsWidgets);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.text('Pagado el'), findsOneWidget);
    expect(find.text('sim_pi_7'), findsOneWidget);
    expect(find.text('Pago simulado: no se cobró nada.'), findsOneWidget);
    expect(find.text('Confirmar con tu banco'), findsNothing);
  });

  pruebaPagos('un pago fallido dice por que no se cobro', (tester) async {
    await tester.pumpWidget(
      appCobro(
        _pantalla,
        repoCobro(
          pagos: [
            pagoDeEjemplo(
              estado: EstadoPago.fallido,
              motivo: MotivoFalloPago.fondosInsuficientes,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Insignia, 'Fallido'), findsOneWidget);
    expect(find.text('Intentado el'), findsOneWidget);
    expect(
      find.text('Tu banco rechazó la tarjeta por fondos insuficientes.'),
      findsOneWidget,
    );
  });

  pruebaPagos('uno pagado en caja lo dice sin tarjeta', (tester) async {
    await tester.pumpWidget(
      appCobro(
        _pantalla,
        repoCobro(pagos: [pagoDeEjemplo(medio: MedioPago.caja)]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('En caja'), findsOneWidget);
    expect(find.text('Se pagó en la caja de la agencia.'), findsOneWidget);
  });

  pruebaPagos('si espera al banco se confirma desde aqui', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada]);
    final pendiente = await repo.pagar(
      41,
      llave: 'llave-de-prueba-3ds',
      medio: const TarjetaNueva(
        token: 'tok_sim_3ds',
        mesVence: 12,
        anioVence: 2028,
        guardar: false,
      ),
    );
    await tester.pumpWidget(appCobro(PantallaPago(pagoId: pendiente.id), repo));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Insignia, 'Pendiente'), findsOneWidget);

    await tester.tap(find.text('Confirmar con tu banco'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(llaveConfirmarBanco));
    await tester.pumpAndSettle();

    expect(repo.autenticaciones, [true]);
    expect(find.widgetWithText(Insignia, 'Pagado'), findsOneWidget);
    expect(find.text('Confirmar con tu banco'), findsNothing);
  });

  pruebaPagos('pago.confirmado lo actualiza solo', (tester) async {
    final eventos = EventosEnVivoFake();
    final repo = repoCobro();
    final pendiente = await repo.pagar(
      41,
      llave: 'llave-de-prueba-vivo',
      medio: const TarjetaNueva(
        token: 'tok_sim_3ds',
        mesVence: 12,
        anioVence: 2028,
        guardar: false,
      ),
    );
    await tester.pumpWidget(
      appCobro(PantallaPago(pagoId: pendiente.id), repo, eventos: eventos),
    );
    await tester.pumpAndSettle();

    await repo.autenticar(pendiente.id, confirmada: true);
    eventos.emitir('pago.confirmado', {'pagoId': pendiente.id});
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Insignia, 'Pagado'), findsOneWidget);
  });

  pruebaPagos('ver el ticket lleva al ticket de la orden', (tester) async {
    await tester.pumpWidget(
      appCobroEnrutada(
        repoCobro(pagos: [pagoDeEjemplo()]),
        inicial: rutaPago(7),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver el ticket'));
    await tester.tap(find.text('Ver el ticket'));
    await tester.pumpAndSettle();

    expect(find.text('ticket 41'), findsOneWidget);
  });

  pruebaPagos('uno ajeno dice que no se encontro', (tester) async {
    final repo = repoCobro()..falla = const NoEncontrado('No existe');
    await tester.pumpWidget(appCobro(_pantalla, repo));
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('No encontramos este pago'), findsOneWidget);
  });

  pruebaPagos('sin conexion se puede reintentar', (tester) async {
    final repo = repoCobro(pagos: [pagoDeEjemplo()])
      ..falla = const SinConexion('sin red');
    await tester.pumpWidget(appCobro(_pantalla, repo));
    await tester.pumpAndSettle();

    expect(find.byType(EstadoError), findsOneWidget);
    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('sim_pi_7'), findsOneWidget);
  });

  testWidgets('en 320 pasa las guias y no se desborda con letra grande', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(
            pagos: [
              pagoDeEjemplo(
                estado: EstadoPago.fallido,
                motivo: MotivoFalloPago.autenticacionFallida,
              ),
            ],
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
