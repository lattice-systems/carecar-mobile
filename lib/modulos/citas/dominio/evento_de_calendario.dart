/// Una cita como evento de calendario (V2-M02.12), en formato iCalendar.
///
/// Dart puro. Se entrega como archivo `.ics`, que abren Google Calendar, el
/// calendario de Apple y los demas sin pedir permisos a la app. La hora va
/// «flotante» (sin zona): el taller y el telefono del cliente estan en el mismo
/// lugar, y asi el evento no se corre si el telefono cambia de zona.
class EventoDeCalendario {
  const EventoDeCalendario({
    required this.citaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.titulo,
    required this.direccion,
    required this.minutosAntes,
    this.descripcion,
  });

  final int citaId;
  final DateTime fecha;

  /// `HH:mm`, como llega de la API.
  final String horaInicio;
  final String horaFin;
  final String titulo;
  final String direccion;
  final String? descripcion;

  /// Cuanto antes de la cita suena el recordatorio.
  final int minutosAntes;

  /// El contenido del archivo. `creado` es el instante de la marca DTSTAMP
  /// (en UTC); se recibe para que la salida sea determinista en pruebas.
  String aIcs({required DateTime creado}) {
    final lineas = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//CareCar//Citas//ES',
      'CALSCALE:GREGORIAN',
      'BEGIN:VEVENT',
      'UID:cita-$citaId@carecar',
      'DTSTAMP:${_utc(creado)}',
      'DTSTART:${_local(fecha, horaInicio)}',
      'DTEND:${_local(fecha, horaFin)}',
      'SUMMARY:${_escapar(titulo)}',
      'LOCATION:${_escapar(direccion)}',
      if (descripcion != null && descripcion!.isNotEmpty)
        'DESCRIPTION:${_escapar(descripcion!)}',
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'DESCRIPTION:${_escapar(titulo)}',
      'TRIGGER:-PT${minutosAntes}M',
      'END:VALARM',
      'END:VEVENT',
      'END:VCALENDAR',
    ];
    return '${lineas.join('\r\n')}\r\n';
  }
}

String _dos(int n) => n.toString().padLeft(2, '0');

String _utc(DateTime t) {
  final u = t.toUtc();
  return '${u.year}${_dos(u.month)}${_dos(u.day)}T'
      '${_dos(u.hour)}${_dos(u.minute)}${_dos(u.second)}Z';
}

/// `AAAAMMDDTHHMMSS` con la hora de la cita; una hora ilegible cuenta como el
/// inicio del dia.
String _local(DateTime fecha, String hora) {
  final partes = hora.split(':');
  final h = int.tryParse(partes.first);
  final m = partes.length > 1 ? int.tryParse(partes[1]) : null;
  final hh = h ?? 0;
  final mm = h == null ? 0 : (m ?? 0);
  return '${fecha.year}${_dos(fecha.month)}${_dos(fecha.day)}T'
      '${_dos(hh)}${_dos(mm)}00';
}

/// Escapado de texto de RFC 5545: barra, coma, punto y coma y saltos de linea.
String _escapar(String texto) => texto
    .replaceAll(r'\', r'\\')
    .replaceAll(',', r'\,')
    .replaceAll(';', r'\;')
    .replaceAll(RegExp(r'\r?\n'), r'\n');

/// Entrega el `.ics` al sistema (hoja de compartir). Se sustituye en pruebas
/// por `EntregaDeEventoFake`.
abstract interface class EntregaDeEvento {
  Future<void> entregar(String ics, {required int citaId});
}
