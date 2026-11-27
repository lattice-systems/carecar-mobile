import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/confirmar_con_el_banco.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_pagar_orden.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaPagarOrden(ordenId: 41);

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

Future<void> _pagar(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(FormularioPago.botonPagar));
  await tester.tap(find.byKey(FormularioPago.botonPagar));
  await tester.pumpAndSettle();
}

/// Paga y espera a la pantalla del banco: mientras esta abierta el boton
/// sigue cargando, asi que no se espera a que todo se detenga.
Future<void> _pagarHastaElBanco(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(FormularioPago.botonPagar));
  await tester.tap(find.byKey(FormularioPago.botonPagar));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _llenarTarjeta(
  WidgetTester tester,
  String token, {
  bool guardar = false,
}) async {
  final prueba = find.byKey(ValueKey('prueba-$token'));
  await tester.ensureVisible(prueba);
  await tester.tap(prueba);
  await tester.pump();
  await escribir(tester, FormularioPago.campoVencimiento, '1228');
  await escribir(tester, FormularioPago.campoCvv, '123');
  if (guardar) {
    await tester.ensureVisible(find.text('Guardar tarjeta'));
    await tester.tap(find.text('Guardar tarjeta'));
    await tester.pump();
  }
}

String _texto(WidgetTester tester, Key campo) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(campo),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

void main() {
  pruebaPagos('muestra el desglose, dice que es simulado y paga con la '
      'tarjeta predeterminada', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada]);
    await _montar(tester, repo);

    expect(find.text('Pagar orden'), findsWidgets);
    expect(find.text('Orden 41'), findsWidgets);
    expect(find.textContaining('Pago simulado'), findsOneWidget);
    expect(find.text(r'$1,200.00'), findsWidgets);
    expect(find.text(r'$227.59'), findsWidgets);
    expect(find.text(r'Pagar $1,650.00'), findsOneWidget);
    expect(find.byKey(FormularioPago.campoNumero), findsNothing);

    await _pagar(tester);

    expect(repo.mediosRecibidos.single, isA<TarjetaGuardada>());
    expect((repo.mediosRecibidos.single as TarjetaGuardada).metodoPagoId, 1);
    expect(find.text('¡Orden pagada!'), findsOneWidget);
    expect(find.textContaining('no se cobró nada'), findsOneWidget);
  });

  pruebaPagos('con otra tarjeta solo manda el token y la puede guardar', (
    tester,
  ) async {
    final repo = repoCobro();
    await _montar(tester, repo);

    await _llenarTarjeta(tester, 'tok_sim_visa', guardar: true);
    expect(_texto(tester, FormularioPago.campoNumero), '4242 4242 4242 4242');
    expect(_texto(tester, FormularioPago.campoVencimiento), '12/28');
    await _pagar(tester);

    final medio = repo.mediosRecibidos.single as TarjetaNueva;
    expect(medio.token, 'tok_sim_visa');
    expect(medio.mesVence, 12);
    expect(medio.anioVence, 2028);
    expect(medio.guardar, isTrue);
    expect(repo.metodosActuales.single.ultimos4, '4242');
    expect(find.text('¡Orden pagada!'), findsOneWidget);
  });

  pruebaPagos('sin datos validos no se cobra y dice que revisar', (
    tester,
  ) async {
    final repo = repoCobro();
    await _montar(tester, repo);

    await escribir(tester, FormularioPago.campoNumero, '4111111111111111');
    await _pagar(tester);

    expect(repo.mediosRecibidos, isEmpty);
    expect(find.text('Revisa los datos de la tarjeta.'), findsOneWidget);
    expect(find.text('Usa una de las tarjetas de prueba.'), findsOneWidget);
    expect(find.text('Escribe el vencimiento.'), findsOneWidget);
    expect(find.text('El CVV tiene 3 dígitos.'), findsOneWidget);
  });

  pruebaPagos('un rechazo explica el motivo y otro intento usa otra llave', (
    tester,
  ) async {
    final repo = repoCobro();
    await _montar(tester, repo);

    await _llenarTarjeta(tester, 'tok_sim_fondos_insuficientes');
    await _pagar(tester);
    expect(find.text('No se pudo pagar'), findsOneWidget);
    expect(
      find.text('Tu banco rechazó la tarjeta por fondos insuficientes.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Intentar otra vez'));
    await tester.pumpAndSettle();
    await _llenarTarjeta(tester, 'tok_sim_visa');
    await _pagar(tester);

    expect(repo.llavesRecibidas, hasLength(2));
    expect(repo.llavesRecibidas.toSet(), hasLength(2));
    expect(find.text('¡Orden pagada!'), findsOneWidget);
  });

  pruebaPagos('si el banco pide confirmar se abre su pantalla', (tester) async {
    final repo = repoCobro();
    await _montar(tester, repo);

    await _llenarTarjeta(tester, 'tok_sim_3ds');
    await _pagarHastaElBanco(tester);
    expect(find.text('Tu banco pide confirmar'), findsOneWidget);
    expect(find.textContaining(r'$1,650.00'), findsWidgets);
    await tester.tap(find.byKey(llaveConfirmarBanco));
    await tester.pumpAndSettle();

    expect(repo.autenticaciones, [true]);
    expect(find.text('¡Orden pagada!'), findsOneWidget);
  });

  pruebaPagos('cancelar en el banco no cobra', (tester) async {
    final repo = repoCobro();
    await _montar(tester, repo);

    await _llenarTarjeta(tester, 'tok_sim_3ds');
    await _pagarHastaElBanco(tester);
    await tester.tap(find.byKey(llaveCancelarBanco));
    await tester.pumpAndSettle();

    expect(repo.autenticaciones, [false]);
    expect(find.text('Tu banco no confirmó el pago.'), findsOneWidget);
  });

  pruebaPagos('sin conexion se reintenta con la misma llave', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada])
      ..fallaAlPagar = const SinConexion('sin red');
    await _montar(tester, repo);

    await _pagar(tester);
    expect(find.textContaining('Sin conexión'), findsOneWidget);

    repo.fallaAlPagar = null;
    await _pagar(tester);

    expect(repo.llavesRecibidas, hasLength(1));
    expect(find.text('¡Orden pagada!'), findsOneWidget);
  });

  pruebaPagos('un pago en curso de la orden se explica', (tester) async {
    final repo = repoCobro(
      metodos: [visaGuardada],
      pagos: [
        pagoDeEjemplo(
          estado: EstadoPago.pendiente,
          requiereAutenticacion: true,
        ),
      ],
    );
    await _montar(tester, repo);

    await _pagar(tester);

    expect(find.textContaining('esperando la confirmación'), findsOneWidget);
  });

  pruebaPagos('factura con los datos fiscales predeterminados', (tester) async {
    final repo = repoCobro(metodos: [visaGuardada]);
    await _montar(tester, repo, conPerfiles: true);

    expect(find.text('Factura'), findsOneWidget);
    await _pagar(tester);

    expect(repo.perfilesRecibidos, [10]);
  });

  pruebaPagos('una orden ya pagada lo dice', (tester) async {
    await _montar(tester, repoCobro(pagos: [pagoDeEjemplo()]));

    expect(find.text('Esta orden ya está pagada'), findsOneWidget);
    expect(find.byKey(FormularioPago.botonPagar), findsNothing);
  });

  pruebaPagos('una orden que no se puede pagar lo explica', (tester) async {
    await _montar(
      tester,
      repoCobro(
        ordenes: [
          OrdenPorPagar(
            ordenId: 41,
            vehiculoId: 9,
            fecha: DateTime(2026, 11, 26),
            totalManoDeObra: 100,
            totalRefacciones: 0,
            subtotal: 86.21,
            iva: 13.79,
            total: 100,
            pagable: false,
          ),
        ],
      ),
    );

    expect(find.text('Esta orden aún no se puede pagar'), findsOneWidget);
  });

  pruebaPagos('si no carga la orden se puede reintentar', (tester) async {
    final repo = repoCobro()..falla = const SinConexion('sin red');
    await _montar(tester, repo);

    expect(find.byType(EstadoError), findsOneWidget);
    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byKey(FormularioPago.botonPagar), findsOneWidget);
  });

  testWidgets('en 320 pasa las guias y no se desborda con letra grande', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        appCobro(
          _pantalla,
          repoCobro(metodos: [visaGuardada]),
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

  testWidgets('la tarjeta nueva tambien pasa las guias en 320', (tester) async {
    telefonoChicoYAlto(tester);
    await tester.pumpWidget(
      appCobro(_pantalla, repoCobro(), ancho: anchoTelefonoChico),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await auditarAccesibilidad(tester);
  });

  testWidgets('la ruta lleva a pagar la orden', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appCobroEnrutada(
        repoCobro(metodos: [visaGuardada]),
        inicial: rutaPagarOrden(41),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaPagarOrden), findsOneWidget);
    expect(find.text(r'Pagar $1,650.00'), findsOneWidget);
  });
}
