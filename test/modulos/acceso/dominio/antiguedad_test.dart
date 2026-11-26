import 'package:carecar_mobile/modulos/acceso/dominio/antiguedad.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.09 · cuánto hace que se usó una sesión.
///
/// Devuelve **números y un tramo, nunca texto**: el idioma y el formato de
/// fecha los pone la pantalla, igual que hace `BloqueoPorIntentos`. Aquí se
/// decide solo en qué tramo cae, que es la parte con filo.
void main() {
  final ahora = DateTime.utc(2026, 11, 26, 12, 0);

  Antiguedad calcular(DateTime cuando) =>
      Antiguedad.entre(cuando: cuando, ahora: ahora);

  test('hace menos de un minuto es «ahora»', () {
    expect(
      calcular(ahora.subtract(const Duration(seconds: 40))).tramo,
      TramoDeAntiguedad.ahora,
    );
  });

  test('minutos, mientras no llegue a una hora', () {
    final a = calcular(ahora.subtract(const Duration(minutes: 5)));
    expect(a.tramo, TramoDeAntiguedad.minutos);
    expect(a.cantidad, 5);

    expect(
      calcular(ahora.subtract(const Duration(minutes: 59))).tramo,
      TramoDeAntiguedad.minutos,
    );
  });

  test('horas, mientras no llegue a un dia', () {
    final a = calcular(ahora.subtract(const Duration(hours: 3)));
    expect(a.tramo, TramoDeAntiguedad.horas);
    expect(a.cantidad, 3);

    expect(
      calcular(ahora.subtract(const Duration(hours: 23, minutes: 59))).tramo,
      TramoDeAntiguedad.horas,
    );
  });

  test('dias, mientras no llegue a una semana', () {
    final a = calcular(ahora.subtract(const Duration(days: 3)));
    expect(a.tramo, TramoDeAntiguedad.dias);
    expect(a.cantidad, 3);

    expect(
      calcular(ahora.subtract(const Duration(days: 6, hours: 23))).tramo,
      TramoDeAntiguedad.dias,
    );
  });

  test('de una semana en adelante se dice la fecha', () {
    // Pasada una semana, «hace 23 días» no le dice nada a nadie; la fecha sí.
    final a = calcular(ahora.subtract(const Duration(days: 7)));
    expect(a.tramo, TramoDeAntiguedad.fecha);
    expect(a.cantidad, isNull);
  });

  test('la cantidad se trunca, no se redondea', () {
    // «Hace 5 minutos» a los 5 minutos y 59 segundos sigue siendo cierto;
    // decir 6 adelantaría el reloj del cliente.
    final a = calcular(ahora.subtract(const Duration(minutes: 5, seconds: 59)));
    expect(a.cantidad, 5);
  });

  group('casos que el servidor puede mandar y no deben verse roto', () {
    test('una fecha en el futuro se trata como ahora', () {
      // Pasa de verdad: el reloj del celular puede ir atrasado respecto al del
      // servidor. «Hace -3 minutos» sería peor que «ahora».
      expect(
        calcular(ahora.add(const Duration(minutes: 3))).tramo,
        TramoDeAntiguedad.ahora,
      );
    });

    test('compara instantes aunque vengan en zonas distintas', () {
      // El contrato manda UTC; el reloj de la pantalla es local. Comparar sin
      // normalizar daría el desfase de la zona como antigüedad.
      final mismoInstanteLocal = ahora
          .subtract(const Duration(minutes: 10))
          .toLocal();
      final a = Antiguedad.entre(cuando: mismoInstanteLocal, ahora: ahora);

      expect(a.tramo, TramoDeAntiguedad.minutos);
      expect(a.cantidad, 10);
    });
  });
}
