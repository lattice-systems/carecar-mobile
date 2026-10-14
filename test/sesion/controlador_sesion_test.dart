import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

void main() {
  late ApiFalsa api;
  late AlmacenEnMemoria almacen;
  late ControladorSesion controlador;

  void armar([ApiFalsa? otra]) {
    api = otra ?? ApiFalsa();
    almacen = AlmacenEnMemoria();
    controlador = ControladorSesion(api, almacen);
  }

  setUp(armar);

  group('estado inicial', () {
    test('arranca sin sesion', () {
      expect(controlador.estado, isA<SinSesion>());
      expect(controlador.haySesion, isFalse);
    });

    test('no hay token guardado', () async {
      expect(await almacen.leerToken(), isNull);
    });
  });

  group('login correcto', () {
    test('queda autenticada', () async {
      await controlador.iniciarSesion(
        usuario: 'cliente1',
        contrasena: 'CareCar2026',
      );

      expect(controlador.estado, isA<Autenticada>());
      expect(controlador.haySesion, isTrue);
    });

    test(
      'manda al API el usuario y la contrasena que se escribieron',
      () async {
        await controlador.iniciarSesion(
          usuario: 'cliente1',
          contrasena: 'CareCar2026',
        );

        expect(api.ultimaPeticion!.usuario, 'cliente1');
        expect(api.ultimaPeticion!.contrasena, 'CareCar2026');
      },
    );

    test(
      'guarda el token en el almacen, que es lo que usa ClienteApi',
      () async {
        await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');

        expect(await almacen.leerToken(), 'token.valido.firmado');
      },
    );

    test('avisa a quien lo escucha', () async {
      var avisos = 0;
      controlador.addListener(() => avisos++);

      await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');

      // Al menos dos: uno al empezar a autenticar y otro al terminar.
      expect(avisos, greaterThanOrEqualTo(2));
    });

    test('expone debeCambiarContrasena para que APP-2.3 lo use', () async {
      armar(ApiFalsa.conContrasenaTemporal());

      await controlador.iniciarSesion(usuario: 'cliente2', contrasena: 'x');

      final estado = controlador.estado as Autenticada;
      expect(estado.debeCambiarContrasena, isTrue);
    });

    test(
      'con contrasena definitiva, debeCambiarContrasena viene en falso',
      () async {
        await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');

        final estado = controlador.estado as Autenticada;
        expect(estado.debeCambiarContrasena, isFalse);
      },
    );
  });

  group('mientras autentica', () {
    test('pasa por el estado Autenticando', () async {
      final puerta = Completer<void>();
      armar(ApiFalsa.queTarda(puerta.future));

      final futuro = controlador.iniciarSesion(
        usuario: 'cliente1',
        contrasena: 'x',
      );
      expect(controlador.estado, isA<Autenticando>());

      puerta.complete();
      await futuro;
      expect(controlador.estado, isA<Autenticada>());
    });

    test('no manda dos peticiones si se pide dos veces seguidas', () async {
      final puerta = Completer<void>();
      armar(ApiFalsa.queTarda(puerta.future));

      final primera = controlador.iniciarSesion(usuario: 'a', contrasena: 'b');
      final segunda = controlador.iniciarSesion(usuario: 'a', contrasena: 'b');

      puerta.complete();
      await Future.wait([primera, segunda]);

      expect(
        api.llamadasAlLogin,
        1,
        reason: 'el doble toque no debe duplicar el login',
      );
    });
  });

  group('los dos errores que pide la tarea 3', () {
    test('credenciales invalidas deja el mensaje del backend', () async {
      armar(
        ApiFalsa.queFalla(
          const CredencialesInvalidas('Usuario o contrasena incorrectos'),
        ),
      );

      await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'mala');

      final estado = controlador.estado as FalloDeSesion;
      expect(estado.mensaje, 'Usuario o contrasena incorrectos');
      expect(controlador.haySesion, isFalse);
    });

    test('sin conexion deja un mensaje distinto al de credenciales', () async {
      armar(ApiFalsa.queFalla(const SinConexion()));

      await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');

      final estado = controlador.estado as FalloDeSesion;
      expect(
        estado.mensaje,
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
      expect(estado.esFalloDeRed, isTrue);
    });

    test('credenciales invalidas no se marca como fallo de red', () async {
      armar(ApiFalsa.queFalla(const CredencialesInvalidas('Incorrectos')));

      await controlador.iniciarSesion(usuario: 'a', contrasena: 'b');

      expect((controlador.estado as FalloDeSesion).esFalloDeRed, isFalse);
    });
  });

  group('otros fallos', () {
    test('cuenta desactivada llega con su propio mensaje', () async {
      armar(
        ApiFalsa.queFalla(
          const CuentaDesactivada('La cuenta esta desactivada'),
        ),
      );

      await controlador.iniciarSesion(usuario: 'cliente3', contrasena: 'x');

      expect(
        (controlador.estado as FalloDeSesion).mensaje,
        'La cuenta esta desactivada',
      );
    });

    test('un error inesperado no tumba el controlador', () async {
      armar(ApiFalsa(alIniciarSesion: (_) async => throw StateError('boom')));

      await controlador.iniciarSesion(usuario: 'a', contrasena: 'b');

      expect(controlador.estado, isA<FalloDeSesion>());
      expect((controlador.estado as FalloDeSesion).mensaje, isNotEmpty);
    });

    test('un login fallido no deja token guardado', () async {
      armar(ApiFalsa.queFalla(const CredencialesInvalidas('Incorrectos')));

      await controlador.iniciarSesion(usuario: 'a', contrasena: 'b');

      expect(await almacen.leerToken(), isNull);
    });

    test('se puede reintentar despues de un fallo', () async {
      armar(ApiFalsa.queFalla(const SinConexion()));
      await controlador.iniciarSesion(usuario: 'a', contrasena: 'b');
      expect(controlador.estado, isA<FalloDeSesion>());

      // Se restablece la red.
      api.alIniciarSesion = null;
      await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');

      expect(controlador.estado, isA<Autenticada>());
    });
  });

  group('cerrar sesion', () {
    test('borra el token y vuelve a sin sesion', () async {
      await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');
      expect(controlador.haySesion, isTrue);

      await controlador.cerrarSesion();

      expect(controlador.estado, isA<SinSesion>());
      expect(controlador.haySesion, isFalse);
      expect(await almacen.leerToken(), isNull);
    });
  });

  group('AlmacenEnMemoria', () {
    test('guarda, lee y borra', () async {
      final a = AlmacenEnMemoria();
      expect(await a.leerToken(), isNull);

      await a.guardarToken('abc');
      expect(await a.leerToken(), 'abc');

      await a.borrarToken();
      expect(await a.leerToken(), isNull);
    });
  });
}
