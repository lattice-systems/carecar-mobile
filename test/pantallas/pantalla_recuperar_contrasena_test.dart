// APP-2.3 · «La recuperacion es por correo, con un codigo de un solo uso que
// expira» (criterio del backlog, ajustado por RIC-18: codigo, no enlace).

import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/pantallas/pantalla_recuperar_contrasena.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

Future<void> _montar(
  WidgetTester tester,
  ApiFalsa api, {
  String? correoInicial,
  VoidCallback? alVolver,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: PantallaRecuperarContrasena(
        api: api,
        correoInicial: correoInicial,
        alVolver: alVolver ?? () {},
      ),
    ),
  );
}

/// Pide el codigo y deja la pantalla en el segundo paso.
Future<void> _pedirCodigo(
  WidgetTester tester, {
  String correo = 'cliente1@example.com',
}) async {
  await tester.enterText(
    find.byKey(PantallaRecuperarContrasena.campoCorreo),
    correo,
  );
  await tester.tap(find.byKey(PantallaRecuperarContrasena.botonEnviar));
  await tester.pumpAndSettle();
}

void main() {
  group('paso 1 · pedir el codigo', () {
    testWidgets('hereda el correo que ya se escribio en el login', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa(), correoInicial: 'cliente1@example.com');

      final campo = tester.widget<TextFormField>(
        find.byKey(PantallaRecuperarContrasena.campoCorreo),
      );
      expect(campo.controller?.text, 'cliente1@example.com');
    });

    testWidgets('un correo mal escrito no se manda', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);

      await _pedirCodigo(tester, correo: 'esto-no-es-un-correo');

      expect(api.llamadasAlRecuperar, 0);
      expect(find.textContaining('correo válido'), findsOneWidget);
    });

    testWidgets('con un correo valido pasa al segundo paso', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);

      await _pedirCodigo(tester);

      expect(api.ultimoCorreoDeRecuperacion, 'cliente1@example.com');
      expect(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        findsOneWidget,
      );
    });

    testWidgets('avisa que la respuesta es la misma exista o no la cuenta', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa());

      // El contrato responde 202 siempre, para no revelar que cuentas hay. Si
      // la app no lo explica, quien escribio mal su correo se queda esperando.
      expect(
        find.textContaining('Si ese correo tiene una cuenta'),
        findsOneWidget,
      );
    });

    testWidgets('mientras envia, el boton se deshabilita', (tester) async {
      final espera = Completer<void>();
      final api = ApiFalsa()..alRecuperarContrasena = (_) => espera.future;
      await _montar(tester, api);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCorreo),
        'cliente1@example.com',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonEnviar));
      await tester.pump();

      expect(find.text('Enviando…'), findsOneWidget);

      espera.complete();
      await tester.pumpAndSettle();
    });
  });

  group('paso 2 · escribir el codigo', () {
    testWidgets('el codigo debe tener 6 digitos', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '123',
      );
      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoNueva),
        'NuevaClave1',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimoRestablecimiento, isNull);
      expect(find.textContaining('6 dígitos'), findsWidgets);
    });

    testWidgets('solo deja escribir numeros', (tester) async {
      await _montar(tester, ApiFalsa());
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        'abc123def',
      );
      await tester.pump();

      final campo = tester.widget<TextFormField>(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
      );
      expect(campo.controller?.text, '123');
    });

    testWidgets('una contrasena que no cumple no se manda', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '123456',
      );
      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoNueva),
        'sinnumeros',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(api.ultimoRestablecimiento, isNull);
    });

    testWidgets('manda correo, codigo y contrasena nueva', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '123456',
      );
      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoNueva),
        'NuevaClave1',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      final peticion = api.ultimoRestablecimiento!;
      expect(peticion.correo, 'cliente1@example.com');
      expect(peticion.codigo, '123456');
      expect(peticion.contrasenaNueva, 'NuevaClave1');
    });

    testWidgets('un codigo invalido lo dice con su mensaje', (tester) async {
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async => throw const DatosInvalidos(
          'El código no es válido o ya venció. Pide uno nuevo.',
        );
      await _montar(tester, api);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '999999',
      );
      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoNueva),
        'NuevaClave1',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(
        find.text('El código no es válido o ya venció. Pide uno nuevo.'),
        findsOneWidget,
      );
    });

    testWidgets('pedir otro codigo limpia el anterior', (tester) async {
      final api = ApiFalsa();
      await _montar(tester, api);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '111111',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonOtroCodigo));
      await tester.pumpAndSettle();

      // RIC-19: pedir uno nuevo invalida el anterior, asi que dejarlo escrito
      // solo serviria para que el cliente mande uno que ya no sirve.
      final campo = tester.widget<TextFormField>(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
      );
      expect(campo.controller?.text, isEmpty);
      expect(api.llamadasAlRecuperar, 2);
    });
  });

  group('paso 3 · listo', () {
    testWidgets('al cambiarla ofrece volver a iniciar sesion', (tester) async {
      var volvio = 0;
      await _montar(tester, ApiFalsa(), alVolver: () => volvio++);
      await _pedirCodigo(tester);

      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoCodigo),
        '123456',
      );
      await tester.enterText(
        find.byKey(PantallaRecuperarContrasena.campoNueva),
        'NuevaClave1',
      );
      await tester.tap(find.byKey(PantallaRecuperarContrasena.botonGuardar));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      expect(volvio, 1);
    });
  });

  testWidgets('sin conexion se distingue de un error de datos', (tester) async {
    final api = ApiFalsa()
      ..alRecuperarContrasena = (_) async => throw const SinConexion();
    await _montar(tester, api);

    await _pedirCodigo(tester);

    expect(find.text('Sin conexión'), findsOneWidget);
    // Se queda en el paso 1: no tiene sentido pedir un codigo que no llego.
    expect(find.byKey(PantallaRecuperarContrasena.campoCodigo), findsNothing);
  });
}
