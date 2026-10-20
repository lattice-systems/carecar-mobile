// APP-2.3 · «En el primer ingreso se obliga a cambiar la contrasena temporal».

import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/pantallas/pantalla_cambiar_contrasena.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

Future<void> _montar(
  WidgetTester tester,
  ApiFalsa api, {
  VoidCallback? alCambiar,
  VoidCallback? alCerrarSesion,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: PantallaCambiarContrasena(
        api: api,
        alCambiar: alCambiar ?? () {},
        alCerrarSesion: alCerrarSesion ?? () {},
      ),
    ),
  );
}

Future<void> _llenar(
  WidgetTester tester, {
  String actual = 'Temporal123',
  String nueva = 'NuevaClave1',
  String? confirmar,
}) async {
  await tester.enterText(
    find.byKey(PantallaCambiarContrasena.campoActual),
    actual,
  );
  await tester.enterText(
    find.byKey(PantallaCambiarContrasena.campoNueva),
    nueva,
  );
  await tester.enterText(
    find.byKey(PantallaCambiarContrasena.campoConfirmar),
    confirmar ?? nueva,
  );
}

void main() {
  group('el criterio: no se puede continuar sin cambiarla', () {
    testWidgets('no hay boton de regreso ni de omitir', (tester) async {
      await _montar(tester, ApiFalsa());

      expect(find.byType(BackButton), findsNothing);
      for (final texto in const [
        'Omitir',
        'Más tarde',
        'Mas tarde',
        'Saltar',
        'Ahora no',
        'Continuar sin cambiar',
      ]) {
        expect(
          find.text(texto),
          findsNothing,
          reason: 'no debe haber forma de saltarse el cambio: «$texto»',
        );
      }
    });

    testWidgets('la unica salida es cerrar sesion', (tester) async {
      var cerradas = 0;
      await _montar(tester, ApiFalsa(), alCerrarSesion: () => cerradas++);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonCerrarSesion));
      await tester.pump();

      expect(cerradas, 1);
    });
  });

  group('validacion antes de llamar al API', () {
    testWidgets('con los campos vacios no manda nada', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaNueva, isNull);
    });

    testWidgets('una contrasena sin numero no se manda', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _llenar(tester, nueva: 'solamenteletras');

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaNueva, isNull);
      expect(
        find.text('La contraseña debe tener al menos un número.'),
        findsOneWidget,
      );
    });

    testWidgets('si las dos nuevas no coinciden, lo dice', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _llenar(tester, nueva: 'NuevaClave1', confirmar: 'OtraClave1');

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaNueva, isNull);
      expect(find.textContaining('iguales'), findsOneWidget);
    });

    testWidgets('la nueva no puede ser igual a la temporal', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _llenar(tester, actual: 'Temporal123', nueva: 'Temporal123');

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaNueva, isNull);
      expect(find.textContaining('distinta'), findsOneWidget);
    });
  });

  group('el camino feliz', () {
    testWidgets('manda la actual y la nueva, y avisa', (tester) async {
      var cambios = 0;
      final api = ApiFalsa();
      await _montar(tester, api, alCambiar: () => cambios++);
      await _llenar(tester);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimaActual, 'Temporal123');
      expect(api.ultimaNueva, 'NuevaClave1');
      expect(cambios, 1);
    });

    testWidgets('mientras guarda, el boton cambia y se deshabilita', (
      tester,
    ) async {
      final espera = Completer<void>();
      final api = ApiFalsa()
        ..alCambiarContrasena = (_, _) async => espera.future;
      await _montar(tester, api);
      await _llenar(tester);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pump();

      expect(find.text('Guardando…'), findsOneWidget);
      final boton = tester.widget<FilledButton>(
        find.byKey(PantallaCambiarContrasena.botonGuardar),
      );
      expect(boton.onPressed, isNull);

      espera.complete();
      await tester.pumpAndSettle();
    });
  });

  group('los errores', () {
    testWidgets('la temporal equivocada se muestra como error', (tester) async {
      final api = ApiFalsa()
        ..alCambiarContrasena = (_, _) async =>
            throw const DatosInvalidos('La contraseña actual no coincide');
      await _montar(tester, api);
      await _llenar(tester);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(
        find.byKey(PantallaCambiarContrasena.avisoDeError),
        findsOneWidget,
      );
      expect(find.text('La contraseña actual no coincide'), findsOneWidget);
    });

    testWidgets('sin conexion se distingue del resto', (tester) async {
      final api = ApiFalsa()
        ..alCambiarContrasena = (_, _) async => throw const SinConexion();
      await _montar(tester, api);
      await _llenar(tester);

      await tester.tap(find.byKey(PantallaCambiarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('despues de un error se puede volver a intentar', (
      tester,
    ) async {
      var intentos = 0;
      final api = ApiFalsa()
        ..alCambiarContrasena = (_, _) async {
          intentos++;
          if (intentos == 1) throw const SinConexion();
        };
      await _montar(tester, api);
      await _llenar(tester);

      final boton = find.byKey(PantallaCambiarContrasena.botonGuardar);
      await tester.tap(boton);
      await tester.pumpAndSettle();

      // El aviso de error empuja el formulario hacia abajo, asi que hay que
      // asegurarse de que el boton siga visible antes del segundo toque.
      await tester.ensureVisible(boton);
      await tester.pumpAndSettle();
      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(intentos, 2);
    });
  });

  testWidgets('cabe en una pantalla de 375 px sin desbordarse', (tester) async {
    tester.view.physicalSize = const Size(375, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _montar(tester, ApiFalsa());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
