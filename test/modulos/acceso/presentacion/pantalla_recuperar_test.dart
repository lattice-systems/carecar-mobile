import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_fake.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_recuperar.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

/// V2-M01.04 · la pantalla que pide el enlace de recuperacion.
///
/// El criterio con filo: **la respuesta es igual exista o no el correo**. El
/// contrato responde 202 en los dos casos para no revelar que cuentas hay
/// registradas, y la pantalla no debe deshacer eso con un mensaje distinto.
void main() {
  late RepositorioAccesoFake repositorio;

  setUp(() => repositorio = RepositorioAccesoFake());

  Future<void> montar(WidgetTester tester, {String? correoInicial}) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [repositorioAccesoProvider.overrideWithValue(repositorio)],
          child: conTemaPista(PantallaRecuperar(correoInicial: correoInicial)),
        ),
      );

  Future<void> pedir(WidgetTester tester, {String? correo}) async {
    if (correo != null) {
      await tester.enterText(find.byKey(PantallaRecuperar.campoCorreo), correo);
    }
    final boton = find.byKey(PantallaRecuperar.botonEnviar);
    await tester.ensureVisible(boton);
    await tester.pump();
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  group('no revela que cuentas existen', () {
    testWidgets('un correo registrado lleva al mismo aviso', (tester) async {
      await montar(tester);
      await pedir(tester, correo: 'cliente1@example.com');

      expect(find.byKey(PantallaRecuperar.avisoEnviado), findsOneWidget);
      expect(repositorio.llamadasAlPedirEnlace, 1);
    });

    testWidgets('un correo inexistente lleva al mismo aviso', (tester) async {
      // El repositorio termina bien igual, porque el servidor responde 202.
      await montar(tester);
      await pedir(tester, correo: 'nadie@example.com');

      expect(find.byKey(PantallaRecuperar.avisoEnviado), findsOneWidget);
    });

    testWidgets('el aviso no nombra el correo que se escribio', (tester) async {
      // Repetirlo no revela nada por si mismo, pero el texto debe explicar
      // que puede no llegar nada, para que quien se equivoco no espere.
      await montar(tester);
      await pedir(tester, correo: 'cliente1@example.com');

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaRecuperar.avisoEnviado),
      );
      expect(aviso.tono, Tono.informacion);
      expect(find.textContaining('Revisa tu correo'), findsOneWidget);
    });
  });

  group('valida antes de pedirle algo al servidor', () {
    testWidgets('sin correo no llama', (tester) async {
      await montar(tester);
      await pedir(tester, correo: '');

      expect(repositorio.llamadasAlPedirEnlace, 0);
      expect(find.text('Escribe tu correo.'), findsOneWidget);
    });

    testWidgets('un correo sin arroba no llama', (tester) async {
      await montar(tester);
      await pedir(tester, correo: 'cliente1');

      expect(repositorio.llamadasAlPedirEnlace, 0);
    });

    testWidgets('manda el correo recortado', (tester) async {
      await montar(tester);
      await pedir(tester, correo: '  cliente1@example.com  ');

      expect(repositorio.ultimoCorreo, 'cliente1@example.com');
    });
  });

  group('llega con el correo que ya se escribio en el acceso', () {
    testWidgets('viene puesto y no hay que teclearlo otra vez', (tester) async {
      await montar(tester, correoInicial: 'cliente1@example.com');

      await pedir(tester);

      expect(repositorio.llamadasAlPedirEnlace, 1);
      expect(repositorio.ultimoCorreo, 'cliente1@example.com');
    });
  });

  group('cuando algo falla', () {
    testWidgets('sin conexion es advertencia y se puede reintentar', (
      tester,
    ) async {
      repositorio.falla = const SinConexion();
      await montar(tester);
      await pedir(tester, correo: 'cliente1@example.com');

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaRecuperar.avisoDeError),
      );
      expect(aviso.tono, Tono.advertencia);
      // No se muestra el aviso de enviado si no se envio nada.
      expect(find.byKey(PantallaRecuperar.avisoEnviado), findsNothing);
    });

    testWidgets('un bloqueo por intentos se distingue', (tester) async {
      // Recuperar tambien se limita (429): insistir no sirve.
      repositorio.falla = const DemasiadosIntentos(
        'Demasiados intentos.',
        esperaSegundos: 900,
      );
      await montar(tester);
      await pedir(tester, correo: 'cliente1@example.com');

      expect(find.text('Demasiados intentos'), findsOneWidget);
      expect(find.byKey(PantallaRecuperar.avisoEnviado), findsNothing);
    });
  });

  group('mientras envia', () {
    testWidgets('dos toques seguidos mandan una sola peticion', (tester) async {
      final respuesta = Completer<void>();
      repositorio.esperar = respuesta.future;
      await montar(tester, correoInicial: 'cliente1@example.com');

      final boton = find.byKey(PantallaRecuperar.botonEnviar);
      await tester.ensureVisible(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pump();

      expect(repositorio.llamadasAlPedirEnlace, 1);

      respuesta.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(PantallaRecuperar.avisoEnviado), findsOneWidget);
    });
  });
}
