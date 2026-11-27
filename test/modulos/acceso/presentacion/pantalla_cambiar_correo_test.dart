import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fallos_de_prueba.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.07 · cambiar mi correo, con su verificación.
///
/// Son dos pasos y el segundo no puede empezar sin el primero. Lo que más se
/// prueba aquí es que **los tres errores se vean distintos**: la contraseña
/// equivocada y el correo mal escrito llegan los dos como 400 del servidor, y
/// si la pantalla los confundiera le diría a la persona que corrija lo que
/// estaba bien.
void main() {
  PerfilDelCliente perfil() => PerfilDelCliente(
    nombre: 'María Elena Robles',
    correo: 'cliente1@example.com',
    telefono: '477 123 4567',
    clienteDesde: DateTime(2022, 5, 18),
  );

  Widget app(
    RepositorioAccesoFake repo, {
    Escenario escenario = Escenario.claro,
  }) => ProviderScope(
    overrides: [repositorioAccesoProvider.overrideWithValue(repo)],
    child: conTemaPista(const PantallaCambiarCorreo(), escenario: escenario),
  );

  RepositorioAccesoFake conPerfil() =>
      RepositorioAccesoFake()..perfilDelCliente = perfil();

  void prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
      testWidgets(descripcion, (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await cuerpo(tester);
      });

  /// Se busca por llave y no por etiqueta: `CampoTexto` pinta la etiqueta
  /// **arriba** del campo, no dentro, asi que `widgetWithText(TextField, ...)`
  /// no lo encontraria.
  Future<void> escribir(WidgetTester tester, Key campo, String texto) async {
    await tester.ensureVisible(find.byKey(campo));
    await tester.enterText(find.byKey(campo), texto);
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    final boton = find.text(texto);
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  group('pedir el cambio', () {
    prueba('no deja pedirlo sin correo y sin contrasena', (tester) async {
      await tester.pumpWidget(app(conPerfil()));
      await tester.pumpAndSettle();

      await tocar(tester, 'Enviar el código');

      // Ni se intentó: el servidor no tiene que enseñarnos lo que ya sabemos.
      expect(conPerfil().correoPedido, isNull);
      expect(find.text('Escribe el código'), findsNothing);
    });

    prueba('un correo sin formato se detiene aqui, sin viajar', (tester) async {
      final repo = conPerfil();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await escribir(tester, PantallaCambiarCorreo.campoCorreo, 'no-es-correo');
      await escribir(
        tester,
        PantallaCambiarCorreo.campoContrasena,
        'CareCar2026',
      );
      await tocar(tester, 'Enviar el código');

      expect(find.text('Escribe un correo válido'), findsOneWidget);
      expect(repo.correoPedido, isNull);
    });

    prueba('con los dos datos manda el codigo y pasa al segundo paso', (
      tester,
    ) async {
      final repo = conPerfil();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await escribir(
        tester,
        PantallaCambiarCorreo.campoCorreo,
        'maria.nueva@example.com',
      );
      await escribir(
        tester,
        PantallaCambiarCorreo.campoContrasena,
        'CareCar2026',
      );
      await tocar(tester, 'Enviar el código');

      expect(repo.correoPedido, 'maria.nueva@example.com');
      expect(repo.contrasenaDelCambio, 'CareCar2026');
      // El segundo paso dice a dónde fue el código.
      expect(find.textContaining('maria.nueva@example.com'), findsWidgets);
      expect(find.byKey(PantallaCambiarCorreo.campoCodigo), findsOneWidget);
    });
  });

  group('los tres errores se ven distintos', () {
    prueba('la contrasena equivocada culpa a la contrasena', (tester) async {
      final repo = conPerfil()
        ..fallaAlPedirCambio = const ContrasenaNoCoincide();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await escribir(
        tester,
        PantallaCambiarCorreo.campoCorreo,
        'maria.nueva@example.com',
      );
      await escribir(tester, PantallaCambiarCorreo.campoContrasena, 'mala');
      await tocar(tester, 'Enviar el código');

      expect(find.text('Tu contraseña no coincide'), findsOneWidget);
      // Y no se pasa al segundo paso.
      expect(find.byKey(PantallaCambiarCorreo.campoCodigo), findsNothing);
    });

    prueba('un correo de otro cliente lo dice sin culpar a la contrasena', (
      tester,
    ) async {
      final repo = conPerfil()..fallaAlPedirCambio = const CorreoEnUso();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await escribir(
        tester,
        PantallaCambiarCorreo.campoCorreo,
        'cliente2@example.com',
      );
      await escribir(
        tester,
        PantallaCambiarCorreo.campoContrasena,
        'CareCar2026',
      );
      await tocar(tester, 'Enviar el código');

      expect(find.text('Ese correo ya está en uso'), findsOneWidget);
      expect(find.text('Tu contraseña no coincide'), findsNothing);
    });

    prueba('sin conexion no culpa a nadie', (tester) async {
      final repo = conPerfil()..fallaAlPedirCambio = Fallos.sinConexion();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await escribir(
        tester,
        PantallaCambiarCorreo.campoCorreo,
        'maria.nueva@example.com',
      );
      await escribir(
        tester,
        PantallaCambiarCorreo.campoContrasena,
        'CareCar2026',
      );
      await tocar(tester, 'Enviar el código');

      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.text('Tu contraseña no coincide'), findsNothing);
      expect(find.text('Ese correo ya está en uso'), findsNothing);
    });
  });

  group('confirmar', () {
    Future<RepositorioAccesoFake> enElSegundoPaso(WidgetTester tester) async {
      final repo = conPerfil();
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();
      await escribir(
        tester,
        PantallaCambiarCorreo.campoCorreo,
        'maria.nueva@example.com',
      );
      await escribir(
        tester,
        PantallaCambiarCorreo.campoContrasena,
        'CareCar2026',
      );
      await tocar(tester, 'Enviar el código');
      return repo;
    }

    prueba('el codigo correcto lo deja listo', (tester) async {
      final repo = await enElSegundoPaso(tester);

      await escribir(tester, PantallaCambiarCorreo.campoCodigo, '123456');
      await tocar(tester, 'Confirmar');

      expect(repo.codigoConfirmado, '123456');
      expect(find.text('Tu correo quedó actualizado'), findsOneWidget);
    });

    prueba('un codigo equivocado lo dice y deja intentar otra vez', (
      tester,
    ) async {
      final repo = await enElSegundoPaso(tester);
      repo.fallaAlConfirmar = const CodigoNoValido();

      await escribir(tester, PantallaCambiarCorreo.campoCodigo, '000000');
      await tocar(tester, 'Confirmar');

      expect(
        find.text('Ese código no es válido, ya se usó o venció'),
        findsOneWidget,
      );
      // El campo sigue ahi: la salida es volver a intentar o pedir otro.
      expect(find.byKey(PantallaCambiarCorreo.campoCodigo), findsOneWidget);
    });

    prueba('no deja confirmar con menos de seis digitos', (tester) async {
      final repo = await enElSegundoPaso(tester);

      await escribir(tester, PantallaCambiarCorreo.campoCodigo, '123');
      await tocar(tester, 'Confirmar');

      expect(repo.codigoConfirmado, isNull);
    });
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('se ve completa en ${escenario.name} sin desbordar', (tester) async {
      await tester.pumpWidget(app(conPerfil(), escenario: escenario));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Enviar el código'), findsOneWidget);
    });
  }
}
