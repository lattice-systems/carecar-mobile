import 'package:carecar_mobile/nucleo/registro/redactor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('quitarDatosPersonales (V2-M22.07)', () {
    test('tapa un correo, aunque lleve punto, mas o mayusculas', () {
      expect(
        quitarDatosPersonales('entra Ana.Perez+app@correo.com.mx ya'),
        'entra [correo] ya',
      );
    });

    test('tapa un telefono con o sin separadores', () {
      for (final telefono in [
        '5512345678',
        '55 1234 5678',
        '(55) 1234-5678',
        '55.1234.5678',
        '+52 55 1234 5678',
        '+525512345678',
      ]) {
        expect(
          quitarDatosPersonales('llama al $telefono ahora'),
          'llama al [telefono] ahora',
          reason: telefono,
        );
      }
    });

    test('tapa un VIN en mayusculas o minusculas', () {
      expect(
        quitarDatosPersonales('vin 1HGCM82633A004352 del auto'),
        'vin [vin] del auto',
      );
      expect(
        quitarDatosPersonales('vin 1hgcm82633a004352 del auto'),
        'vin [vin] del auto',
      );
    });

    test('tapa un token JWT completo', () {
      const jwt =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.'
          'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      expect(
        quitarDatosPersonales('sesion $jwt lista'),
        'sesion [token] lista',
      );
    });

    test('tapa lo que sigue a Bearer', () {
      expect(
        quitarDatosPersonales('Authorization: Bearer abc123-XYZ_9.opaco'),
        'Authorization: Bearer [token]',
      );
    });

    test('tapa el valor de un campo token, clave o contrasena', () {
      expect(quitarDatosPersonales('token=abc123xyz'), 'token=[token]');
      expect(
        quitarDatosPersonales('{"refresh_token":"qwe-123","ok":true}'),
        '{"refresh_token":"[token]","ok":true}',
      );
      expect(
        quitarDatosPersonales('contrasena: Secreta123'),
        'contrasena: [token]',
      );
      expect(
        quitarDatosPersonales('GET /x?api_key=k-999&pagina=2'),
        'GET /x?api_key=[token]&pagina=2',
      );
    });

    test('tapa varios datos en el mismo texto', () {
      expect(
        quitarDatosPersonales(
          'ana@correo.mx 55 1234 5678 1HGCM82633A004352 token=zzz',
        ),
        '[correo] [telefono] [vin] token=[token]',
      );
    });

    test('no toca texto sin datos personales', () {
      for (final texto in [
        'Fallo una notificacion: 42 intentos',
        'cita 118 del vehiculo 7 el 2026-11-24T10:20:30Z',
        'INTERNACIONALIZAR es una palabra larga',
        'precio 1299900.50 en 48 meses',
        '',
      ]) {
        expect(quitarDatosPersonales(texto), texto, reason: texto);
      }
    });

    test('aplicarlo dos veces da lo mismo que una', () {
      const texto = 'ana@correo.mx 5512345678 token=abc 1HGCM82633A004352';
      final una = quitarDatosPersonales(texto);
      expect(quitarDatosPersonales(una), una);
    });
  });
}
