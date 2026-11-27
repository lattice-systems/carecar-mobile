import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/pagos.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/privacidad/pantalla_segura.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_cobro.dart';
import 'ayudas_pagos.dart';

Future<ProteccionDeCapturaFake> _montar(
  WidgetTester tester, {
  bool conSesion = true,
  RepositorioPagosFake? pagos,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  final proteccion = ProteccionDeCapturaFake();
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      idioma: const Locale('es'),
      overrides: [
        repositorioDatosFiscalesProvider.overrideWithValue(repoDeEjemplo()),
        repositorioPagosProvider.overrideWithValue(
          pagos ?? repoCobro(pagos: [pagoDeEjemplo()], metodos: [visaGuardada]),
        ),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        proteccionDeCapturaProvider.overrideWithValue(proteccion),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return proteccion;
}

void main() {
  testWidgets('/datos-fiscales abre mis datos fiscales sin capturas', (
    tester,
  ) async {
    final proteccion = await _montar(tester);
    enrutadorDe(tester).go(rutaDatosFiscales);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaDatosFiscales), findsOneWidget);
    expect(find.byType(PantallaSegura), findsOneWidget);
    expect(proteccion.bloqueada, isTrue);
  });

  testWidgets('el alta y la edicion tambien se abren por enlace', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaPerfilFiscalNuevo);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PantallaPerfilFiscal>(find.byType(PantallaPerfilFiscal))
          .perfilId,
      isNull,
    );

    enrutadorDe(tester).go(rutaPerfilFiscal(11));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PantallaPerfilFiscal>(find.byType(PantallaPerfilFiscal))
          .perfilId,
      11,
    );
  });

  testWidgets('al salir se vuelven a permitir las capturas', (tester) async {
    final proteccion = await _montar(tester);
    enrutadorDe(tester).go(rutaDatosFiscales);
    await tester.pumpAndSettle();
    enrutadorDe(tester).go('/');
    await tester.pumpAndSettle();

    expect(proteccion.bloqueada, isFalse);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaDatosFiscales);
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });

  for (final (ruta, pantalla) in [
    (rutaMisPagos, PantallaMisPagos),
    (rutaPago(7), PantallaPago),
    (rutaMetodosPago, PantallaMetodosPago),
    (rutaPagarOrden(41), PantallaPagarOrden),
  ]) {
    testWidgets('$ruta abre su pantalla sin capturas (V2-M08.02)', (
      tester,
    ) async {
      final proteccion = await _montar(tester);
      enrutadorDe(tester).go(ruta);
      await tester.pumpAndSettle();

      expect(find.byType(pantalla), findsOneWidget);
      expect(find.byType(PantallaSegura), findsOneWidget);
      expect(proteccion.bloqueada, isTrue);
    });
  }

  testWidgets('el pago y la orden llegan con su numero', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaPago(7));
    await tester.pumpAndSettle();
    expect(tester.widget<PantallaPago>(find.byType(PantallaPago)).pagoId, 7);

    enrutadorDe(tester).go(rutaPagarOrden(41));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PantallaPagarOrden>(find.byType(PantallaPagarOrden))
          .ordenId,
      41,
    );
  });

  testWidgets('sin sesion mis pagos manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaMisPagos);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });
}
