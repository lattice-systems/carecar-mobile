import 'package:carecar_mobile/api/modelos/sesion.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.04 · la peticion de restablecer con el enlace de un solo uso.
///
/// El contrato v2 (2.1.0) declara `RestablecerContrasenaRequest` con
/// `required: [contrasenaNueva]` y los demas campos opcionales: «Con `token`,
/// o con `correo` y `codigo` (app v1). Si llega `token`, se usa ese».
///
/// Por eso se agrega una forma nueva en vez de cambiar la que hay: la pantalla
/// v1 sigue mandando correo y codigo, y la v2 manda el token del enlace. El
/// backend acepta las dos.
void main() {
  group('con el enlace', () {
    test('manda el token y la contrasena, y nada mas', () {
      const peticion = PeticionRestablecer.conEnlace(
        token: 'abc123',
        contrasenaNueva: 'carecar2026',
      );

      expect(peticion.toJson(), {
        'token': 'abc123',
        'contrasenaNueva': 'carecar2026',
      });
    });

    test('no manda correo ni codigo vacios', () {
      // Mandar `"correo": ""` haria que el backend intentara la forma v1 y
      // respondiera 400 por datos invalidos en vez de usar el token.
      const peticion = PeticionRestablecer.conEnlace(
        token: 'abc123',
        contrasenaNueva: 'carecar2026',
      );

      expect(peticion.toJson().containsKey('correo'), isFalse);
      expect(peticion.toJson().containsKey('codigo'), isFalse);
    });

    test('recorta el token: en un correo es facil que arrastre espacios', () {
      const peticion = PeticionRestablecer.conEnlace(
        token: '  abc123  ',
        contrasenaNueva: 'carecar2026',
      );

      expect(peticion.toJson()['token'], 'abc123');
    });

    test('la contrasena no se toca', () {
      // Un espacio al final puede ser parte de la contrasena.
      const peticion = PeticionRestablecer.conEnlace(
        token: 'abc123',
        contrasenaNueva: ' care car 2026 ',
      );

      expect(peticion.toJson()['contrasenaNueva'], ' care car 2026 ');
    });
  });

  group('con el codigo de 6 digitos sigue funcionando igual', () {
    test('manda correo, codigo y contrasena, y nada de token', () {
      const peticion = PeticionRestablecer(
        correo: 'cliente1@example.com',
        codigo: '123456',
        contrasenaNueva: 'carecar2026',
      );

      expect(peticion.toJson(), {
        'correo': 'cliente1@example.com',
        'codigo': '123456',
        'contrasenaNueva': 'carecar2026',
      });
      expect(peticion.toJson().containsKey('token'), isFalse);
    });
  });
}
