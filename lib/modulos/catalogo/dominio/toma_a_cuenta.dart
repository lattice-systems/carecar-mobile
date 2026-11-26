/// Estado general del auto que el cliente quiere dar a cuenta.
enum EstadoAuto { excelente, bueno, regular, malo }

/// Lo que el cliente pide estimar (V2-M03.04).
///
/// El auto es uno de sus vehiculos o uno capturado a mano, nunca los dos. Dart
/// puro, como el resto del dominio.
sealed class SolicitudEstimacion {
  const SolicitudEstimacion({
    required this.km,
    required this.estado,
    this.modeloDestinoId,
  });

  final int km;
  final EstadoAuto estado;

  /// Modelo nuevo contra el que se estima, si el cliente venia de uno.
  final int? modeloDestinoId;
}

/// Un vehiculo del garaje del cliente.
class SolicitudDeVehiculo extends SolicitudEstimacion {
  const SolicitudDeVehiculo({
    required this.vehiculoId,
    required super.km,
    required super.estado,
    super.modeloDestinoId,
  });

  final int vehiculoId;
}

/// Un auto que el cliente escribio: marca, modelo (el tipo, como Versa) y anio.
class SolicitudCapturada extends SolicitudEstimacion {
  const SolicitudCapturada({
    required this.marca,
    required this.modelo,
    required this.anio,
    required super.km,
    required super.estado,
    super.modeloDestinoId,
  });

  final String marca;
  final String modelo;
  final int anio;
}

/// El resultado: un rango no vinculante, nunca una oferta.
///
/// Los supuestos vienen ya calculados por el backend. La app no recalcula
/// nada: la formula vive solo alla.
class Estimacion {
  const Estimacion({
    required this.id,
    required this.creadaEn,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.km,
    required this.estado,
    required this.minimo,
    required this.maximo,
    required this.edadAnios,
    required this.kmEsperado,
    required this.margen,
    this.vehiculoId,
    this.modeloDestino,
    this.precioDestino,
  });

  final int id;
  final DateTime creadaEn;

  /// El vehiculo del cliente con el que se hizo; nulo si capturo el auto a
  /// mano.
  final int? vehiculoId;
  final String marca;
  final String modelo;
  final int anio;
  final int km;
  final EstadoAuto estado;
  final double minimo;
  final double maximo;

  /// Antiguedad del auto que uso la formula.
  final int edadAnios;

  /// Kilometraje que se espera para esa antiguedad.
  final int kmEsperado;

  /// Fraccion que se resta y se suma al valor estimado (0.08 es 8 %).
  final double margen;

  /// Nombre del modelo nuevo, como "Nissan Versa 2025".
  final String? modeloDestino;

  /// Precio de lista del modelo nuevo al momento de estimar.
  final double? precioDestino;

  /// "Nissan March 2020".
  String get titulo => [marca, modelo, anio].join(' ');

  /// El margen como porcentaje entero, para escribirlo: 8.
  int get margenPorcentaje => (margen * 100).round();
}

/// Lee el kilometraje que escribio el cliente: solo digitos, con comas, puntos
/// o espacios como separador de miles, de 0 a 999,999. `null` si no sirve.
int? leerKilometraje(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\s,.]'), '');
  if (limpio.isEmpty || !RegExp(r'^\d{1,6}$').hasMatch(limpio)) return null;
  return int.parse(limpio);
}

/// Lee el anio del auto: cuatro digitos entre 1900 y [maximo]. `null` si no
/// sirve.
int? leerAnio(String texto, {required int maximo}) {
  final limpio = texto.trim();
  if (!RegExp(r'^\d{4}$').hasMatch(limpio)) return null;
  final anio = int.parse(limpio);
  return anio >= 1900 && anio <= maximo ? anio : null;
}

/// Lo que faltaria pagar por el modelo nuevo si se da el auto a cuenta
/// (V2-M03.05). Tan poco vinculante como la estimacion de la que sale.
class DiferenciaAPagar {
  const DiferenciaAPagar({required this.minimo, required this.maximo});

  /// Lo menos que se pagaria: el precio menos lo mas que valdria el auto.
  final double minimo;

  /// Lo mas que se pagaria: el precio menos lo menos que valdria el auto.
  final double maximo;

  /// `true` si hasta el valor mas bajo del auto alcanza para el precio.
  bool get cubiertaPorElAuto => maximo <= 0;
}

/// Precio del modelo menos el rango estimado, sin bajar de cero.
///
/// `null` si la estimacion no se hizo contra un modelo o el modelo no tiene
/// precio de lista.
DiferenciaAPagar? diferenciaAPagar(Estimacion estimacion) {
  final precio = estimacion.precioDestino;
  if (precio == null) return null;
  double sinNegativos(double v) => v < 0 ? 0 : v;
  return DiferenciaAPagar(
    minimo: sinNegativos(precio - estimacion.maximo),
    maximo: sinNegativos(precio - estimacion.minimo),
  );
}
