import 'package:carecar_mobile/nucleo/navegacion/enlaces.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? interna(String enlace) =>
      EnlacesApp.aRutaInterna(Uri.parse(enlace))?.toString();

  test(
    'carecar:// pone el host como primer segmento y conserva la consulta',
    () {
      expect(
        interna('carecar://restablecer?token=123456'),
        '/restablecer?token=123456',
      );
      expect(interna('carecar://citas/5'), '/citas/5');
      expect(interna('carecar://citas/5/'), '/citas/5');
    },
  );

  test('enlace universal https del dominio de la agencia', () {
    const h = EnlacesApp.hostEnlacesUniversales;
    expect(
      interna('https://$h/app/restablecer?token=123456&correo=a%40b.mx'),
      '/restablecer?token=123456&correo=a%40b.mx',
    );
    expect(interna('https://$h/app'), '/');
    expect(interna('https://$h/app/'), '/');
  });

  test('lo que no es de la app o ya es interno no se toca', () {
    expect(interna('https://otro.example.org/app/restablecer'), isNull);
    expect(interna('/restablecer?token=1'), isNull);
  });
}
