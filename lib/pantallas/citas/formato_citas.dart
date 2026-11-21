/// Formatos de fecha que usan las pantallas de citas.
library;

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

const _diasLargos = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

/// `2026-11-20` → `vie`.
String diaCorto(DateTime f) => _dias[f.weekday - 1];

/// `2026-11-20` → `nov`.
String mesCorto(DateTime f) => _meses[f.month - 1];

/// `2026-11-20` → `Viernes 20 nov`.
String formatoFechaLarga(DateTime f) =>
    '${_diasLargos[f.weekday - 1]} ${f.day} ${_meses[f.month - 1]}';

/// Compara solo el dia, sin la hora ni la zona.
bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
