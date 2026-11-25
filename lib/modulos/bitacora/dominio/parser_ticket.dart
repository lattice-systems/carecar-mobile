/// Lo que se pudo leer de la foto de un ticket de gasolinera (V2-M18.02).
///
/// Cada campo es nulo si no se encontró: el formulario solo propone lo que
/// leyó y la persona confirma o corrige.
class LecturaTicket {
  const LecturaTicket({this.litros, this.monto, this.fecha});

  final double? litros;
  final double? monto;
  final DateTime? fecha;

  /// No se leyó nada útil: el formulario debe quedar en blanco.
  bool get estaVacia => litros == null && monto == null && fecha == null;
}

/// Extrae litros, monto y fecha del texto que reconoció el dispositivo.
///
/// Es una función pura: el reconocimiento de texto vive detrás de otra
/// interfaz. Las heurísticas son las de los tickets mexicanos de gasolinera
/// («LITROS», «TOTAL», «dd/mm/aaaa»); lo que no se reconoce se deja en nulo.
LecturaTicket leerTicket(String texto) {
  final lineas = texto.toUpperCase().split(RegExp(r'[\r\n]+'));
  return LecturaTicket(
    litros: _litros(lineas),
    monto: _monto(lineas),
    fecha: _fecha(texto.toUpperCase()),
  );
}

final _numero = RegExp(r'\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:[.,]\d+)?');

/// Convierte «1,249.90», «849,77» o «35.420» a número. Con solo comas, «,dd»
/// es decimal; «,ddd» es millar salvo que sea una cantidad en litros.
double? _aNumero(String texto, {bool enLitros = false}) {
  var t = texto;
  if (t.contains(',') && t.contains('.')) {
    t = t.lastIndexOf('.') > t.lastIndexOf(',')
        ? t.replaceAll(',', '')
        : t.replaceAll('.', '').replaceAll(',', '.');
  } else if (t.contains(',')) {
    final millares = RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(t);
    t = millares && !enLitros ? t.replaceAll(',', '') : t.replaceAll(',', '.');
  }
  return double.tryParse(t);
}

double? _litros(List<String> lineas) {
  final conUnidad = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:LITROS?|LTRS?|LTS?|L)\b');
  final clave = RegExp(r'LITROS?|LTRS?|LTS?\b|CANTIDAD|CANT\b|VOLUMEN');
  for (final linea in lineas) {
    if (_esPrecioPorLitro(linea)) continue;
    final m = conUnidad.firstMatch(linea);
    if (m != null) {
      final v = _aNumero(m.group(1)!, enLitros: true);
      if (v != null && v > 0) return v;
    }
  }
  for (final linea in lineas) {
    if (_esPrecioPorLitro(linea) || !clave.hasMatch(linea)) continue;
    final despues = linea.substring(clave.firstMatch(linea)!.end);
    final m = _numero.firstMatch(despues);
    if (m != null) {
      final v = _aNumero(m.group(0)!, enLitros: true);
      if (v != null && v > 0) return v;
    }
  }
  return null;
}

bool _esPrecioPorLitro(String linea) =>
    linea.contains('PRECIO') ||
    linea.contains('POR LITRO') ||
    linea.contains('P/L') ||
    linea.contains(r'$/L');

double? _monto(List<String> lineas) {
  final clave = RegExp(r'(?<!SUB)TOTAL|IMPORTE|MONTO|A PAGAR');
  double? mayor;
  for (final linea in lineas) {
    if (!clave.hasMatch(linea)) continue;
    final numeros = _numero.allMatches(linea).toList();
    if (numeros.isEmpty) continue;
    final v = _aNumero(numeros.last.group(0)!);
    if (v != null && v > 0 && (mayor == null || v > mayor)) mayor = v;
  }
  if (mayor != null) return mayor;

  final conPesos = RegExp(r'\$\s*(\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?)');
  for (final linea in lineas) {
    for (final m in conPesos.allMatches(linea)) {
      final v = _aNumero(m.group(1)!);
      if (v != null && v > 0 && (mayor == null || v > mayor)) mayor = v;
    }
  }
  return mayor;
}

const _meses = {
  'ENE': 1,
  'FEB': 2,
  'MAR': 3,
  'ABR': 4,
  'MAY': 5,
  'JUN': 6,
  'JUL': 7,
  'AGO': 8,
  'SEP': 9,
  'OCT': 10,
  'NOV': 11,
  'DIC': 12,
};

DateTime? _fecha(String texto) {
  final iso = RegExp(r'(?<!\d)(\d{4})-(\d{1,2})-(\d{1,2})(?!\d)');
  final m1 = iso.firstMatch(texto);
  if (m1 != null) {
    final f = _validar(m1.group(1)!, m1.group(2)!, m1.group(3)!);
    if (f != null) return f;
  }
  final numerica = RegExp(
    r'(?<!\d)(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4}|\d{2})(?!\d)',
  );
  for (final m in numerica.allMatches(texto)) {
    final f = _validar(m.group(3)!, m.group(2)!, m.group(1)!);
    if (f != null) return f;
  }
  final escrita = RegExp(
    r'(?<!\d)(\d{1,2})\s*(ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)'
    r'[A-Z]*\.?\s*,?\s*(?:DE\s*)?(\d{4}|\d{2})(?!\d)',
  );
  for (final m in escrita.allMatches(texto)) {
    final f = _validar(m.group(3)!, '${_meses[m.group(2)]}', m.group(1)!);
    if (f != null) return f;
  }
  return null;
}

/// Arma la fecha solo si existe en el calendario (31/02 no).
DateTime? _validar(String anio, String mes, String dia) {
  var a = int.parse(anio);
  if (anio.length == 2) a += 2000;
  final m = int.parse(mes);
  final d = int.parse(dia);
  final f = DateTime(a, m, d);
  return f.year == a && f.month == m && f.day == d ? f : null;
}
