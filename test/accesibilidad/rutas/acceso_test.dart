import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_rutas.dart';

/// Las pantallas de acceso v2 (M01) en el recorrido de accesibilidad. Cada
/// una pide un estado distinto de la sesión, así que cada una monta su app.
/// La recuperación de contraseña sigue en v1 y las pantallas v1 no se auditan.
void main() {
  testWidgets('el inicio de sesión pasa la auditoría', (tester) async {
    await montarParaAuditar(tester, prepararSesion: (_) async {});
    await auditarRutas(tester, {Rutas.acceso: PantallaAcceso});
  });

  testWidgets('la bienvenida pasa la auditoría', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await montarParaAuditar(
      tester,
      prepararSesion: (_) async {},
      overrides: [preferenciasProvider.overrideWithValue(prefs)],
    );
    await auditarRutas(tester, {Rutas.bienvenida: PantallaBienvenida});
  });

  testWidgets('la cuenta desactivada pasa la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      prepararSesion: (sesion) async {
        await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
        await sesion.terminarPorCuentaDesactivada();
      },
    );
    await auditarRutas(tester, {
      Rutas.cuentaDesactivada: PantallaCuentaDesactivada,
    });
  });

  testWidgets('el cambio obligatorio de contraseña pasa la auditoría', (
    tester,
  ) async {
    await montarParaAuditar(
      tester,
      api: ApiFalsa.conContrasenaTemporal(),
      prepararSesion: (sesion) =>
          sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'Temporal2026'),
    );
    await auditarRutas(tester, {
      Rutas.cambiarContrasena: PantallaCambiarContrasena,
    });
  });

  testWidgets('mi contraseña y cambiar correo pasan la auditoría', (
    tester,
  ) async {
    await montarParaAuditar(tester);
    await auditarRutas(tester, {
      rutaMiContrasena: PantallaMiContrasena,
      rutaCambiarCorreo: PantallaCambiarCorreo,
    });
  });
}
