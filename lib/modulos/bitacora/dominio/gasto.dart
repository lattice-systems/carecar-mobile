/// Tipos de gasto que acepta la bitácora (los del contrato).
enum TipoGasto {
  gasolina,
  estacionamiento,
  casetas,
  lavado,
  otro;

  /// El texto que viaja en el contrato.
  String get enContrato => name;

  /// Lee el tipo del contrato; uno desconocido es un error de formato.
  static TipoGasto desde(String valor) {
    for (final t in values) {
      if (t.name == valor) return t;
    }
    throw FormatException('El tipo de gasto «$valor» no existe');
  }
}

/// Un gasto de un vehículo, tal como lo guarda el servidor.
class Gasto {
  const Gasto({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.litros,
    this.km,
    this.descripcion,
  });

  final int id;
  final int vehiculoId;
  final TipoGasto tipo;
  final double monto;
  final DateTime fecha;

  /// Solo en las cargas de gasolina.
  final double? litros;

  /// Kilometraje del tablero al cargar; solo en las cargas de gasolina.
  final int? km;
  final String? descripcion;

  bool get esCarga => tipo == TipoGasto.gasolina;
}

/// Campos del formulario de un gasto que pueden venir mal.
enum CampoGasto { monto, litros, km, fecha, descripcion }

/// Lo que la persona captura antes de guardar un gasto.
///
/// Las reglas son las del contrato: monto mayor a 0; gasolina pide litros y km;
/// «otro» pide descripción (hasta 200); la fecha no puede ser futura.
class BorradorGasto {
  const BorradorGasto({
    required this.tipo,
    this.monto,
    this.litros,
    this.km,
    this.fecha,
    this.descripcion,
  });

  static const int maximoDescripcion = 200;

  final TipoGasto tipo;
  final double? monto;
  final double? litros;
  final int? km;
  final DateTime? fecha;
  final String? descripcion;

  /// Campos que no pasan la validación, para marcar error por campo.
  ///
  /// [kmMinimo] es la última lectura de km que conoce la app; el servidor la
  /// vuelve a comprobar (422 `KM_INVALIDO`), esto solo evita el viaje.
  Set<CampoGasto> camposInvalidos({required DateTime hoy, int? kmMinimo}) {
    final malos = <CampoGasto>{};
    final m = monto;
    if (m == null || !(m > 0)) malos.add(CampoGasto.monto);

    if (tipo == TipoGasto.gasolina) {
      final l = litros;
      if (l == null || !(l > 0)) malos.add(CampoGasto.litros);
      final k = km;
      if (k == null || k < 0 || (kmMinimo != null && k < kmMinimo)) {
        malos.add(CampoGasto.km);
      }
    }

    final f = fecha;
    final dia = DateTime(hoy.year, hoy.month, hoy.day);
    if (f == null || DateTime(f.year, f.month, f.day).isAfter(dia)) {
      malos.add(CampoGasto.fecha);
    }

    final d = descripcion?.trim() ?? '';
    if (d.length > maximoDescripcion || (tipo == TipoGasto.otro && d.isEmpty)) {
      malos.add(CampoGasto.descripcion);
    }
    return malos;
  }
}
