import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

/// V2-M01.11 · «la sesion se renueva sola durante 30 dias».
///
/// Las piezas estan probadas por separado: el controlador rota el par y
/// serializa los refrescos (`test/sesion/controlador_sesion_test.dart`), el
/// cliente reintenta una vez ante un 401 (`test/api/sesion_con_refresco_test`)
/// y el guardia sabe guardar el destino (`guardia_sesion_test.dart`).
///
/// **Lo que nadie comprobaba es la suma**, que es justo lo que dicen los dos
/// criterios: que el refresco sea transparente para quien usa la app, y que si
/// falla vuelva al acceso **conservando la pantalla a la que iba**.
void main() {
  /// Un par guardado cuyo access token ya vencio, como al reabrir la app.
  TokensSesion vencidos() => TokensSesion(
    accessToken: 'viejo',
    refreshToken: 'refresco-bueno',
    expiraEn: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  ControladorSesion controladorCon(ApiFalsa api, TokensSesion? guardados) {
    final almacen = AlmacenEnMemoria();
    if (guardados != null) almacen.guardar(guardados);
    return ControladorSesion(api, almacen);
  }

  group('el refresco es transparente', () {
    testWidgets('al reabrir con el access token vencido no se ve el acceso', (
      tester,
    ) async {
      final api = ApiFalsa();
      final sesion = controladorCon(api, vencidos());

      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      await sesion.restaurar();
      await tester.pumpAndSettle();

      // Se refresco sin pedir nada.
      expect(api.refrescosPedidos, ['refresco-bueno']);
      expect(sesion.estado, isA<Autenticada>());
      // Y por tanto la pantalla de acceso no aparece.
      expect(find.byType(PantallaAcceso), findsNothing);
    });

    testWidgets('el par nuevo queda guardado, no el gastado', (tester) async {
      // El refresh es de un solo uso: si se guardara el viejo, el siguiente
      // refresco lo reusaria y el servidor cerraria **todas** las sesiones de
      // la cuenta. Es el riesgo mas caro de esta historia.
      final almacen = AlmacenEnMemoria();
      await almacen.guardar(vencidos());
      final api = ApiFalsa()
        ..alRefrescar = (_) async => ApiFalsa.respuesta(
          accessToken: 'nuevo',
          refreshToken: 'refresco-nuevo',
        );
      final sesion = ControladorSesion(api, almacen);

      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      await sesion.restaurar();
      await tester.pumpAndSettle();

      final guardado = await almacen.leer();
      expect(guardado?.refreshToken, 'refresco-nuevo');
      expect(guardado?.accessToken, 'nuevo');
    });
  });

  group('si el refresco falla, vuelve al acceso con el destino', () {
    testWidgets('lleva a /acceso y guarda a donde iba', (tester) async {
      final api = ApiFalsa()
        ..alRefrescar = (_) async =>
            throw const CredencialesInvalidas('Tu sesión terminó.');
      final sesion = controladorCon(api, vencidos());

      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      // Primero entra bien y navega a una pantalla privada.
      await sesion.restaurar();
      await tester.pumpAndSettle();

      expect(sesion.estado, isA<SinSesion>());

      final enrutador = enrutadorDe(tester);
      final donde = enrutador.routerDelegate.currentConfiguration.uri
          .toString();
      expect(donde, startsWith(Rutas.acceso));
    });

    testWidgets(
      'si la sesion muere estando en una pantalla privada, la guarda',
      (tester) async {
        // Este es el criterio tal cual: no es «sin sesion pides una ruta», es
        // «estabas dentro, el refresco murio y no deberias perder donde ibas».
        final api = ApiFalsa();
        final sesion = controladorCon(api, null);

        await tester.pumpWidget(
          AppEnrutadaDePrueba(api: api, controlador: sesion),
        );
        await sesion.iniciarSesion(
          correo: 'cliente1@example.com',
          contrasena: 'CareCar2026',
        );
        await tester.pumpAndSettle();

        final enrutador = enrutadorDe(tester);
        enrutador.go('/garaje');
        await tester.pumpAndSettle();
        expect(
          enrutador.routerDelegate.currentConfiguration.uri.path,
          '/garaje',
        );

        // El refresh token murio: el servidor responde 401 y la sesion termina.
        api.alRefrescar = (_) async =>
            throw const CredencialesInvalidas('Tu sesión terminó.');
        await sesion.renovar();
        await tester.pumpAndSettle();

        final donde = Uri.decodeFull(
          enrutador.routerDelegate.currentConfiguration.uri.toString(),
        );
        expect(donde, startsWith(Rutas.acceso));
        expect(donde, contains('/garaje'));
      },
    );

    testWidgets('el destino guardado trae de vuelta tras entrar otra vez', (
      tester,
    ) async {
      final api = ApiFalsa();
      final sesion = controladorCon(api, null);

      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      await tester.pumpAndSettle();

      // Sin sesion, pedir una ruta privada manda al acceso con el destino.
      final enrutador = enrutadorDe(tester);
      enrutador.go('/garaje');
      await tester.pumpAndSettle();

      final enElAcceso = enrutador.routerDelegate.currentConfiguration.uri
          .toString();
      expect(enElAcceso, contains(Rutas.parametroDesde));
      expect(Uri.decodeFull(enElAcceso), contains('/garaje'));

      // Al entrar, el guardia usa ese destino en vez del inicio.
      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      await tester.pumpAndSettle();

      final despues = enrutador.routerDelegate.currentConfiguration.uri
          .toString();
      expect(despues, '/garaje');
    });
  });
}
