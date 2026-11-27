import 'package:carecar_mobile/nucleo/navegacion/guardia_sesion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

const _sinSesion = SinSesion();
const _normal = Autenticada(debeCambiarContrasena: false);
const _temporal = Autenticada(debeCambiarContrasena: true);

String? _va(
  String destino,
  EstadoSesion estado, {
  bool cambiada = false,
  bool aviso = false,
}) => redirigirPorSesion(
  destino: Uri.parse(destino),
  estado: estado,
  contrasenaCambiada: cambiada,
  avisoPorAceptar: aviso,
);

void main() {
  group('cuenta desactivada (V2-M01.08)', () {
    const desactivada = SinSesion(porCuentaDesactivada: true);

    test('cualquier ruta va al aviso, no al login', () {
      // Es la diferencia que importa: volver a escribir la contrasena no
      // arregla una cuenta desactivada, asi que el login no es la salida.
      expect(_va('/', desactivada), Rutas.cuentaDesactivada);
      expect(_va(Rutas.acceso, desactivada), Rutas.cuentaDesactivada);
      expect(_va('/ejemplo/avisos', desactivada), Rutas.cuentaDesactivada);
    });

    test('en el aviso se queda', () {
      expect(_va(Rutas.cuentaDesactivada, desactivada), isNull);
    });

    test('sin esa marca, el aviso no atrapa a nadie', () {
      expect(_va(Rutas.acceso, _sinSesion), isNull);
    });
  });

  group('sin sesion', () {
    test('una ruta privada va al acceso y guarda a donde volver', () {
      expect(
        _va('/ejemplo/avisos?x=1', _sinSesion),
        '/acceso?desde=%2Fejemplo%2Favisos%3Fx%3D1',
      );
    });

    test('el inicio va al acceso sin destino que guardar', () {
      expect(_va('/', _sinSesion), Rutas.acceso);
    });

    test('las rutas publicas se ven sin sesion', () {
      for (final p in Rutas.publicas) {
        expect(_va(p, _sinSesion), isNull, reason: p);
      }
      expect(_va('/restablecer?token=123456', _sinSesion), isNull);
    });

    test('autenticando o con fallo cuenta como sin sesion', () {
      expect(_va('/', const Autenticando()), Rutas.acceso);
      expect(_va('/', const FalloDeSesion('x')), Rutas.acceso);
    });

    test('el cambio obligatorio sin sesion tambien pide acceso', () {
      expect(_va(Rutas.cambiarContrasena, _sinSesion), Rutas.acceso);
    });
  });

  group('con sesion', () {
    test('en el acceso vuelve a desde, o al inicio', () {
      expect(
        _va('/acceso?desde=%2Fejemplo%2Favisos', _normal),
        '/ejemplo/avisos',
      );
      expect(_va('/acceso', _normal), Rutas.inicio);
    });

    test('desde externo o que apunta al acceso se ignora', () {
      expect(_va('/acceso?desde=https%3A%2F%2Fmal.example', _normal), '/');
      expect(_va('/acceso?desde=%2F%2Fmal.example', _normal), '/');
      expect(_va('/acceso?desde=%2Facceso', _normal), '/');
    });

    test('las rutas privadas se ven y las publicas de recuperar tambien', () {
      expect(_va('/ejemplo/avisos', _normal), isNull);
      expect(_va('/restablecer?token=1', _normal), isNull);
    });
  });

  group('contrasena temporal', () {
    test('cualquier ruta va al cambio obligatorio, guardando el destino', () {
      expect(_va('/', _temporal), Rutas.cambiarContrasena);
      expect(
        _va('/ejemplo/avisos', _temporal),
        '/cambiar-contrasena?desde=%2Fejemplo%2Favisos',
      );
    });

    test('al entrar por el acceso conserva el desde del acceso', () {
      expect(
        _va('/acceso?desde=%2Fejemplo%2Favisos', _temporal),
        '/cambiar-contrasena?desde=%2Fejemplo%2Favisos',
      );
    });

    test('en el cambio se queda hasta cambiarla', () {
      expect(_va(Rutas.cambiarContrasena, _temporal), isNull);
    });

    test('ya cambiada sale a desde, o al inicio', () {
      expect(
        _va(
          '/cambiar-contrasena?desde=%2Fejemplo%2Favisos',
          _temporal,
          cambiada: true,
        ),
        '/ejemplo/avisos',
      );
      expect(_va(Rutas.cambiarContrasena, _temporal, cambiada: true), '/');
      expect(_va('/ejemplo/avisos', _temporal, cambiada: true), isNull);
    });
  });

  group('aviso de privacidad por aceptar (V2-M22.01)', () {
    test('cualquier ruta va a la puerta, guardando el destino', () {
      expect(
        _va('/ejemplo/avisos?x=1', _normal, aviso: true),
        '/privacidad/aceptar?desde=%2Fejemplo%2Favisos%3Fx%3D1',
      );
    });

    test('el inicio va a la puerta sin destino que guardar', () {
      expect(_va('/', _normal, aviso: true), Rutas.aceptarAviso);
    });

    test('al entrar por el acceso conserva el desde del acceso', () {
      expect(
        _va('/acceso?desde=%2Fejemplo%2Favisos', _normal, aviso: true),
        '/privacidad/aceptar?desde=%2Fejemplo%2Favisos',
      );
    });

    test('en la puerta se queda mientras falte aceptar', () {
      expect(_va(Rutas.aceptarAviso, _normal, aviso: true), isNull);
      expect(
        _va('/privacidad/aceptar?desde=%2Fejemplo', _normal, aviso: true),
        isNull,
      );
    });

    test('aceptado, sale de la puerta a desde, o al inicio', () {
      expect(
        _va('/privacidad/aceptar?desde=%2Fejemplo%2Favisos', _normal),
        '/ejemplo/avisos',
      );
      expect(_va(Rutas.aceptarAviso, _normal), Rutas.inicio);
      expect(_va('/ejemplo/avisos', _normal), isNull);
    });

    test('la contrasena temporal va primero', () {
      expect(
        _va('/ejemplo/avisos', _temporal, aviso: true),
        '/cambiar-contrasena?desde=%2Fejemplo%2Favisos',
      );
      expect(_va(Rutas.aceptarAviso, _temporal, aviso: true), isNotNull);
    });

    test('cambiada la contrasena, sigue la puerta', () {
      expect(
        _va('/cambiar-contrasena?desde=%2Fejemplo', _temporal, cambiada: true),
        '/ejemplo',
        reason: 'la guardia de contrasena no decide por el aviso',
      );
      expect(
        _va('/ejemplo', _temporal, cambiada: true, aviso: true),
        '/privacidad/aceptar?desde=%2Fejemplo',
      );
    });

    test(
      'sin sesion la puerta pide acceso, aunque el aviso este pendiente',
      () {
        expect(_va(Rutas.aceptarAviso, _sinSesion, aviso: true), Rutas.acceso);
        expect(_va('/ejemplo', _sinSesion, aviso: true), isNotNull);
      },
    );

    test('un desde que apunta a la puerta se ignora, para no dar vueltas', () {
      expect(_va('/acceso?desde=%2Fprivacidad%2Faceptar', _normal), '/');
      expect(
        _va('/privacidad/aceptar?desde=%2Fprivacidad%2Faceptar', _normal),
        '/',
      );
    });

    test('las rutas publicas siguen viendose sin sesion', () {
      expect(_va('/recuperar', _sinSesion, aviso: true), isNull);
    });
  });
}
