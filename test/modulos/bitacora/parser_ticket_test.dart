import 'package:carecar_mobile/modulos/bitacora/dominio/parser_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ticket de gasolinera (V2-M18.02)', () {
    test('lee litros, total y fecha de un ticket típico', () {
      const texto = '''
GASOLINERA EL SOL SA DE CV
RFC GSO010101AB1
FECHA: 18/11/2026 14:32
PRODUCTO: MAGNA
LITROS: 35.420
PRECIO: \$23.99
TOTAL: \$849.77
GRACIAS POR SU COMPRA
''';
      final l = leerTicket(texto);
      expect(l.litros, closeTo(35.42, 1e-9));
      expect(l.monto, closeTo(849.77, 1e-9));
      expect(l.fecha, DateTime(2026, 11, 18));
      expect(l.estaVacia, isFalse);
    });

    test('acepta abreviaturas, miles con coma y año de dos dígitos', () {
      const texto = '''
05-03-26
CANT 52.1 LTS
IMPORTE \$1,249.90
''';
      final l = leerTicket(texto);
      expect(l.litros, closeTo(52.1, 1e-9));
      expect(l.monto, closeTo(1249.90, 1e-9));
      expect(l.fecha, DateTime(2026, 3, 5));
    });

    test('lee la cantidad pegada a la unidad y la fecha con mes escrito', () {
      const texto = 'PREMIUM 40.00 L\nTOTAL A PAGAR 1,000.00\n7 NOV 2026';
      final l = leerTicket(texto);
      expect(l.litros, closeTo(40, 1e-9));
      expect(l.monto, closeTo(1000, 1e-9));
      expect(l.fecha, DateTime(2026, 11, 7));
    });

    test('con coma decimal lee 35,42 litros', () {
      final l = leerTicket('LITROS 35,42\nTOTAL 849,77');
      expect(l.litros, closeTo(35.42, 1e-9));
      expect(l.monto, closeTo(849.77, 1e-9));
    });

    test('sin la palabra total toma el mayor importe con signo de pesos', () {
      final l = leerTicket('MAGNA \$23.99\n\$500.00\n\$80.00');
      expect(l.monto, closeTo(500, 1e-9));
    });

    test('fecha en formato año-mes-día', () {
      expect(leerTicket('2026-11-02 10:00').fecha, DateTime(2026, 11, 2));
    });

    test('una fecha imposible se ignora', () {
      expect(leerTicket('31/02/2026').fecha, isNull);
    });

    test('si no lee nada, queda vacía para dejar el formulario en blanco', () {
      expect(leerTicket('').estaVacia, isTrue);
      expect(leerTicket('hola mundo sin números').estaVacia, isTrue);
    });

    test('lo que sí encuentra se conserva aunque falte lo demás', () {
      final l = leerTicket('LITROS 20.0');
      expect(l.litros, closeTo(20, 1e-9));
      expect(l.monto, isNull);
      expect(l.fecha, isNull);
      expect(l.estaVacia, isFalse);
    });
  });
}
