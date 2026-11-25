import 'package:carecar_mobile/modulos/ejemplo/ejemplo.dart';
import 'package:carecar_mobile/nucleo/navegacion/enlaces.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_cambiar_contrasena.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/pantallas/pantalla_recuperar_contrasena.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<ControladorSesion> _montar(
  WidgetTester tester, {
  ApiFalsa? api,
  bool conSesion = true,
  bool temporal = false,
}) async {
  final falsa = api ?? ApiFalsa();
  if (temporal) {
    falsa.alIniciarSesion = (_) async =>
        ApiFalsa.respuesta(debeCambiarContrasena: true);
  }
  final sesion = ControladorSesion(falsa, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(AppEnrutadaDePrueba(api: falsa, controlador: sesion));
  await tester.pumpAndSettle();
  return sesion;
}

/// Lo mismo que hace Android/iOS al abrir un enlace con la app en marcha.
Future<void> _abrirEnlace(WidgetTester tester, String enlace) async {
  final mensaje = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', {'location': enlace}),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    mensaje,
    (_) {},
  );
  await tester.pumpAndSettle();
}

String _codigoEscrito(WidgetTester tester) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(PantallaRecuperarContrasena.campoCodigo),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

String _ubicacion(WidgetTester tester) =>
    enrutadorDe(tester).routerDelegate.currentConfiguration.uri.toString();

void main() {
  group('una prueba por ruta', () {
    testWidgets('inicio ("/") muestra el menu', (tester) async {
      await _montar(tester);
      expect(find.byType(InicioNuevo), findsOneWidget);
      expect(_ubicacion(tester), Rutas.inicio);
    });

    testWidgets('acceso muestra el login', (tester) async {
      await _montar(tester, conSesion: false);
      expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
    });

    testWidgets('recuperar muestra el paso del correo, con el correo', (
      tester,
    ) async {
      await _montar(tester, conSesion: false);
      enrutadorDe(tester)
          .go(Rutas.localizacionRecuperar(correo: 'ana@example.com'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(PantallaRecuperarContrasena.botonEnviar),
        findsOneWidget,
      );
      expect(find.text('ana@example.com'), findsOneWidget);
    });

    testWidgets('restablecer muestra el paso del codigo', (tester) async {
      await _montar(tester, conSesion: false);
      enrutadorDe(tester).go(
        Rutas.localizacionRestablecer(
          token: '123456',
          correo: 'ana@example.com',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        findsOneWidget,
      );
      expect(_codigoEscrito(tester), '123456');
    });

    testWidgets('cambiar-contrasena muestra el cambio obligatorio', (
      tester,
    ) async {
      await _montar(tester, temporal: true);
      expect(
        find.byKey(PantallaCambiarContrasena.botonGuardar),
        findsOneWidget,
      );
    });

    testWidgets('ejemplo/avisos (solo desarrollo) muestra la pantalla', (
      tester,
    ) async {
      await _montar(tester);
      enrutadorDe(tester).go(rutaAvisosEjemplo);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaAvisos), findsOneWidget);
    });

    testWidgets('una ruta que no existe cae en el inicio', (tester) async {
      await _montar(tester);
      enrutadorDe(tester).go('/no-existe');
      await tester.pumpAndSettle();
      expect(find.byType(InicioNuevo), findsOneWidget);
    });
  });

  group('redireccion por sesion', () {
    testWidgets(
      'sin sesion, una ruta privada pide acceso y vuelve tras entrar',
      (tester) async {
        final sesion = await _montar(tester, conSesion: false);
        enrutadorDe(tester).go(rutaAvisosEjemplo);
        await tester.pumpAndSettle();

        expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
        expect(
          _ubicacion(tester),
          Rutas.localizacionAcceso(desde: rutaAvisosEjemplo),
        );

        await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
        await tester.pumpAndSettle();
        expect(find.byType(PantallaAvisos), findsOneWidget);
        expect(_ubicacion(tester), rutaAvisosEjemplo);
      },
    );

    testWidgets('con contrasena temporal obliga a cambiarla y luego sigue', (
      tester,
    ) async {
      final api = ApiFalsa();
      final sesion = await _montar(
        tester,
        api: api,
        conSesion: false,
        temporal: true,
      );
      enrutadorDe(tester).go(rutaAvisosEjemplo);
      await tester.pumpAndSettle();
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'Temporal123');
      await tester.pumpAndSettle();

      expect(
        find.byKey(PantallaCambiarContrasena.botonGuardar),
        findsOneWidget,
      );
      // No se puede saltar yendo a otra ruta.
      enrutadorDe(tester).go(rutaAvisosEjemplo);
      await tester.pumpAndSettle();
      expect(
        find.byKey(PantallaCambiarContrasena.botonGuardar),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoActual),
        'Temporal123',
      );
      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoNueva),
        'NuevaClave2026',
      );
      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoConfirmar),
        'NuevaClave2026',
      );
      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaNueva, 'NuevaClave2026');
      expect(find.byType(PantallaAvisos), findsOneWidget);
    });

    testWidgets('con sesion, el acceso lleva al inicio', (tester) async {
      await _montar(tester);
      enrutadorDe(tester).go(Rutas.acceso);
      await tester.pumpAndSettle();
      expect(find.byType(InicioNuevo), findsOneWidget);
    });

    testWidgets('al cerrar sesion vuelve al acceso', (tester) async {
      final sesion = await _montar(tester);
      await sesion.cerrarSesion();
      await tester.pumpAndSettle();
      expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
    });
  });

  group('deep links', () {
    testWidgets(
      'carecar://restablecer?token=... abre la recuperacion con el codigo',
      (tester) async {
        await _montar(tester, conSesion: false);
        await _abrirEnlace(
          tester,
          'carecar://restablecer?token=123456&correo=ana%40example.com',
        );

        expect(_ubicacion(tester), startsWith(Rutas.restablecer));
        expect(
          find.byKey(PantallaRecuperarContrasena.campoCodigo),
          findsOneWidget,
        );
        expect(_codigoEscrito(tester), '123456');
        expect(find.byKey(PantallaLogin.botonEntrar), findsNothing);
      },
    );

    testWidgets('el enlace universal https abre la misma pantalla', (
      tester,
    ) async {
      await _montar(tester, conSesion: false);
      await _abrirEnlace(
        tester,
        'https://${EnlacesApp.hostEnlacesUniversales}/app/restablecer'
        '?token=654321&correo=ana%40example.com',
      );

      expect(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        findsOneWidget,
      );
      expect(_codigoEscrito(tester), '654321');
    });

    testWidgets('un enlace a una ruta privada sin sesion pasa por el login', (
      tester,
    ) async {
      await _montar(tester, conSesion: false);
      await _abrirEnlace(tester, 'carecar://ejemplo/avisos');
      expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
      expect(
        _ubicacion(tester),
        Rutas.localizacionAcceso(desde: rutaAvisosEjemplo),
      );
    });
  });
}
