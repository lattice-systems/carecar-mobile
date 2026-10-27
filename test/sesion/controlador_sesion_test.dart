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
      expect((await almacen.leer())?.accessToken, isNull);
    });
  });

  group('login correcto', () {
    test('queda autenticada', () async {
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );

      expect(controlador.estado, isA<Autenticada>());
      expect(controlador.haySesion, isTrue);
    });

    test(
      'manda al API el usuario y la contrasena que se escribieron',
      () async {
        await controlador.iniciarSesion(
          correo: 'cliente1@example.com',
          contrasena: 'CareCar2026',
        );

        expect(api.ultimaPeticion!.correo, 'cliente1@example.com');
        expect(api.ultimaPeticion!.contrasena, 'CareCar2026');
      },
    );

    test(
      'guarda el token en el almacen, que es lo que usa ClienteApi',
      () async {
        await controlador.iniciarSesion(
          correo: 'cliente1@example.com',
          contrasena: 'x',
        );

        expect((await almacen.leer())?.accessToken, 'token.valido.firmado');
      },
    );

    test('avisa a quien lo escucha', () async {
      var avisos = 0;
      controlador.addListener(() => avisos++);

      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      // Al menos dos: uno al empezar a autenticar y otro al terminar.
      expect(avisos, greaterThanOrEqualTo(2));
    });

    test('expone debeCambiarContrasena para que APP-2.3 lo use', () async {
      armar(ApiFalsa.conContrasenaTemporal());

      await controlador.iniciarSesion(
        correo: 'cliente2@example.com',
        contrasena: 'x',
      );

      final estado = controlador.estado as Autenticada;
      expect(estado.debeCambiarContrasena, isTrue);
    });

    test(
      'con contrasena definitiva, debeCambiarContrasena viene en falso',
      () async {
        await controlador.iniciarSesion(
          correo: 'cliente1@example.com',
          contrasena: 'x',
        );

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
        correo: 'cliente1@example.com',
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

      final primera = controlador.iniciarSesion(
        correo: 'a@example.com',
        contrasena: 'b',
      );
      final segunda = controlador.iniciarSesion(
        correo: 'a@example.com',
        contrasena: 'b',
      );

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

      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'mala',
      );

      final estado = controlador.estado as FalloDeSesion;
      expect(estado.mensaje, 'Usuario o contrasena incorrectos');
      expect(controlador.haySesion, isFalse);
    });

    test('sin conexion deja un mensaje distinto al de credenciales', () async {
      armar(ApiFalsa.queFalla(const SinConexion()));

      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      final estado = controlador.estado as FalloDeSesion;
      expect(
        estado.mensaje,
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
      expect(estado.esFalloDeRed, isTrue);
    });

    test('credenciales invalidas no se marca como fallo de red', () async {
      armar(ApiFalsa.queFalla(const CredencialesInvalidas('Incorrectos')));

      await controlador.iniciarSesion(correo: 'a@example.com', contrasena: 'b');

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

      await controlador.iniciarSesion(
        correo: 'cliente3@example.com',
        contrasena: 'x',
      );

      expect(
        (controlador.estado as FalloDeSesion).mensaje,
        'La cuenta esta desactivada',
      );
    });

    test('un error inesperado no tumba el controlador', () async {
      armar(ApiFalsa(alIniciarSesion: (_) async => throw StateError('boom')));

      await controlador.iniciarSesion(correo: 'a@example.com', contrasena: 'b');

      expect(controlador.estado, isA<FalloDeSesion>());
      expect((controlador.estado as FalloDeSesion).mensaje, isNotEmpty);
    });

    test('un login fallido no deja token guardado', () async {
      armar(ApiFalsa.queFalla(const CredencialesInvalidas('Incorrectos')));

      await controlador.iniciarSesion(correo: 'a@example.com', contrasena: 'b');

      expect((await almacen.leer())?.accessToken, isNull);
    });

    test('se puede reintentar despues de un fallo', () async {
      armar(ApiFalsa.queFalla(const SinConexion()));
      await controlador.iniciarSesion(correo: 'a@example.com', contrasena: 'b');
      expect(controlador.estado, isA<FalloDeSesion>());

      // Se restablece la red.
      api.alIniciarSesion = null;
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      expect(controlador.estado, isA<Autenticada>());
    });
  });

  group('cerrar sesion', () {
    test('borra el token y vuelve a sin sesion', () async {
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );
      expect(controlador.haySesion, isTrue);

      await controlador.cerrarSesion();

      expect(controlador.estado, isA<SinSesion>());
      expect(controlador.haySesion, isFalse);
      expect((await almacen.leer())?.accessToken, isNull);
    });
  });

  // El grupo que probaba AlmacenEnMemoria se movio a
  // test/sesion/almacen_sesion_test.dart, junto con TokensSesion y
  // AlmacenSeguro: ahi se prueban las tres implementaciones del almacen en un
  // solo lugar, en lugar de una aqui y las otras aparte.

  // --- TEC-6 T3 y T4 · la sesion que sobrevive y se renueva ---

  /// Deja en el almacen un par ya guardado, como si la app se hubiera cerrado.
  Future<void> dejarSesionGuardada({
    String acceso = 'acceso.guardado',
    String refresco = 'refresco.guardado',
    Duration vida = const Duration(hours: 1),
  }) => almacen.guardar(
    TokensSesion.conVida(
      accessToken: acceso,
      refreshToken: refresco,
      segundos: vida.inSeconds,
    ),
  );

  group('login con la sesion de la v1.1', () {
    test('guarda el par completo, no solo el access token', () async {
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      final guardado = await almacen.leer();
      expect(guardado?.accessToken, 'token.valido.firmado');
      expect(guardado?.refreshToken, 'refresco.valido');
      expect(guardado?.vencido, isFalse);
    });
  });

  group('restaurar al abrir la app', () {
    test('sin nada guardado se queda sin sesion', () async {
      await controlador.restaurar();

      expect(controlador.estado, isA<SinSesion>());
      expect(api.refrescosPedidos, isEmpty);
    });

    test('con una sesion vigente entra sin pedir contrasena', () async {
      // Es el objetivo de toda la tarea: el cliente abre la app y ya esta
      // dentro.
      await dejarSesionGuardada();

      await controlador.restaurar();

      expect(controlador.haySesion, isTrue);
      expect(api.refrescosPedidos, isEmpty, reason: 'no hacia falta refrescar');
    });

    test('con el access token vencido lo renueva en silencio', () async {
      await dejarSesionGuardada(
        refresco: 'refresco.viejo',
        vida: Duration.zero,
      );

      await controlador.restaurar();

      expect(api.refrescosPedidos, ['refresco.viejo']);
      expect(controlador.haySesion, isTrue);
      expect((await almacen.leer())?.accessToken, 'token.renovado.firmado');
    });

    test('si el refresh tambien murio, pide entrar de nuevo', () async {
      armar(
        ApiFalsa()
          ..alRefrescar = (_) async =>
              throw const CredencialesInvalidas('La sesion termino'),
      );
      await dejarSesionGuardada(vida: Duration.zero);

      await controlador.restaurar();

      expect(controlador.estado, isA<SinSesion>());
      expect(await almacen.leer(), isNull, reason: 'no se queda basura');
    });
  });

  group('renovar', () {
    test('rota el par y guarda el ultimo', () async {
      // RIC-2: el refresh es de un solo uso, asi que guardar el viejo dejaria
      // la sesion muerta en el siguiente refresco.
      await dejarSesionGuardada(refresco: 'refresco.1');

      expect(await controlador.renovar(), isTrue);

      final guardado = await almacen.leer();
      expect(guardado?.accessToken, 'token.renovado.firmado');
      expect(guardado?.refreshToken, 'refresco.renovado');
    });

    test('sin sesion guardada no inventa un refresco', () async {
      expect(await controlador.renovar(), isFalse);
      expect(api.refrescosPedidos, isEmpty);
    });

    test('un 401 cierra la sesion: el refresh ya no sirve', () async {
      armar(
        ApiFalsa()
          ..alRefrescar = (_) async =>
              throw const CredencialesInvalidas('La sesion termino'),
      );
      await dejarSesionGuardada();

      expect(await controlador.renovar(), isFalse);
      expect(controlador.estado, isA<SinSesion>());
      expect(await almacen.leer(), isNull);
    });

    test('sin conexion NO cierra la sesion', () async {
      // Quedarse sin red no significa que la sesion termino. Cerrarla aqui
      // sacaria al cliente de la app por pasar por un tunel.
      armar(ApiFalsa()..alRefrescar = (_) async => throw const SinConexion());
      await dejarSesionGuardada();
      await controlador.restaurar();

      expect(await controlador.renovar(), isFalse);
      expect(await almacen.leer(), isNotNull, reason: 'el par se conserva');
    });

    test('dos refrescos a la vez gastan un solo refresh token', () async {
      // Si dos peticiones reciben 401 al mismo tiempo y cada una refresca, la
      // segunda usa un token ya gastado y tira una sesion que estaba bien.
      final puerta = Completer<void>();
      armar(
        ApiFalsa()
          ..alRefrescar = (_) async {
            await puerta.future;
            return ApiFalsa.respuesta(
              accessToken: 'token.renovado.firmado',
              refreshToken: 'refresco.renovado',
            );
          },
      );
      await dejarSesionGuardada(refresco: 'refresco.1');

      final a = controlador.renovar();
      final b = controlador.renovar();
      puerta.complete();

      expect(await a, isTrue);
      expect(await b, isTrue);
      expect(api.refrescosPedidos, ['refresco.1'], reason: 'un solo refresco');
    });
  });

  group('cerrar sesion con revocacion', () {
    test('le avisa al servidor para que revoque el refresh token', () async {
      // RIC-4. Sin esto el refresh seguiria sirviendo 30 dias.
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      await controlador.cerrarSesion();

      expect(api.cierresPedidos, ['refresco.valido']);
      expect(await almacen.leer(), isNull);
      expect(controlador.estado, isA<SinSesion>());
    });

    test('si el aviso falla, la sesion se cierra igual', () async {
      // Lo peor que pasa es que ese refresh viva hasta expirar en el servidor.
      // Dejar la sesion abierta en el celular seria peor.
      armar(ApiFalsa()..alRefrescar = null);
      await dejarSesionGuardada();
      await controlador.restaurar();

      // El cierre falla por red.
      final conFallo = ApiFalsa();
      controlador = ControladorSesion(conFallo, almacen);
      await controlador.restaurar();
      await controlador.cerrarSesion();

      expect(await almacen.leer(), isNull);
      expect(controlador.estado, isA<SinSesion>());
    });

    test('sin sesion guardada no llama al servidor', () async {
      await controlador.cerrarSesion();

      expect(api.cierresPedidos, isEmpty);
      expect(controlador.estado, isA<SinSesion>());
    });
  });

  group('RIC-5 · el bloqueo por demasiados intentos', () {
    test('le dice al usuario cuanto tiene que esperar', () async {
      // `ClienteApi` ya lee el encabezado `Retry-After` y arma el texto, pero
      // hasta ahora nadie lo usaba: el usuario veia «intenta mas tarde» sin
      // saber cuanto, aunque el servidor si lo habia dicho.
      armar(
        ApiFalsa.queFalla(
          const DemasiadosIntentos(
            'Demasiados intentos. Intenta de nuevo mas tarde.',
            esperaSegundos: 900,
          ),
        ),
      );

      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'mala',
      );

      final fallo = controlador.estado as FalloDeSesion;
      expect(fallo.mensaje, contains('15 minutos'));
      expect(fallo.esBloqueoTemporal, isTrue);
      expect(fallo.esFalloDeRed, isFalse);
    });

    test('sin Retry-After no inventa un tiempo', () async {
      armar(
        ApiFalsa.queFalla(const DemasiadosIntentos('Demasiados intentos.')),
      );

      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'mala',
      );

      final fallo = controlador.estado as FalloDeSesion;
      expect(fallo.esBloqueoTemporal, isTrue);
      expect(fallo.mensaje, isNot(contains('minuto')));
      expect(fallo.mensaje, contains('Espera'));
    });

    test('un 401 normal no se marca como bloqueo', () async {
      armar(ApiFalsa.queFalla(const CredencialesInvalidas('Incorrectos')));

      await controlador.iniciarSesion(correo: 'a@example.com', contrasena: 'b');

      final fallo = controlador.estado as FalloDeSesion;
      expect(fallo.esBloqueoTemporal, isFalse);
    });
  });

  group('cuenta desactivada', () {
    test('un 403 cierra la sesion sin avisarle al servidor', () async {
      // RIC-3: en la app un 403 solo puede ser cuenta desactivada, y el
      // servidor ya fue quien lo dijo.
      await controlador.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );

      await controlador.terminarPorCuentaDesactivada();

      expect(controlador.estado, isA<SinSesion>());
      expect(await almacen.leer(), isNull);
      expect(api.cierresPedidos, isEmpty);
    });
  });
}
