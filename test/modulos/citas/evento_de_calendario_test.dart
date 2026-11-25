import 'package:carecar_mobile/modulos/citas/dominio/evento_de_calendario.dart';
import 'package:flutter_test/flutter_test.dart';

EventoDeCalendario _evento({String? vehiculo = 'Nissan Versa 2024'}) =>
    EventoDeCalendario(
      citaId: 41,
      fecha: DateTime(2026, 12, 3),
      horaInicio: '09:30',
      horaFin: '10:30',
      titulo: 'Cita en la agencia',
      direccion: 'Calle Ejemplo 123, Centro; Ciudad',
      descripcion: vehiculo == null ? null : 'Vehículo: $vehiculo',
      minutosAntes: 60,
    );

void main() {
  test('el .ics trae las lineas obligatorias con salto CRLF', () {
    final ics = _evento().aIcs(creado: DateTime.utc(2026, 11, 25, 6));
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('\r\nVERSION:2.0\r\n'));
    expect(ics, contains('\r\nBEGIN:VEVENT\r\n'));
    expect(ics, endsWith('END:VEVENT\r\nEND:VCALENDAR\r\n'));
    expect(ics, contains('UID:cita-41@carecar\r\n'));
    expect(ics, contains('DTSTAMP:20261125T060000Z\r\n'));
  });

  test('la hora es flotante: el taller y el telefono comparten zona', () {
    final ics = _evento().aIcs(creado: DateTime.utc(2026, 11, 25));
    expect(ics, contains('DTSTART:20261203T093000\r\n'));
    expect(ics, contains('DTEND:20261203T103000\r\n'));
  });

  test('escapa comas, punto y coma y saltos en el texto', () {
    final ics = _evento().aIcs(creado: DateTime.utc(2026, 11, 25));
    expect(ics, contains(r'LOCATION:Calle Ejemplo 123\, Centro\; Ciudad'));
  });

  test('lleva un recordatorio antes de la cita', () {
    final ics = _evento().aIcs(creado: DateTime.utc(2026, 11, 25));
    expect(ics, contains('BEGIN:VALARM\r\n'));
    expect(ics, contains('TRIGGER:-PT60M\r\n'));
    expect(ics, contains('ACTION:DISPLAY\r\n'));
  });

  test('sin descripcion no escribe la linea', () {
    final ics = _evento(vehiculo: null)
        .aIcs(creado: DateTime.utc(2026, 11, 25));
    expect(ics, isNot(contains('DESCRIPTION:Veh')));
  });

  test('una hora ilegible usa el inicio del dia en vez de fallar', () {
    final e = EventoDeCalendario(
      citaId: 1,
      fecha: DateTime(2026, 1, 2),
      horaInicio: 'xx',
      horaFin: 'yy',
      titulo: 't',
      direccion: 'd',
      minutosAntes: 30,
    );
    final ics = e.aIcs(creado: DateTime.utc(2026, 1, 1));
    expect(ics, contains('DTSTART:20260102T000000\r\n'));
  });
}
