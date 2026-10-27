// APP-2.1 de punta a punta contra la API simulada.
//
// Es el resultado demostrable del Sprint 1: «login de la app contra la API
// simulada». Usa el ClienteApi real sobre HTTP, no un doble.
//
// Para correrlo:
//   cd mock_api && npm start
//   flutter test test/sesion/login_contra_simulada_test.dart
//
// Si la simulada no esta levantada, se omite y no pone el CI en rojo.

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _base = 'http://localhost:3000/api/v1/app';

void main() {
  late bool levantada;

  setUpAll(() async {
    try {
      final r = await http
          .get(Uri.parse('$_base/catalogo'))
          .timeout(const Duration(seconds: 2));
      // Sin token da 401, que ya confirma que el servidor esta ahi.
      levantada = r.statusCode == 401 || r.statusCode == 200;
    } catch (_) {
      levantada = false;
    }
  });

  ControladorSesion armar({String direccion = _base}) {
    final almacen = AlmacenEnMemoria();
    final cliente = ClienteApi(
      config: ApiConfig.para(direccion),
      obtenerToken: () async => (await almacen.leer())?.accessToken,
    );
    addTearDown(cliente.cerrar);
    return ControladorSesion(CarecarApiHttp(cliente), almacen);
  }

  test('cliente1 entra y queda con sesion', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final sesion = armar();

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    expect(sesion.estado, isA<Autenticada>());
    expect((sesion.estado as Autenticada).debeCambiarContrasena, isFalse);
    expect(await sesion.obtenerToken(), isNotNull);
  });

  test('cliente2 entra con contrasena temporal', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final sesion = armar();

    await sesion.iniciarSesion(
      correo: 'cliente2@example.com',
      contrasena: 'Temporal123',
    );

    expect((sesion.estado as Autenticada).debeCambiarContrasena, isTrue);
  });

  test('con la contrasena mala sale el mensaje de credenciales', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final sesion = armar();

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'equivocada',
    );

    final fallo = sesion.estado as FalloDeSesion;
    expect(fallo.esFalloDeRed, isFalse);
    expect(fallo.mensaje, isNotEmpty);
    expect(
      await sesion.obtenerToken(),
      isNull,
      reason: 'no debe guardar token',
    );
  });

  test('cliente3 esta desactivada y no entra', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final sesion = armar();

    await sesion.iniciarSesion(
      correo: 'cliente3@example.com',
      contrasena: 'CareCar2026',
    );

    expect(sesion.estado, isA<FalloDeSesion>());
    expect((sesion.estado as FalloDeSesion).esFalloDeRed, isFalse);
  });

  test(
    'una direccion apagada da sin conexion, no error de credenciales',
    () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      // Puerto donde no hay nada escuchando.
      final sesion = armar(direccion: 'http://localhost:9/api/v1/app');

      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );

      final fallo = sesion.estado as FalloDeSesion;
      expect(fallo.esFalloDeRed, isTrue);
      expect(
        fallo.mensaje,
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
    },
  );

  test('cerrar sesion borra el token', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final sesion = armar();
    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    await sesion.cerrarSesion();

    expect(sesion.estado, isA<SinSesion>());
    expect(await sesion.obtenerToken(), isNull);
  });

  test('el token sirve para una peticion autenticada', () async {
    if (!levantada) return markTestSkipped('La API simulada no esta levantada');
    final almacen = AlmacenEnMemoria();
    final cliente = ClienteApi(
      config: ApiConfig.para(_base),
      obtenerToken: () async => (await almacen.leer())?.accessToken,
    );
    addTearDown(cliente.cerrar);
    final api = CarecarApiHttp(cliente);
    final sesion = ControladorSesion(api, almacen);

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
    // Misma instancia de cliente: toma el token del almacen en cada peticion.
    final vehiculos = await api.misVehiculos();

    expect(vehiculos, hasLength(2), reason: 'cliente1 tiene 2 vehiculos');
  });

  // --- La sesion con refresco · TEC-6 T3 y T4 ---
  //
  // Contra la simulada, que es la referencia de las pruebas (decision D-E).
  // Los refresh tokens del mock viven en memoria, asi que estas pruebas no
  // dejan estado sucio en db.json y se pueden repetir.

  group('refresco contra la simulada', () {
    test('el login trae el par completo', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final almacen = AlmacenEnMemoria();
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        obtenerToken: () async => (await almacen.leer())?.accessToken,
      );
      addTearDown(cliente.cerrar);
      final sesion = ControladorSesion(CarecarApiHttp(cliente), almacen);

      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );

      final guardado = await almacen.leer();
      expect(guardado?.refreshToken, isNotEmpty);
      expect(guardado?.vencido, isFalse);
      // El mock manda 3600, igual que el backend hoy.
      expect(
        guardado!.expiraEn.difference(DateTime.now().toUtc()).inMinutes,
        greaterThan(50),
      );
    });

    test('renovar rota el par y el token nuevo sirve', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final almacen = AlmacenEnMemoria();
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        obtenerToken: () async => (await almacen.leer())?.accessToken,
      );
      addTearDown(cliente.cerrar);
      final api = CarecarApiHttp(cliente);
      final sesion = ControladorSesion(api, almacen);

      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      final primero = (await almacen.leer())!;

      expect(await sesion.renovar(), isTrue);
      final segundo = (await almacen.leer())!;

      expect(
        segundo.refreshToken,
        isNot(primero.refreshToken),
        reason: 'RIC-2: cada refresco entrega uno nuevo',
      );
      // Lo que de verdad importa: el access token renovado abre una ruta
      // protegida.
      expect(await api.misVehiculos(), hasLength(2));
    });

    test('el refresh usado ya no sirve', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final almacen = AlmacenEnMemoria();
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        obtenerToken: () async => (await almacen.leer())?.accessToken,
      );
      addTearDown(cliente.cerrar);
      final api = CarecarApiHttp(cliente);
      final sesion = ControladorSesion(api, almacen);

      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      final gastado = (await almacen.leer())!.refreshToken;
      await sesion.renovar();

      await expectLater(api.refrescar(gastado), throwsA(isA<ExcepcionApi>()));
    });

    test('cerrar sesion revoca el refresh en el servidor', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final almacen = AlmacenEnMemoria();
      final cliente = ClienteApi(
        config: ApiConfig.para(_base),
        obtenerToken: () async => (await almacen.leer())?.accessToken,
      );
      addTearDown(cliente.cerrar);
      final api = CarecarApiHttp(cliente);
      final sesion = ControladorSesion(api, almacen);

      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      final revocado = (await almacen.leer())!.refreshToken;

      await sesion.cerrarSesion();

      expect(sesion.estado, isA<SinSesion>());
      await expectLater(api.refrescar(revocado), throwsA(isA<ExcepcionApi>()));
    });
  });
}
