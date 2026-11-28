import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_dispositivos_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/servicio_push_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/proveedores_push.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ayudas/api_falsa.dart';

/// Anota cuántos cierres de sesión había pedido la API al momento de la baja:
/// tiene que ser cero, porque `/auth/cerrar-sesion` ya no lleva access token.
class _RepositorioQueMira extends RepositorioDispositivosFake {
  _RepositorioQueMira(this._api);

  final ApiFalsa _api;
  final cierresAlDarDeBaja = <int>[];

  @override
  Future<void> darDeBaja(String instalacionId) {
    cierresAlDarDeBaja.add(_api.cierresPedidos.length);
    return super.darDeBaja(instalacionId);
  }
}

class _AvisosQueConceden implements AvisosDelSistema {
  @override
  Future<bool> pedirPermiso() async => true;

  @override
  Future<void> abrirAjustes() async {}
}

/// V2-M06.02 · el enganche: que la app de verdad llame al coordinador al
/// entrar, al cambiar el permiso, al volver a primer plano y al salir.
void main() {
  late ApiFalsa api;
  late ControladorSesion sesion;
  late _RepositorioQueMira repositorio;
  late ServicioPushFake servicio;

  Future<void> montar(
    WidgetTester tester, {
    bool? permitidos = true,
    bool conFirebase = true,
  }) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    tester.platformDispatcher.localeTestValue = const Locale('es');
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({
      if (permitidos != null) 'avisos.respondido': true,
      'avisos.permitidos': ?permitidos,
    });
    final prefs = await SharedPreferences.getInstance();
    api = ApiFalsa();
    sesion = ControladorSesion(api, AlmacenEnMemoria());
    addTearDown(sesion.dispose);
    repositorio = _RepositorioQueMira(api);
    servicio = ServicioPushFake(token: 'token-1');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controladorSesionProvider.overrideWithValue(sesion),
          preferenciasProvider.overrideWithValue(prefs),
          avisosDelSistemaProvider.overrideWithValue(_AvisosQueConceden()),
          if (conFirebase) ...[
            servicioPushProvider.overrideWithValue(servicio),
            repositorioDispositivosProvider.overrideWithValue(repositorio),
          ],
        ],
        child: const RegistradorDePush(child: SizedBox()),
      ),
    );
  }

  Future<void> entrar(WidgetTester tester) async {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
    await tester.pumpAndSettle();
  }

  testWidgets('al entrar registra el token de este teléfono', (tester) async {
    await montar(tester);
    expect(repositorio.llamadas, isEmpty);

    await entrar(tester);

    expect(repositorio.llamadas, hasLength(1));
    expect(repositorio.llamadas.single, startsWith('PUT '));
    expect(repositorio.llamadas.single, endsWith(' token-1 android es'));
  });

  testWidgets('al cerrar sesión da de baja antes de avisar al servidor', (
    tester,
  ) async {
    await montar(tester);
    await entrar(tester);

    await sesion.cerrarSesion();
    await tester.pumpAndSettle();

    expect(repositorio.llamadas.last, startsWith('DELETE '));
    expect(repositorio.cierresAlDarDeBaja, [0]);
    expect(api.cierresPedidos, hasLength(1));
  });

  testWidgets('sin permiso no registra; al concederlo, sí', (tester) async {
    await montar(tester, permitidos: null);
    await entrar(tester);
    expect(repositorio.llamadas, isEmpty);

    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(SizedBox)),
    );
    await contenedor.read(permisoDeAvisosProvider.notifier).pedir();
    await tester.pumpAndSettle();

    expect(repositorio.llamadas, hasLength(1));
  });

  testWidgets('si falló sin red, lo reintenta al volver a primer plano', (
    tester,
  ) async {
    await montar(tester);
    repositorio.fallarCon = Exception('sin red');
    await entrar(tester);
    expect(repositorio.llamadas, isEmpty);

    repositorio.fallarCon = null;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(repositorio.llamadas, hasLength(1));
  });

  testWidgets('desmontado ya no da de baja al cerrar sesión', (tester) async {
    await montar(tester);
    await entrar(tester);
    await tester.pumpWidget(const SizedBox());

    await sesion.cerrarSesion();

    expect(repositorio.llamadas.where((l) => l.startsWith('DELETE ')), isEmpty);
  });

  testWidgets('sin Firebase no hace ninguna petición de dispositivos', (
    tester,
  ) async {
    // Sin sobrescribir el repositorio, leerlo pediría el cliente HTTP del
    // núcleo, que en esta prueba no existe: si se tocara, fallaría.
    await montar(tester, conFirebase: false);
    await entrar(tester);
    await sesion.cerrarSesion();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(api.cierresPedidos, hasLength(1));
  });
}
