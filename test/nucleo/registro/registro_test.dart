import 'package:carecar_mobile/nucleo/registro/registro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> escrito;

  setUp(() {
    escrito = [];
    Registro.salida = escrito.add;
    addTearDown(Registro.restaurarSalida);
  });

  group('Registro (V2-M22.07)', () {
    test('escribe el mensaje tal cual cuando no hay datos personales', () {
      Registro.depurar('No se pudieron iniciar las notificaciones');
      expect(escrito, ['No se pudieron iniciar las notificaciones']);
    });

    test('a la salida solo llega texto sin correo, telefono, VIN ni token', () {
      Registro.depurar(
        'Fallo para ana@correo.mx con 1HGCM82633A004352',
        error: Exception('tel 55 1234 5678 token=abc123'),
      );
      expect(escrito, hasLength(1));
      expect(
        escrito.single,
        'Fallo para [correo] con [vin]: '
        'Exception: tel [telefono] token=[token]',
      );
    });

    test('un error que llega solo tambien se limpia', () {
      Registro.depurar('Fallo', error: 'Bearer abc.def.ghi');
      expect(escrito.single, 'Fallo: Bearer [token]');
    });

    test('restaurarSalida deja de usar la salida de la prueba', () {
      Registro.restaurarSalida();
      // No lanza y no escribe en la lista de la prueba.
      Registro.depurar('mensaje de prueba');
      expect(escrito, isEmpty);
    });
  });
}
