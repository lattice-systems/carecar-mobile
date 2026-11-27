import 'package:carecar_mobile/notificaciones/recordatorios.dart';
import 'package:carecar_mobile/notificaciones/servicio_notificaciones.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

/// V2-M06.03 · tocar un aviso me lleva a su pantalla.
///
/// Los tres estados del criterio salen de dónde llega el destino:
/// - **app abierta o en segundo plano**: llega un toque, y el servicio avisa.
/// - **app cerrada**: no hay toque que escuchar; el destino ya estaba
///   esperando cuando se armó el enrutador.
///
/// El cuarto criterio -«si requiere login, vuelve al destino tras entrar»- no
/// necesita código nuevo: lo da la guardia con `desde`. Aquí se comprueba.
void main() {
  late ApiFalsa api;
  late ControladorSesion sesion;
  late ServicioNotificaciones avisos;

  setUp(() {
    api = ApiFalsa();
    sesion = ControladorSesion(api, AlmacenEnMemoria());
    avisos = ServicioNotificaciones(PluginNulo(), null);
    Notificaciones.actual = avisos;
  });

  tearDown(() {
    sesion.dispose();
    // El servicio es global: sin esto una prueba le deja basura a la que sigue.
    Notificaciones.actual = ServicioNotificaciones(PluginNulo(), null);
  });

  Future<GoRouter> app(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppEnrutadaDePrueba(
        api: api,
        controlador: sesion,
        idioma: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();
    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    return contenedor.read(enrutadorProvider);
  }

  String donde(GoRouter r) =>
      r.routerDelegate.currentConfiguration.uri.toString();

  Future<void> entrar(WidgetTester tester) async {
    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
    await tester.pumpAndSettle();
  }

  testWidgets('con la app abierta, el toque lleva al destino del aviso', (
    tester,
  ) async {
    final enrutador = await app(tester);
    await entrar(tester);

    avisos.notificarToque(destinoDeCitas);
    await tester.pumpAndSettle();

    expect(donde(enrutador), destinoDeCitas);
  });

  testWidgets('con la app cerrada, el destino esperaba al enrutador', (
    tester,
  ) async {
    // El toque ya pasó: el sistema arrancó la app por el aviso.
    avisos.destinoAlEntrar = destinoDeCitas;
    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    final enrutador = await app(tester);
    await tester.pumpAndSettle();

    expect(donde(enrutador), destinoDeCitas);
  });

  testWidgets('si el destino pide sesión, vuelve ahí después de entrar', (
    tester,
  ) async {
    final enrutador = await app(tester);
    // Sin sesión: la guardia manda al acceso y guarda a dónde iba.
    avisos.notificarToque(destinoDeCitas);
    await tester.pumpAndSettle();

    expect(pantallaDeAcceso, findsOneWidget);
    expect(donde(enrutador), contains(Rutas.parametroDesde));

    await entrar(tester);

    expect(donde(enrutador), destinoDeCitas);
  });

  testWidgets('un aviso sin destino no mueve a nadie de su lugar', (
    tester,
  ) async {
    final enrutador = await app(tester);
    await entrar(tester);
    final antes = donde(enrutador);

    // Los avisos de la v1 no traen destino, y tocarlos no debe sacar a nadie
    // de donde está.
    avisos.notificarToque();
    await tester.pumpAndSettle();

    expect(donde(enrutador), antes);
  });

  testWidgets('un destino de fuera de la app se ignora', (tester) async {
    final enrutador = await app(tester);
    await entrar(tester);
    final antes = donde(enrutador);

    avisos.notificarToque('https://example.com/pagar');
    await tester.pumpAndSettle();

    expect(donde(enrutador), antes);
  });
}
