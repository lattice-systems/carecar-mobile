import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_fake.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/fallos_acceso.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_cambiar_contrasena.dart'
    show ListaDeReglas;
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_nueva_contrasena.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// V2-M01.04 · la pantalla a la que abre el enlace del correo.
///
/// Dos criterios se cruzan aqui y es lo delicado de la historia: **un enlace
/// vencido o usado y una contrasena que no cumple llegan los dos como 400**.
/// El primero tiene que ofrecer «pide otro enlace»; el segundo no, porque el
/// enlace estaba bien y ofrecer otro manda a la persona a empezar de cero sin
/// motivo.
void main() {
  late RepositorioAccesoFake repositorio;

  setUp(() => repositorio = RepositorioAccesoFake());

  /// La pantalla dentro de un enrutador con `/recuperar`, para comprobar de
  /// verdad a donde lleva «pedir otro enlace».
  Future<void> montar(WidgetTester tester, {String? token}) {
    final enrutador = GoRouter(
      initialLocation: token == null
          ? Rutas.restablecer
          : '${Rutas.restablecer}?token=$token',
      routes: [
        GoRoute(
          path: Rutas.restablecer,
          builder: (context, state) => PantallaNuevaContrasena(
            token: state.uri.queryParameters['token'],
          ),
        ),
        GoRoute(
          path: Rutas.recuperar,
          builder: (_, _) => const Scaffold(body: Text('pedir otro')),
        ),
      ],
    );

    return tester.pumpWidget(
      ProviderScope(
        overrides: [repositorioAccesoProvider.overrideWithValue(repositorio)],
        child: MaterialApp.router(
          // En produccion lo pone `rutas_acceso.dart` con su envoltorio; aqui
          // la ruta se arma a mano, asi que el tema va aqui.
          theme: TemaPista.claro(),
          locale: idiomaBase,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          routerConfig: enrutador,
        ),
      ),
    );
  }

  Future<void> llenar(
    WidgetTester tester, {
    String nueva = 'carecar2026',
    String? confirmar,
  }) async {
    await tester.enterText(
      find.byKey(PantallaNuevaContrasena.campoNueva),
      nueva,
    );
    await tester.enterText(
      find.byKey(PantallaNuevaContrasena.campoConfirmar),
      confirmar ?? nueva,
    );
    await tester.pump();
  }

  Future<void> guardar(WidgetTester tester) async {
    final boton = find.byKey(PantallaNuevaContrasena.botonGuardar);
    await tester.ensureVisible(boton);
    await tester.pump();
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  group('el enlace trae el token', () {
    testWidgets('con token se puede escribir la contrasena', (tester) async {
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();

      expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsOneWidget);
      expect(find.byType(ListaDeReglas), findsOneWidget);
    });

    testWidgets('sin token no se pide nada: el enlace esta roto', (
      tester,
    ) async {
      // `carecar://restablecer` sin token no sirve para nada, y pedir una
      // contrasena para despues fallar seria perder el tiempo de la persona.
      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsNothing);
      expect(
        find.byKey(PantallaNuevaContrasena.avisoEnlaceNoValido),
        findsOneWidget,
      );
      expect(
        find.byKey(PantallaNuevaContrasena.botonPedirOtro),
        findsOneWidget,
      );
    });
  });

  group('no manda lo que el servidor va a rechazar', () {
    testWidgets('con las reglas sin cumplir no llama', (tester) async {
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester, nueva: 'corta1');
      await guardar(tester);

      expect(repositorio.ultimoToken, isNull);
    });

    testWidgets('si la confirmacion no coincide, avisa y no llama', (
      tester,
    ) async {
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester, nueva: 'carecar2026', confirmar: 'carecar2027');
      await guardar(tester);

      expect(repositorio.ultimoToken, isNull);
      expect(find.text('Las dos contraseñas no son iguales.'), findsOneWidget);
    });
  });

  group('al guardar bien', () {
    testWidgets('manda el token del enlace y la contrasena', (tester) async {
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester);
      await guardar(tester);

      expect(repositorio.ultimoToken, 'abc123');
      expect(repositorio.ultimaContrasenaDelEnlace, 'carecar2026');
      expect(find.byKey(PantallaNuevaContrasena.avisoListo), findsOneWidget);
    });

    testWidgets('ofrece ir a iniciar sesion y ya no deja guardar otra vez', (
      tester,
    ) async {
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester);
      await guardar(tester);

      expect(
        find.byKey(PantallaNuevaContrasena.botonIrAlAcceso),
        findsOneWidget,
      );
      // El token es de un solo uso: dejar el boton de guardar invitaria a
      // repetir, y eso daria «el enlace ya no sirve» sobre una operacion que
      // si funciono.
      expect(find.byKey(PantallaNuevaContrasena.botonGuardar), findsNothing);
      expect(repositorio.llamadasAlRestablecer, 1);
    });
  });

  group('los dos 400 se ven distintos', () {
    testWidgets('enlace vencido o usado: ofrece pedir otro', (tester) async {
      repositorio.fallaDelEnlace = const EnlaceNoValido();
      await montar(tester, token: 'gastado');
      await tester.pumpAndSettle();
      await llenar(tester);
      await guardar(tester);

      expect(
        find.byKey(PantallaNuevaContrasena.avisoEnlaceNoValido),
        findsOneWidget,
      );
      expect(
        find.byKey(PantallaNuevaContrasena.botonPedirOtro),
        findsOneWidget,
      );
      // Y ya no tiene sentido seguir escribiendo con este enlace.
      expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsNothing);
    });

    testWidgets('contrasena rechazada: NO ofrece pedir otro', (tester) async {
      // El enlace estaba bien. Mandar a pedir otro seria hacerle empezar de
      // cero sin motivo.
      repositorio.fallaDelEnlace = const DatosInvalidos('Revisa los datos.');
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester);
      await guardar(tester);

      expect(find.byKey(PantallaNuevaContrasena.botonPedirOtro), findsNothing);
      expect(
        find.byKey(PantallaNuevaContrasena.avisoEnlaceNoValido),
        findsNothing,
      );
      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaNuevaContrasena.avisoDeError),
      );
      expect(aviso.tono, Tono.peligro);
      // Se puede corregir y volver a intentar con el mismo enlace.
      expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsOneWidget);
    });

    testWidgets('sin conexion es advertencia y conserva el enlace', (
      tester,
    ) async {
      repositorio.fallaDelEnlace = const SinConexion();
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester);
      await guardar(tester);

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaNuevaContrasena.avisoDeError),
      );
      expect(aviso.tono, Tono.advertencia);
      expect(find.byKey(PantallaNuevaContrasena.campoNueva), findsOneWidget);
    });
  });

  group('pedir otro enlace', () {
    testWidgets('lleva a la pantalla de recuperacion', (tester) async {
      await montar(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(PantallaNuevaContrasena.botonPedirOtro));
      await tester.pumpAndSettle();

      expect(find.text('pedir otro'), findsOneWidget);
    });
  });

  group('mientras guarda', () {
    testWidgets('dos toques mandan una sola peticion', (tester) async {
      final respuesta = Completer<void>();
      repositorio.esperar = respuesta.future;
      await montar(tester, token: 'abc123');
      await tester.pumpAndSettle();
      await llenar(tester);

      final boton = find.byKey(PantallaNuevaContrasena.botonGuardar);
      await tester.ensureVisible(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pump();

      expect(repositorio.llamadasAlRestablecer, 1);

      respuesta.complete();
      await tester.pumpAndSettle();
    });
  });
}
