import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/confirmar_con_la_billetera.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pagar_orden.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaPagarOrden(ordenId: 41);

Future<void> _tocarBilletera(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(FormularioPago.botonBilletera));
  await tester.tap(find.byKey(FormularioPago.botonBilletera));
  await tester.pumpAndSettle();
}

Future<void> _montar(
  WidgetTester tester,
  RepositorioPagosFake repo, {
  bool conPerfiles = false,
}) async {
  await tester.pumpWidget(
    appCobro(_pantalla, repo, fiscales: conPerfiles ? repoDeEjemplo() : null),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('pagar con la billetera simulada (V2-M08.03)', () {
    pruebaPagos('en Android ofrece Google Pay y paga sin tarjeta', (
      tester,
    ) async {
      final repo = repoCobro();
      await _montar(tester, repo);

      expect(find.text('Pagar con Google Pay'), findsOneWidget);
      expect(find.text('Pagar con Apple Pay'), findsNothing);
      expect(find.textContaining('Billetera simulada'), findsOneWidget);

      await _tocarBilletera(tester);
      expect(find.text('Google Pay (simulado)'), findsOneWidget);
      expect(
        find.text(
          r'Vas a pagar $1,650.00 con Google Pay (simulado). Es simulado: no '
          'se cobra nada.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(llaveConfirmarBilletera));
      await tester.pumpAndSettle();

      final medio = repo.mediosRecibidos.single as Billetera;
      expect(medio.medio, MedioPago.googlePay);
      expect(repo.pagosActuales.single.medio, MedioPago.googlePay);
      expect(repo.autenticaciones, isEmpty);
      expect(find.text('¡Orden pagada!'), findsOneWidget);
    });

    pruebaPagos('en iPhone ofrece Apple Pay', (tester) async {
      final repo = repoCobro();
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repo,
          extra: [
            billeteraDelTelefonoProvider.overrideWithValue(MedioPago.applePay),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pagar con Apple Pay'), findsOneWidget);
      expect(find.text('Pagar con Google Pay'), findsNothing);
      await _tocarBilletera(tester);
      expect(find.text('Apple Pay (simulado)'), findsOneWidget);
      await tester.tap(find.byKey(llaveConfirmarBilletera));
      await tester.pumpAndSettle();

      expect(
        (repo.mediosRecibidos.single as Billetera).medio,
        MedioPago.applePay,
      );
    });

    pruebaPagos('cancelar la hoja de la billetera no cobra', (tester) async {
      final repo = repoCobro();
      await _montar(tester, repo);

      await _tocarBilletera(tester);
      await tester.tap(find.byKey(llaveCancelarBilletera));
      await tester.pumpAndSettle();

      expect(repo.mediosRecibidos, isEmpty);
      expect(find.byKey(FormularioPago.botonPagar), findsOneWidget);
    });

    pruebaPagos('no revisa los campos de la tarjeta', (tester) async {
      final repo = repoCobro();
      await _montar(tester, repo);
      expect(find.byKey(FormularioPago.campoNumero), findsOneWidget);

      await _tocarBilletera(tester);
      await tester.tap(find.byKey(llaveConfirmarBilletera));
      await tester.pumpAndSettle();

      expect(find.textContaining('Revisa'), findsNothing);
      expect(find.text('¡Orden pagada!'), findsOneWidget);
    });

    pruebaPagos('con datos fiscales factura sola y lleva a la factura', (
      tester,
    ) async {
      final repo = repoCobro();
      await tester.pumpWidget(
        appCobroEnrutada(
          repo,
          inicial: rutaPagarOrden(41),
          fiscales: repoDeEjemplo(),
        ),
      );
      await tester.pumpAndSettle();

      await _tocarBilletera(tester);
      await tester.tap(find.byKey(llaveConfirmarBilletera));
      await tester.pumpAndSettle();

      expect(repo.perfilesRecibidos, [10]);
      expect(
        find.textContaining('La factura simulada queda en el detalle'),
        findsOneWidget,
      );
      await tester.tap(find.text('Ver la factura'));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaPago), findsOneWidget);
      expect(find.text('Factura A-000124'), findsOneWidget);
    });

    pruebaPagos('sin datos fiscales el resultado no promete factura', (
      tester,
    ) async {
      final repo = repoCobro();
      await _montar(tester, repo);

      await _tocarBilletera(tester);
      await tester.tap(find.byKey(llaveConfirmarBilletera));
      await tester.pumpAndSettle();

      expect(find.textContaining('factura'), findsNothing);
      expect(find.text('Ver mis pagos'), findsOneWidget);
    });

    testWidgets('el boton pasa las guias y la hoja no se desborda en 320', (
      tester,
    ) async {
      telefonoChicoYAlto(tester);
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          appCobro(
            _pantalla,
            repoCobro(),
            escenario: escenario,
            ancho: anchoTelefonoChico,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: escenario.name);
        if (escenario != Escenario.letraGrande) {
          await auditarAccesibilidad(tester);
        }
        await _tocarBilletera(tester);
        expect(tester.takeException(), isNull, reason: escenario.name);
        await tester.tap(find.byKey(llaveCancelarBilletera));
        await tester.pumpAndSettle();
      }
    });
  });
}
