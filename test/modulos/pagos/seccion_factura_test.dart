import 'dart:convert';

import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pago.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_perfil_fiscal.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/seccion_factura.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaPago(pagoId: 7);

Future<void> _tocar(WidgetTester tester, Finder boton) async {
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  group('la factura de un pago (V2-M08.06)', () {
    pruebaPagos('timbrada: folio, folio fiscal, receptor y aviso simulado', (
      tester,
    ) async {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(
            pagos: [
              pagoDeEjemplo(perfilFiscalId: 10, factura: facturaDeEjemplo),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Factura'), findsOneWidget);
      expect(find.widgetWithText(Insignia, 'Timbrada'), findsOneWidget);
      expect(find.text('Factura A-000124'), findsOneWidget);
      expect(find.text('6F1C2A3B-4D5E-4F60-8A7B-000000000001'), findsOneWidget);
      expect(find.text('Folio fiscal'), findsOneWidget);
      expect(find.text('GODE561231GR8 · DOLORES GÓMEZ'), findsOneWidget);
      expect(find.text('Receptor · uso G03'), findsOneWidget);
      expect(find.textContaining('sin validez fiscal'), findsOneWidget);
      expect(find.byKey(SeccionFactura.botonFacturar), findsNothing);
    });

    pruebaPagos('comparte el PDF y el XML con su nombre', (tester) async {
      final compartidos = <ArchivoFactura>[];
      final repo = repoCobro(
        pagos: [pagoDeEjemplo(perfilFiscalId: 10, factura: facturaDeEjemplo)],
      );
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repo,
          extra: [
            compartirFacturaProvider.overrideWithValue(
              (archivo) async => compartidos.add(archivo),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _tocar(tester, find.byKey(SeccionFactura.botonPdf));
      await _tocar(tester, find.byKey(SeccionFactura.botonXml));

      expect(repo.descargas, [
        (1, FormatoFactura.pdf),
        (1, FormatoFactura.xml),
      ]);
      expect(compartidos.map((a) => a.nombre), [
        'factura-A-000124.pdf',
        'factura-A-000124.xml',
      ]);
      expect(compartidos.first.formato.tipoContenido, 'application/pdf');
      expect(utf8.decode(compartidos.last.bytes), contains('Version="4.0"'));
    });

    pruebaPagos('si no se descarga lo dice y se puede volver a intentar', (
      tester,
    ) async {
      final repo = repoCobro(
        pagos: [pagoDeEjemplo(perfilFiscalId: 10, factura: facturaDeEjemplo)],
      )..fallaAlFacturar = Exception('caida');
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repo,
          extra: [compartirFacturaProvider.overrideWithValue((_) async {})],
        ),
      );
      await tester.pumpAndSettle();

      await _tocar(tester, find.byKey(SeccionFactura.botonPdf));
      expect(
        find.text('No se pudo descargar la factura. Intenta otra vez.'),
        findsOneWidget,
      );

      repo.fallaAlFacturar = null;
      await _tocar(tester, find.byKey(SeccionFactura.botonPdf));
      expect(
        find.text('No se pudo descargar la factura. Intenta otra vez.'),
        findsNothing,
      );
      expect(repo.descargas, [(1, FormatoFactura.pdf)]);
    });

    pruebaPagos('sin factura se timbra con los datos predeterminados', (
      tester,
    ) async {
      final repo = repoCobro(pagos: [pagoDeEjemplo(facturable: true)]);
      await tester.pumpWidget(
        appCobro(_pantalla, repo, fiscales: repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      expect(find.text('GODE561231GR8 · DOLORES GÓMEZ'), findsOneWidget);
      await _tocar(tester, find.byKey(SeccionFactura.botonFacturar));

      expect(repo.facturasPedidas, [(7, 10)]);
      expect(find.widgetWithText(Insignia, 'Timbrada'), findsOneWidget);
      expect(find.text('Factura A-000124'), findsOneWidget);
      expect(find.byKey(SeccionFactura.botonFacturar), findsNothing);
    });

    pruebaPagos('propone los datos fiscales que se eligieron al pagar', (
      tester,
    ) async {
      final repo = repoCobro(
        pagos: [pagoDeEjemplo(facturable: true, perfilFiscalId: 11)],
      );
      await tester.pumpWidget(
        appCobro(_pantalla, repo, fiscales: repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      await _tocar(tester, find.byKey(SeccionFactura.botonFacturar));

      expect(repo.facturasPedidas, [(7, 11)]);
    });

    pruebaPagos('si el timbrado rechaza el perfil dice que corregir y lleva a '
        'editarlo', (tester) async {
      final repo = repoCobro(pagos: [pagoDeEjemplo(facturable: true)])
        ..rechazoDeTimbrado = {'razonSocial', 'codigoPostal'};
      await tester.pumpWidget(
        appCobroEnrutada(repo, inicial: rutaPago(7), fiscales: repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      await _tocar(tester, find.byKey(SeccionFactura.botonFacturar));

      expect(
        find.text('El timbrado rechazó tus datos fiscales.'),
        findsOneWidget,
      );
      expect(find.textContaining('sin el régimen societario'), findsOneWidget);
      expect(find.textContaining('código postal'), findsOneWidget);
      expect(find.byKey(SeccionFactura.botonFacturar), findsOneWidget);

      await _tocar(tester, find.byKey(SeccionFactura.botonCorregir));

      final perfil = tester.widget<PantallaPerfilFiscal>(
        find.byType(PantallaPerfilFiscal),
      );
      expect(perfil.perfilId, 10);
    });

    pruebaPagos('si ya tenia factura lo dice y la muestra', (tester) async {
      final repo = repoCobro(pagos: [pagoDeEjemplo(facturable: true)])
        ..fallaAlFacturar = const FacturaRechazada(
          MotivoRechazoFactura.yaFacturado,
        );
      await tester.pumpWidget(
        appCobro(_pantalla, repo, fiscales: repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      await _tocar(tester, find.byKey(SeccionFactura.botonFacturar));

      expect(find.text('Este pago ya tiene factura.'), findsOneWidget);
    });

    pruebaPagos('sin datos fiscales lleva a darlos de alta', (tester) async {
      await tester.pumpWidget(
        appCobroEnrutada(
          repoCobro(pagos: [pagoDeEjemplo(facturable: true)]),
          inicial: rutaPago(7),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Para facturar este pago agrega tus datos fiscales.'),
        findsOneWidget,
      );
      expect(find.byKey(SeccionFactura.botonFacturar), findsNothing);

      await _tocar(tester, find.byKey(SeccionFactura.botonAgregarPerfil));

      final perfil = tester.widget<PantallaPerfilFiscal>(
        find.byType(PantallaPerfilFiscal),
      );
      expect(perfil.perfilId, isNull);
    });

    pruebaPagos('un pago en caja se factura en la agencia', (tester) async {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(pagos: [pagoDeEjemplo(medio: MedioPago.caja)]),
          fiscales: repoDeEjemplo(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Los pagos en caja se facturan en la agencia.'),
        findsOneWidget,
      );
      expect(find.byKey(SeccionFactura.botonFacturar), findsNothing);
    });

    pruebaPagos('un pago fallido no ofrece factura', (tester) async {
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
          fiscales: repoDeEjemplo(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Factura'), findsNothing);
    });

    pruebaPagos('factura.timbrada la muestra sola', (tester) async {
      final eventos = EventosEnVivoFake();
      final repo = repoCobro(pagos: [pagoDeEjemplo(facturable: true)]);
      await tester.pumpWidget(
        appCobro(_pantalla, repo, fiscales: repoDeEjemplo(), eventos: eventos),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SeccionFactura.botonFacturar), findsOneWidget);

      await repo.facturar(7, perfilFiscalId: 10);
      eventos.emitir('factura.timbrada', {'facturaId': 1, 'pagoId': 7});
      await tester.pumpAndSettle();

      expect(find.text('Factura A-000124'), findsOneWidget);
      expect(find.byKey(SeccionFactura.botonFacturar), findsNothing);
    });

    testWidgets('timbrada y por facturar pasan las guias en 320', (
      tester,
    ) async {
      telefonoChicoYAlto(tester);
      for (final pago in [
        pagoDeEjemplo(perfilFiscalId: 10, factura: facturaDeEjemplo),
        pagoDeEjemplo(facturable: true),
      ]) {
        for (final escenario in Escenario.values) {
          await tester.pumpWidget(
            appCobro(
              _pantalla,
              repoCobro(pagos: [pago]),
              fiscales: repoDeEjemplo(),
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
      }
    });
  });
}
