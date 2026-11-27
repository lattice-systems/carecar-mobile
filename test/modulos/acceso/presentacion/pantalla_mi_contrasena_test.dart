import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.10 · «cambiar mi contraseña desde Seguridad cuando yo quiera».
///
/// Dos criterios y los dos se prueban aquí: que **pida la actual** y que
/// cerrar las demás sesiones sea **opcional**. Lo segundo es lo delicado: el
/// contrato solo sabe cerrarlas **todas, incluida esta**, así que con la
/// casilla marcada la app tiene que soltar también su propia sesión. Si se
/// quedara dentro, el cliente creería que no se cerró nada.
void main() {
  ControladorSesion sesionLocal(ApiFalsa api) =>
      ControladorSesion(api, AlmacenEnMemoria());

  Future<ControladorSesion> sesionDentro() async {
    final local = sesionLocal(ApiFalsa());
    await local.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
    return local;
  }

  Widget app(RepositorioAccesoFake repo, ControladorSesion local) =>
      ProviderScope(
        overrides: [
          repositorioAccesoProvider.overrideWithValue(repo),
          controladorSesionProvider.overrideWithValue(local),
        ],
        child: conTemaPista(const PantallaMiContrasena()),
      );

  void prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
      testWidgets(descripcion, (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await cuerpo(tester);
      });

  /// Se busca por llave: `CampoTexto` pinta la etiqueta **arriba** del campo.
  Future<void> llenar(
    WidgetTester tester, {
    String actual = 'CareCar2026',
  }) async {
    for (final campo in {
      PantallaMiContrasena.campoActual: actual,
      PantallaMiContrasena.campoNueva: 'Pista2026nueva',
      PantallaMiContrasena.campoConfirmar: 'Pista2026nueva',
    }.entries) {
      await tester.ensureVisible(find.byKey(campo.key));
      await tester.enterText(find.byKey(campo.key), campo.value);
      await tester.pumpAndSettle();
    }
  }

  Future<void> guardar(WidgetTester tester) async {
    final boton = find.byKey(PantallaMiContrasena.botonGuardar);
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  prueba('pide la actual y manda las dos, sin tocar las sesiones', (
    tester,
  ) async {
    final repo = RepositorioAccesoFake();
    final local = await sesionDentro();

    await tester.pumpWidget(app(repo, local));
    await llenar(tester);
    await guardar(tester);

    expect(repo.ultimaActual, 'CareCar2026');
    expect(repo.ultimaNueva, 'Pista2026nueva');
    // La casilla viene apagada: cambiar la contraseña no debe sacar a nadie de
    // sus otros dispositivos sin habérselo pedido.
    expect(repo.cerroTodas, isFalse);
    expect(local.estado, isA<Autenticada>());
    expect(find.text('Tu contraseña quedó actualizada'), findsOneWidget);
  });

  prueba('con la casilla marcada cierra todas y suelta esta sesion', (
    tester,
  ) async {
    final repo = RepositorioAccesoFake();
    final local = await sesionDentro();

    await tester.pumpWidget(app(repo, local));
    await llenar(tester);
    await tester.tap(find.byKey(PantallaMiContrasena.casillaCerrarOtras));
    await tester.pumpAndSettle();
    await guardar(tester);

    expect(repo.ultimaNueva, 'Pista2026nueva');
    expect(repo.cerroTodas, isTrue);
    expect(local.estado, isA<SinSesion>());
  });

  prueba('si el servidor rechaza la actual, no cierra nada y lo avisa', (
    tester,
  ) async {
    final repo = RepositorioAccesoFake()
      ..falla = Fallos.validacion(mensaje: 'Tu contraseña actual no coincide.');
    final local = await sesionDentro();

    await tester.pumpWidget(app(repo, local));
    await llenar(tester, actual: 'LaQueNoEs2026');
    await tester.tap(find.byKey(PantallaMiContrasena.casillaCerrarOtras));
    await tester.pumpAndSettle();
    await guardar(tester);

    expect(find.byKey(PantallaMiContrasena.avisoDeError), findsOneWidget);
    expect(find.text('Tu contraseña actual no coincide.'), findsOneWidget);
    // Lo que importa: el cambio no pasó, así que las sesiones siguen vivas.
    expect(repo.cerroTodas, isFalse);
    expect(local.estado, isA<Autenticada>());
    expect(find.text('Tu contraseña quedó actualizada'), findsNothing);
  });
}
