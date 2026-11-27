import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/bienvenida/estado_bienvenida.dart';
import 'package:carecar_mobile/nucleo/biometria/candado_biometrico.dart';
import 'package:carecar_mobile/nucleo/biometria/lector_biometrico.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/app_enrutada.dart';
import '../../../ayudas/lector_biometrico_falso.dart';

/// V2-M01.05 · desbloquear la app con huella o rostro.
///
/// Se prueba con la app enrutada porque lo que importa es la suma: que al
/// reabrir con sesión guardada y el candado prendido **no se vea nada** hasta
/// identificarse, y que siempre quede la salida de la contraseña.
void main() {
  TokensSesion vigentes() => TokensSesion(
    accessToken: 'bueno',
    refreshToken: 'refresco-bueno',
    expiraEn: DateTime.now().add(const Duration(hours: 1)),
  );

  /// La app con el candado prendido y una sesión guardada, como al reabrir.
  Future<(Widget, ControladorSesion)> appBloqueada(
    LectorBiometricoFalso lector, {
    String firmaGuardada = 'fingerprint',
  }) async {
    SharedPreferences.setMockInitialValues({
      claveCandadoActivo: true,
      claveCandadoFirma: firmaGuardada,
      // La bienvenida (V2-M01.02) va **antes** que el candado en la guardia, y
      // con razon: quien tiene sesion guardada ya la vio. Sin esto, la app
      // mostraria la bienvenida y no el desbloqueo.
      claveBienvenidaVista: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final api = ApiFalsa();
    final almacen = AlmacenEnMemoria();
    await almacen.guardar(vigentes());
    final sesion = ControladorSesion(api, almacen);

    return (
      AppEnrutadaDePrueba(
        api: api,
        controlador: sesion,
        overrides: [
          preferenciasProvider.overrideWithValue(prefs),
          lectorBiometricoProvider.overrideWithValue(lector),
        ],
        idioma: const Locale('es'),
      ),
      sesion,
    );
  }

  testWidgets('con la huella buena abre la app y no vuelve a pedirla', (
    tester,
  ) async {
    final lector = LectorBiometricoFalso();
    final (app, sesion) = await appBloqueada(lector);

    await tester.pumpWidget(app);
    await sesion.restaurar();
    await tester.pumpAndSettle();

    // Se pidió sola, sin un toque de más, y ya no se ve el desbloqueo.
    expect(lector.identificaciones, 1);
    expect(find.byType(PantallaDesbloqueo), findsNothing);
  });

  testWidgets('si no reconoce, se queda y ofrece la contraseña', (
    tester,
  ) async {
    final lector = LectorBiometricoFalso(reconoce: false);
    final (app, sesion) = await appBloqueada(lector);

    await tester.pumpWidget(app);
    await sesion.restaurar();
    await tester.pumpAndSettle();

    expect(find.byType(PantallaDesbloqueo), findsOneWidget);
    expect(find.byKey(PantallaDesbloqueo.avisoFallo), findsOneWidget);

    // La salida que vuelve segura la comodidad: nadie se queda fuera.
    await tester.tap(find.byKey(PantallaDesbloqueo.botonContrasena));
    await tester.pumpAndSettle();

    expect(sesion.estado, isA<SinSesion>());
    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('si cambió la biometría del equipo, pide la contraseña', (
    tester,
  ) async {
    // El equipo ahora reporta rostro; el candado se prendió con huella.
    final lector = LectorBiometricoFalso(firmaDelEquipo: 'face');
    final (app, sesion) = await appBloqueada(lector);

    await tester.pumpWidget(app);
    await sesion.restaurar();
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaDesbloqueo.avisoCambio), findsOneWidget);
    // No se pidió la huella: no serviría de nada, y el candado queda apagado
    // para que se vuelva a prender a conciencia con la firma nueva.
    expect(lector.identificaciones, 0);
    expect(find.byKey(PantallaDesbloqueo.botonIntentar), findsNothing);
  });
}
