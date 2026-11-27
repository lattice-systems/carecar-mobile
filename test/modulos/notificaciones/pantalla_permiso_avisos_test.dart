import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';
import 'package:carecar_mobile/nucleo/avisos/explicacion_de_avisos.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/pantalla_permiso_avisos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:carecar_mobile/nucleo/bienvenida/estado_bienvenida.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/avisos_del_sistema_falso.dart';
import '../../ayudas/tema_pista.dart';

/// V2-M06.01 · la pantalla que explica los avisos antes de pedirlos.
///
/// Lo que se comprueba es el orden, que es el criterio: **abrir la pantalla no
/// toca el sistema**; el diálogo sale solo si la persona acepta; y si quedó
/// negado, hay salida a los ajustes.
void main() {
  late AvisosDelSistemaFalso sistema;

  /// La pantalla es mas alta que los 600 px de la ventana de prueba: sin esto
  /// los botones quedan fuera y `tap` no los alcanza.
  void lienzoDeTelefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<Widget> escena(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    sistema = AvisosDelSistemaFalso();
    return ProviderScope(
      overrides: [
        preferenciasProvider.overrideWithValue(prefs),
        avisosDelSistemaProvider.overrideWithValue(sistema),
      ],
      child: conTemaPista(const PantallaPermisoAvisos()),
    );
  }

  testWidgets('abrirla no le pide nada al sistema: primero explica', (
    tester,
  ) async {
    lienzoDeTelefono(tester);
    await tester.pumpWidget(await escena({}));
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaPermisoAvisos.botonActivar), findsOneWidget);
    expect(find.byKey(PantallaPermisoAvisos.botonAhoraNo), findsOneWidget);
    expect(sistema.vecesQueSePidio, 0);
  });

  testWidgets('aceptar dispara el diálogo y confirma', (tester) async {
    lienzoDeTelefono(tester);
    await tester.pumpWidget(await escena({}));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(PantallaPermisoAvisos.botonActivar));
    await tester.pumpAndSettle();

    expect(sistema.vecesQueSePidio, 1);
    expect(find.byKey(PantallaPermisoAvisos.avisoListo), findsOneWidget);
  });

  testWidgets('«ahora no» no toca el sistema y la app sigue', (tester) async {
    lienzoDeTelefono(tester);
    await tester.pumpWidget(await escena({}));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(PantallaPermisoAvisos.botonAhoraNo));
    await tester.pumpAndSettle();

    expect(sistema.vecesQueSePidio, 0);
    // Negado no es una pantalla de error: la misma pantalla sigue de pie y
    // ofrece la salida.
    expect(find.byKey(PantallaPermisoAvisos.avisoNegados), findsOneWidget);
  });

  testWidgets('ya negado, ofrece abrir los ajustes del sistema', (
    tester,
  ) async {
    lienzoDeTelefono(tester);
    await tester.pumpWidget(
      await escena({claveAvisosRespondido: true, claveAvisosPermitidos: false}),
    );
    await tester.pumpAndSettle();

    // No se vuelve a ofrecer «Activar»: en Android 13 y después no haría nada.
    expect(find.byKey(PantallaPermisoAvisos.botonActivar), findsNothing);

    await tester.tap(find.byKey(PantallaPermisoAvisos.botonAjustes));
    await tester.pumpAndSettle();

    expect(sistema.vecesQueSeAbrieronAjustes, 1);
  });

  testWidgets('con letra al 200 % los botones siguen completos', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenciasProvider.overrideWithValue(prefs),
          avisosDelSistemaProvider.overrideWithValue(AvisosDelSistemaFalso()),
        ],
        child: conTemaPista(
          const PantallaPermisoAvisos(),
          escenario: Escenario.letraGrande,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Boton), findsNWidgets(2));
  });

  testWidgets('al entrar a la cuenta, la app explica antes de pedir nada', (
    tester,
  ) async {
    lienzoDeTelefono(tester);
    SharedPreferences.setMockInitialValues({
      // La bienvenida (V2-M01.02) va antes en la guardia; quien va a entrar
      // con su cuenta ya la vio.
      claveBienvenidaVista: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final sistema = AvisosDelSistemaFalso();
    final api = ApiFalsa();
    final sesion = ControladorSesion(api, AlmacenEnMemoria());
    addTearDown(sesion.dispose);

    await tester.pumpWidget(
      AppEnrutadaDePrueba(
        api: api,
        controlador: sesion,
        idioma: const Locale('es'),
        overrides: [
          preferenciasProvider.overrideWithValue(prefs),
          avisosDelSistemaProvider.overrideWithValue(sistema),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
    await tester.pumpAndSettle();

    // Lo que prueba la historia: la app llego a la explicacion, y al sistema
    // todavia no se le ha pedido nada.
    expect(find.byType(PantallaPermisoAvisos), findsOneWidget);
    expect(sistema.vecesQueSePidio, 0);

    // Y «Ahora no» deja seguir: no es un callejon sin salida.
    await tester.tap(find.byKey(PantallaPermisoAvisos.botonAhoraNo));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaPermisoAvisos), findsNothing);
    expect(sistema.vecesQueSePidio, 0);
  });
}
