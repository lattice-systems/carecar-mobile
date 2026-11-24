import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/aviso_bloqueo.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_acceso.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.01 · la pantalla de acceso v2.
///
/// Tres de los cuatro criterios se comprueban aqui: no hay registro, las
/// credenciales malas no revelan si el correo existe, y el bloqueo por
/// intentos se distingue de un error. El cuarto —ver Inicio en menos de 2 s—
/// es del enrutador: el guardia de sesion saca de `/acceso` a quien ya entro,
/// asi que **esta pantalla no navega**.
void main() {
  ControladorSesion controlador(ApiFalsa api) =>
      ControladorSesion(api, AlmacenEnMemoria());

  Future<void> montar(
    WidgetTester tester,
    ControladorSesion sesion, {
    DateTime Function()? reloj,
  }) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        controladorSesionProvider.overrideWithValue(sesion),
        if (reloj != null) relojAccesoProvider.overrideWithValue(reloj),
      ],
      child: conTemaPista(const PantallaAcceso()),
    ),
  );

  Future<void> escribir(
    WidgetTester tester, {
    String correo = 'cliente1@example.com',
    String contrasena = 'CareCar2026',
  }) async {
    await tester.enterText(find.byKey(PantallaAcceso.campoCorreo), correo);
    await tester.enterText(
      find.byKey(PantallaAcceso.campoContrasena),
      contrasena,
    );
  }

  Future<void> entrar(WidgetTester tester) async {
    await tester.tap(find.byKey(PantallaAcceso.botonEntrar));
    await tester.pumpAndSettle();
  }

  group('el acceso es cerrado', () {
    testWidgets('no hay ningun flujo de registro', (tester) async {
      await montar(tester, controlador(ApiFalsa()));

      // El criterio de aceptacion es explicito: la agencia entrega la cuenta.
      expect(find.textContaining('egistr'), findsNothing);
      expect(find.textContaining('rear cuenta'), findsNothing);
    });

    testWidgets('explica de donde sale el acceso', (tester) async {
      await montar(tester, controlador(ApiFalsa()));
      expect(find.textContaining('agencia'), findsWidgets);
    });
  });

  group('valida antes de pedirle algo al servidor', () {
    testWidgets('sin correo no llama al API', (tester) async {
      final api = ApiFalsa();
      await montar(tester, controlador(api));

      await escribir(tester, correo: '');
      await entrar(tester);

      expect(api.llamadasAlLogin, 0);
      expect(find.text('Escribe tu correo.'), findsOneWidget);
    });

    testWidgets('sin contrasena no llama al API', (tester) async {
      final api = ApiFalsa();
      await montar(tester, controlador(api));

      await escribir(tester, contrasena: '');
      await entrar(tester);

      expect(api.llamadasAlLogin, 0);
      expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    });

    testWidgets('un correo sin arroba no llama al API', (tester) async {
      final api = ApiFalsa();
      await montar(tester, controlador(api));

      await escribir(tester, correo: 'cliente1');
      await entrar(tester);

      expect(api.llamadasAlLogin, 0);
    });

    testWidgets('con los dos campos llenos si llama, con el correo limpio', (
      tester,
    ) async {
      final api = ApiFalsa();
      await montar(tester, controlador(api));

      await escribir(tester, correo: '  Cliente1@Example.com  ');
      await entrar(tester);

      expect(api.llamadasAlLogin, 1);
      // El backend ignora mayusculas y espacios (RIC-8), pero mandar basura
      // igual es descuidado.
      expect(api.ultimaPeticion?.correo, 'Cliente1@Example.com');
    });
  });

  group('cada fallo se ve distinto', () {
    testWidgets('credenciales malas: error, sin decir si el correo existe', (
      tester,
    ) async {
      const mensaje = 'Correo o contraseña incorrectos.';
      await montar(
        tester,
        controlador(ApiFalsa.queFalla(const CredencialesInvalidas(mensaje))),
      );

      await escribir(tester);
      await entrar(tester);

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaAcceso.avisoDeError),
      );
      expect(aviso.tono, Tono.peligro);
      expect(aviso.mensaje, mensaje);
      // Lo que el criterio prohibe: que el texto delate la cuenta.
      expect(aviso.mensaje, isNot(contains('cliente1@example.com')));
      expect(aviso.mensaje, isNot(contains('no existe')));
    });

    testWidgets('sin conexion: advertencia, no error', (tester) async {
      await montar(tester, controlador(ApiFalsa.queFalla(const SinConexion())));

      await escribir(tester);
      await entrar(tester);

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaAcceso.avisoDeError),
      );
      // No es culpa de quien entra ni hay nada que corregir: es una espera.
      expect(aviso.tono, Tono.advertencia);
      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('bloqueo por intentos: cuenta regresiva en minutos', (
      tester,
    ) async {
      await montar(
        tester,
        controlador(
          ApiFalsa.queFalla(
            const DemasiadosIntentos('Espera 15 minutos.', esperaSegundos: 900),
          ),
        ),
      );

      await escribir(tester);
      await entrar(tester);

      expect(find.byType(AvisoBloqueo), findsOneWidget);
      expect(find.text('Demasiados intentos'), findsOneWidget);
      expect(find.textContaining('15 min'), findsOneWidget);
      // No se usa el texto que armo el controlador: ese no baja.
      expect(find.text('Espera 15 minutos.'), findsNothing);
    });

    testWidgets('la cuenta no se reinicia al reconstruir la pantalla', (
      tester,
    ) async {
      var ahora = DateTime(2026, 11, 24, 10, 0);
      await montar(
        tester,
        controlador(
          ApiFalsa.queFalla(
            const DemasiadosIntentos('Espera.', esperaSegundos: 900),
          ),
        ),
        reloj: () => ahora,
      );

      await escribir(tester);
      await entrar(tester);
      expect(find.textContaining('15 min'), findsOneWidget);

      // Pasan diez minutos y algo reconstruye la pantalla (escribir en un
      // campo basta). Si el fin del bloqueo se recalculara en cada build,
      // volveria a decir 15 y el usuario nunca veria bajar la cuenta.
      ahora = ahora.add(const Duration(minutes: 10));
      await tester.enterText(
        find.byKey(PantallaAcceso.campoCorreo),
        'otro@example.com',
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('5 min'), findsOneWidget);
      expect(find.textContaining('15 min'), findsNothing);
    });

    testWidgets('un bloqueo sin Retry-After cae en el aviso generico', (
      tester,
    ) async {
      // El encabezado es opcional en el contrato: sin el no hay cuenta que
      // mostrar, pero el usuario igual tiene que saber que esta bloqueado.
      await montar(
        tester,
        controlador(
          ApiFalsa.queFalla(const DemasiadosIntentos('Demasiados intentos.')),
        ),
      );

      await escribir(tester);
      await entrar(tester);

      expect(find.byType(AvisoBloqueo), findsNothing);
      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaAcceso.avisoDeError),
      );
      expect(aviso.tono, Tono.advertencia);
      expect(find.text('Demasiados intentos'), findsOneWidget);
    });
  });

  group('mientras entra', () {
    testWidgets('el boton se bloquea para que no haya doble peticion', (
      tester,
    ) async {
      final api = ApiFalsa();
      await montar(tester, controlador(api));
      await escribir(tester);

      await tester.tap(find.byKey(PantallaAcceso.botonEntrar));
      await tester.pump();
      // Sin esperar a que responda, un segundo toque no debe hacer nada.
      await tester.tap(find.byKey(PantallaAcceso.botonEntrar));
      await tester.pumpAndSettle();

      expect(api.llamadasAlLogin, 1);
    });
  });

  group('al entrar', () {
    testWidgets('la sesion queda autenticada y la pantalla no navega sola', (
      tester,
    ) async {
      final sesion = controlador(ApiFalsa());
      await montar(tester, sesion);

      await escribir(tester);
      await entrar(tester);

      // De sacar al usuario de `/acceso` se encarga el guardia del enrutador.
      expect(sesion.estado, isA<Autenticada>());
      expect(tester.takeException(), isNull);
    });
  });
}
