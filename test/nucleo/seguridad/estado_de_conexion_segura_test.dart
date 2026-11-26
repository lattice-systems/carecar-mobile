import 'package:carecar_mobile/nucleo/seguridad/estado_de_conexion_segura.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EstadoDeConexionSegura estado;
  late int avisos;

  setUp(() {
    estado = EstadoDeConexionSegura();
    avisos = 0;
    estado.addListener(() => avisos++);
  });

  tearDown(() => estado.dispose());

  group('EstadoDeConexionSegura (V2-M22.15)', () {
    test('al principio no hay ningún problema', () {
      expect(estado.noSegura, isFalse);
    });

    test('un certificado rechazado lo marca y avisa', () {
      estado.actualizar(false);

      expect(estado.noSegura, isTrue);
      expect(avisos, 1);
    });

    test('repetir el mismo estado no vuelve a avisar', () {
      estado.actualizar(false);
      estado.actualizar(false);

      expect(avisos, 1);
    });

    test('una respuesta posterior lo limpia y avisa', () {
      estado.actualizar(false);

      estado.actualizar(true);

      expect(estado.noSegura, isFalse);
      expect(avisos, 2);
    });

    test('una respuesta sin rechazo previo no avisa', () {
      estado.actualizar(true);

      expect(estado.noSegura, isFalse);
      expect(avisos, 0);
    });
  });
}
