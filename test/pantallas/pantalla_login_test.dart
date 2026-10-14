import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

ControladorSesion _controlador(ApiFalsa api) =>
    ControladorSesion(api, AlmacenEnMemoria());

Future<void> _montar(WidgetTester tester, ControladorSesion controlador) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: PantallaLogin(controlador: controlador),
    ),
  );
}

Future<void> _escribirCredenciales(
  WidgetTester tester, {
  String usuario = 'cliente1',
  String contrasena = 'CareCar2026',
}) async {
  await tester.enterText(find.byKey(PantallaLogin.campoUsuario), usuario);
  await tester.enterText(find.byKey(PantallaLogin.campoContrasena), contrasena);
}

void main() {
  group('el criterio de aceptacion de APP-2.1', () {
    testWidgets('no muestra ningun flujo de registro de cuenta nueva', (
      tester,
    ) async {
      await _montar(tester, _controlador(ApiFalsa()));

      // El criterio es explicito: «la interfaz no debe mostrar botones ni
      // flujos de Registro de cuenta nueva».
      for (final prohibido in [
        'Registrarme',
        'Registrarse',
        'Registro',
        'Crear cuenta',
        'Crear una cuenta',
        'Registrate',
        'Sign up',
        '¿No tienes cuenta?',
      ]) {
        expect(
          find.textContaining(prohibido, findRichText: true),
          findsNothing,
          reason: 'aparecio «$prohibido» y el criterio lo prohibe',
        );
      }
    });

    testWidgets('explica que las credenciales las entrega la agencia', (
      tester,
    ) async {
      await _montar(tester, _controlador(ApiFalsa()));

      expect(find.textContaining('agencia'), findsWidgets);
    });
  });

  group('el formulario', () {
    testWidgets('tiene campo de usuario y de contrasena', (tester) async {
      await _montar(tester, _controlador(ApiFalsa()));

      expect(find.byKey(PantallaLogin.campoUsuario), findsOneWidget);
      expect(find.byKey(PantallaLogin.campoContrasena), findsOneWidget);
    });

    testWidgets('las etiquetas van visibles, no solo como placeholder', (
      tester,
    ) async {
      await _montar(tester, _controlador(ApiFalsa()));

      // Regla de la guia de estilos: «las etiquetas siempre van arriba del
      // campo y visibles. Nunca se usa solo el placeholder».
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('la contrasena viene oculta', (tester) async {
      await _montar(tester, _controlador(ApiFalsa()));

      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(PantallaLogin.campoContrasena),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.obscureText, isTrue);
    });

    testWidgets('se puede mostrar y ocultar la contrasena', (tester) async {
      await _montar(tester, _controlador(ApiFalsa()));

      await tester.tap(find.byKey(PantallaLogin.botonVerContrasena));
      await tester.pump();

      var campo = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(PantallaLogin.campoContrasena),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.obscureText, isFalse);

      await tester.tap(find.byKey(PantallaLogin.botonVerContrasena));
      await tester.pump();

      campo = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(PantallaLogin.campoContrasena),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.obscureText, isTrue);
    });

    testWidgets('los campos miden 16 px, o iOS hace zoom al enfocarlos', (
      tester,
    ) async {
      await _montar(tester, _controlador(ApiFalsa()));

      for (final llave in [
        PantallaLogin.campoUsuario,
        PantallaLogin.campoContrasena,
      ]) {
        final campo = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(llave),
            matching: find.byType(TextField),
          ),
        );
        expect(
          campo.style?.fontSize,
          16,
          reason: 'regla de la guia de estilos',
        );
      }
    });

    testWidgets('el boton principal mide al menos 44 px de alto', (
      tester,
    ) async {
      await _montar(tester, _controlador(ApiFalsa()));

      final alto = tester.getSize(find.byKey(PantallaLogin.botonEntrar)).height;
      expect(alto, greaterThanOrEqualTo(44));
    });
  });

  group('validacion antes de llamar al API', () {
    testWidgets('con los campos vacios no llama al API y avisa', (
      tester,
    ) async {
      final api = ApiFalsa();
      await _montar(tester, _controlador(api));

      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(api.llamadasAlLogin, 0);
      expect(find.text('Escribe tu usuario.'), findsOneWidget);
      expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    });

    testWidgets('con solo el usuario tampoco llama al API', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester, contrasena: '');
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(api.llamadasAlLogin, 0);
    });
  });

  group('los dos mensajes de error de la tarea 3', () {
    testWidgets('credenciales invalidas se muestra en la pantalla', (
      tester,
    ) async {
      final api = ApiFalsa.queFalla(
        const CredencialesInvalidas('Usuario o contrasena incorrectos'),
      );
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester, contrasena: 'mala');
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(find.text('Usuario o contrasena incorrectos'), findsOneWidget);
    });

    testWidgets('sin conexion muestra un mensaje distinto', (tester) async {
      final api = ApiFalsa.queFalla(const SinConexion());
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo conectar con el servidor. Intenta de nuevo.'),
        findsOneWidget,
      );
    });

    testWidgets('el error no se comunica solo con color: lleva texto e icono', (
      tester,
    ) async {
      final api = ApiFalsa.queFalla(const SinConexion());
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      // Regla de la guia: «un estado nunca se comunica solo con color».
      final aviso = find.byKey(PantallaLogin.avisoDeError);
      expect(aviso, findsOneWidget);
      expect(
        find.descendant(of: aviso, matching: find.byType(Icon)),
        findsOneWidget,
      );
    });

    testWidgets('la cuenta desactivada tambien se muestra', (tester) async {
      final api = ApiFalsa.queFalla(
        const CuentaDesactivada('La cuenta esta desactivada'),
      );
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(find.text('La cuenta esta desactivada'), findsOneWidget);
    });

    testWidgets('el error se borra al reintentar', (tester) async {
      final api = ApiFalsa.queFalla(const SinConexion());
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();
      expect(find.byKey(PantallaLogin.avisoDeError), findsOneWidget);

      api.alIniciarSesion = null; // se restablece la red
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pump();

      expect(find.byKey(PantallaLogin.avisoDeError), findsNothing);
    });
  });

  group('mientras entra', () {
    testWidgets('el boton se deshabilita y cambia el texto', (tester) async {
      final puerta = Completer<void>();
      await _montar(tester, _controlador(ApiFalsa.queTarda(puerta.future)));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pump();

      // Regla de la guia: «mientras guarda, el boton se deshabilita y cambia
      // el texto».
      expect(find.text('Entrando…'), findsOneWidget);
      final boton = tester.widget<FilledButton>(
        find.byKey(PantallaLogin.botonEntrar),
      );
      expect(boton.onPressed, isNull);

      puerta.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('los campos se deshabilitan', (tester) async {
      final puerta = Completer<void>();
      await _montar(tester, _controlador(ApiFalsa.queTarda(puerta.future)));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pump();

      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(PantallaLogin.campoUsuario),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.enabled, isFalse);

      puerta.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('un doble toque no manda dos logins', (tester) async {
      final puerta = Completer<void>();
      final api = ApiFalsa.queTarda(puerta.future);
      await _montar(tester, _controlador(api));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pump();
      await tester.tap(
        find.byKey(PantallaLogin.botonEntrar),
        warnIfMissed: false,
      );
      await tester.pump();

      puerta.complete();
      await tester.pumpAndSettle();

      expect(api.llamadasAlLogin, 1);
    });
  });

  group('al entrar bien', () {
    testWidgets('avisa que la sesion quedo iniciada', (tester) async {
      var avisos = 0;
      final controlador = _controlador(ApiFalsa());
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaCareCar.claro,
          home: PantallaLogin(
            controlador: controlador,
            alIniciarSesion: () => avisos++,
          ),
        ),
      );

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(avisos, 1);
      expect(controlador.haySesion, isTrue);
    });

    testWidgets('no se queda ningun aviso de error', (tester) async {
      await _montar(tester, _controlador(ApiFalsa()));

      await _escribirCredenciales(tester);
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();

      expect(find.byKey(PantallaLogin.avisoDeError), findsNothing);
    });
  });

  group('cabe en una pantalla chica', () {
    testWidgets('a 375 px de ancho no se desborda', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _montar(tester, _controlador(ApiFalsa()));
      await tester.pumpAndSettle();

      // La guia pide que ninguna pantalla se rompa a 375 px.
      expect(tester.takeException(), isNull);
    });

    testWidgets('con el teclado abierto se puede desplazar', (tester) async {
      tester.view.physicalSize = const Size(375, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _montar(tester, _controlador(ApiFalsa()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
