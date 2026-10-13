/// Ayudas de lectura compartidas por los modelos del contrato.
library;

/// Lee un entero aunque llegue como `num`.
int leerEntero(Object? valor, String campo) {
  if (valor is int) return valor;
  if (valor is num) return valor.toInt();
  throw FormatException('El campo «$campo» no es un entero: $valor');
}

/// Lee un decimal aunque llegue como entero.
///
/// JSON no distingue `980` de `980.0`, y el contrato declara `total` como
/// `number`: el backend puede mandar cualquiera de los dos.
double leerDecimal(Object? valor, String campo) {
  if (valor is double) return valor;
  if (valor is num) return valor.toDouble();
  throw FormatException('El campo «$campo» no es un numero: $valor');
}

String leerTexto(Object? valor, String campo) {
  if (valor is String) return valor;
  throw FormatException('El campo «$campo» no es texto: $valor');
}

bool leerBool(Object? valor, String campo) {
  if (valor is bool) return valor;
  throw FormatException('El campo «$campo» no es booleano: $valor');
}

/// Lee una fecha ISO 8601 del contrato (`2026-10-20`).
DateTime leerFecha(Object? valor, String campo) {
  final texto = leerTexto(valor, campo);
  final fecha = DateTime.tryParse(texto);
  if (fecha == null) {
    throw FormatException('El campo «$campo» no es una fecha ISO 8601: $texto');
  }
  // Se descarta la hora: el contrato declara estos campos como `date`.
  // Ojo: el contrato no define zona horaria (pregunta RIC-13), asi que la
  // fecha se trata como local y sin desplazamiento.
  return DateTime(fecha.year, fecha.month, fecha.day);
}

/// Escribe una fecha como `AAAA-MM-DD`, el formato que pide el contrato.
String escribirFecha(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year.toString().padLeft(4, '0')}-$mes-$dia';
}
