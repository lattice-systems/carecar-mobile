/// Formatos de numeros y fechas que usan las pantallas de vehiculos.
library;

/// `10250` → `10,250 km`.
String formatoKm(int km) => '${conMiles(km)} km';

/// Separa los miles con coma, como en el resto de Agencia360.
String conMiles(int n) {
  final digitos = n.abs().toString();
  final partes = <String>[];
  for (var fin = digitos.length; fin > 0; fin -= 3) {
    partes.insert(0, digitos.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
  }
  return '${n < 0 ? '-' : ''}${partes.join(',')}';
}

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

/// `2026-11-20` → `20 nov 2026`.
String formatoFecha(DateTime f) => '${f.day} ${_meses[f.month - 1]} ${f.year}';
