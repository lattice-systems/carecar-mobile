// TEC-6 T3 · Los dos tokens de la sesion y donde se guardan.
//
// La v1.1 del contrato convirtio la sesion de un token a un par: un access
// token que vive lo que diga `expiresIn` y un refresh token de 30 dias que se
// usa una sola vez (RIC-1, RIC-2). Guardarlos en memoria significaba que el
// cliente volvia a escribir su contrasena cada vez que abria la app, que es
// justo lo que el refresh viene a evitar. De ahi la decision D-D.
//
// `AlmacenSeguro` se prueba contra un doble del almacenamiento del sistema:
// el plugin de verdad necesita Keystore o Keychain, o sea un dispositivo.

import 'package:carecar_mobile/sesion/almacen_seguro.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doble del almacenamiento cifrado del sistema.
///
/// Guarda en un mapa y deja ver que quedo escrito, que es justo lo que las
/// pruebas necesitan comprobar.
class AlmacenamientoFalso implements AlmacenamientoCifrado {
  final Map<String, String> datos = {};
  int escrituras = 0;
  int borrados = 0;

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> escribir(String clave, String valor) async {
    escrituras++;
    datos[clave] = valor;
  }

  @override
  Future<void> borrar(String clave) async {
    borrados++;
    datos.remove(clave);
  }
}

TokensSesion _tokens({
  String acceso = 'acceso-1',
  String refresco = 'refresco-1',
  Duration vida = const Duration(hours: 1),
}) => TokensSesion.conVida(
  accessToken: acceso,
  refreshToken: refresco,
  segundos: vida.inSeconds,
);

void main() {
  group('TokensSesion', () {
    test(
      'calcula cuando expira a partir de los segundos que da el servidor',
      () {
        // RIC-1: la vida la dice el servidor en `expiresIn` y la app usa ese
        // valor. No abre el JWT ni fija 3600 por su cuenta.
        final antes = DateTime.now().toUtc();
        final t = _tokens(vida: const Duration(seconds: 3600));
        final despues = DateTime.now().toUtc();

        expect(
          t.expiraEn.isAfter(antes.add(const Duration(seconds: 3599))),
          isTrue,
        );
        expect(
          t.expiraEn.isBefore(despues.add(const Duration(seconds: 3601))),
          isTrue,
        );
      },
    );

    test('un token recien emitido no esta vencido', () {
      expect(_tokens().vencido, isFalse);
    });

    test('un token con vida cero ya esta vencido', () {
      expect(_tokens(vida: Duration.zero).vencido, isTrue);
    });

    test('avisa que esta por vencer antes de vencerse de verdad', () {
      // Sirve para renovar antes de que el usuario vea un error, en lugar de
      // esperar el 401.
      final t = _tokens(vida: const Duration(seconds: 20));
      expect(t.vencido, isFalse);
      expect(t.porVencer(margen: const Duration(seconds: 60)), isTrue);
      expect(t.porVencer(margen: const Duration(seconds: 5)), isFalse);
    });

    test('sobrevive una ida y vuelta a JSON sin perder precision', () {
      final original = _tokens(acceso: 'a', refresco: 'r');
      final copia = TokensSesion.fromJson(original.toJson());

      expect(copia.accessToken, 'a');
      expect(copia.refreshToken, 'r');
      expect(copia.expiraEn, original.expiraEn);
    });

    test('rechaza un JSON incompleto en lugar de inventar valores', () {
      expect(
        () => TokensSesion.fromJson(const {'accessToken': 'a'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AlmacenEnMemoria', () {
    test('guarda y devuelve el par completo', () async {
      final almacen = AlmacenEnMemoria();
      await almacen.guardar(_tokens(acceso: 'a', refresco: 'r'));

      final leido = await almacen.leer();
      expect(leido?.accessToken, 'a');
      expect(leido?.refreshToken, 'r');
    });

    test('empieza vacio y queda vacio al borrar', () async {
      final almacen = AlmacenEnMemoria();
      expect(await almacen.leer(), isNull);

      await almacen.guardar(_tokens());
      expect(await almacen.leer(), isNotNull);

      await almacen.borrar();
      expect(await almacen.leer(), isNull);
    });
  });

  group('AlmacenSeguro', () {
    test('escribe el par en el almacenamiento del sistema', () async {
      final sistema = AlmacenamientoFalso();
      final almacen = AlmacenSeguro(sistema);

      await almacen.guardar(_tokens(acceso: 'a', refresco: 'r'));

      expect(sistema.escrituras, 1);
      expect(sistema.datos, hasLength(1));
      // Los dos tokens van juntos en una sola entrada: asi no puede quedar un
      // access token sin su refresh si algo falla a la mitad.
      expect(sistema.datos.values.single, contains('"accessToken":"a"'));
      expect(sistema.datos.values.single, contains('"refreshToken":"r"'));
    });

    test('la sesion sobrevive a cerrar la app', () async {
      // Es la razon de ser de toda la tarea: un almacen nuevo sobre el mismo
      // almacenamiento del sistema vuelve a encontrar la sesion.
      final sistema = AlmacenamientoFalso();
      await AlmacenSeguro(sistema).guardar(_tokens(acceso: 'a', refresco: 'r'));

      final despuesDeReabrir = await AlmacenSeguro(sistema).leer();

      expect(despuesDeReabrir?.accessToken, 'a');
      expect(despuesDeReabrir?.refreshToken, 'r');
    });

    test('sin nada guardado devuelve null, no un error', () async {
      expect(await AlmacenSeguro(AlmacenamientoFalso()).leer(), isNull);
    });

    test('borrar deja el almacenamiento limpio', () async {
      final sistema = AlmacenamientoFalso();
      final almacen = AlmacenSeguro(sistema);
      await almacen.guardar(_tokens());

      await almacen.borrar();

      expect(sistema.borrados, 1);
      expect(sistema.datos, isEmpty);
      expect(await almacen.leer(), isNull);
    });

    test(
      'un dato corrupto se trata como «no hay sesion», no tumba la app',
      () async {
        // Puede pasar si cambia el formato entre versiones de la app. Lo peor
        // aceptable es que el cliente vuelva a entrar; lo inaceptable es que la
        // app no arranque.
        final sistema = AlmacenamientoFalso();
        final almacen = AlmacenSeguro(sistema);
        await almacen.guardar(_tokens());
        sistema.datos[sistema.datos.keys.single] = 'esto no es JSON';

        expect(await almacen.leer(), isNull);
      },
    );

    test('un JSON valido pero sin los campos tampoco rompe', () async {
      final sistema = AlmacenamientoFalso();
      final almacen = AlmacenSeguro(sistema);
      await almacen.guardar(_tokens());
      sistema.datos[sistema.datos.keys.single] = '{"accessToken":"solo-uno"}';

      expect(await almacen.leer(), isNull);
    });
  });
}
