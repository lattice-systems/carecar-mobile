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

/// Lee una fecha y hora del contrato sin zona (`2026-10-20T13:45:00`), que es
/// hora de la agencia. Devuelve nulo si el campo no viene o es nulo.
DateTime? leerFechaHoraOpcional(Object? valor, String campo) {
  if (valor == null) return null;
  final texto = leerTexto(valor, campo);
  final fecha = DateTime.tryParse(texto);
  if (fecha == null) {
    throw FormatException('El campo «$campo» no es una fecha y hora: $texto');
  }
  return DateTime(
    fecha.year,
    fecha.month,
    fecha.day,
    fecha.hour,
    fecha.minute,
    fecha.second,
  );
}

/// Lee un `date-time` del contrato que es un instante: sin zona se toma como
/// UTC, que es lo que el contrato declara. Una fecha rota falla: no se
/// inventa una.
DateTime leerMomentoUtc(Object? valor, String campo) {
  final texto = leerTexto(valor, campo);
  final momento = DateTime.tryParse(texto);
  if (momento == null) {
    throw FormatException('El campo «$campo» no es una fecha: $texto');
  }
  return momento.isUtc
      ? momento
      : DateTime.utc(
          momento.year,
          momento.month,
          momento.day,
          momento.hour,
          momento.minute,
          momento.second,
        );
}

/// Escribe una fecha como `AAAA-MM-DD`, el formato que pide el contrato.
String escribirFecha(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year.toString().padLeft(4, '0')}-$mes-$dia';
}
