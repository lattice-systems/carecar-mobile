import 'comun.dart';

/// Estado general del auto, como lo declara el contrato (`EstadoVehiculo`).
enum EstadoVehiculo {
  excelente('EXCELENTE'),
  bueno('BUENO'),
  regular('REGULAR'),
  malo('MALO'),

  /// Un estado que el contrato todavia no declara. Red de seguridad: la
  /// prueba de contrato avisa cuando el enum del YAML cambia.
  desconocido('');

  const EstadoVehiculo(this.enElContrato);

  /// El valor tal como viaja en el JSON.
  final String enElContrato;

  static EstadoVehiculo desdeContrato(String valor) => values.firstWhere(
    (e) => e.enElContrato == valor,
    orElse: () => desconocido,
  );
}

/// Cuerpo de `POST /toma-a-cuenta/estimaciones` (`NuevaEstimacionTomaCuenta`).
///
/// El auto se indica con [vehiculoId] o con [marca], [modelo] y [anio], nunca
/// con las dos formas ni con ninguna. Los constructores nombrados lo garantizan.
class NuevaEstimacionTomaCuenta {
  /// Un vehiculo del cliente: de ahi salen marca, modelo y anio.
  const NuevaEstimacionTomaCuenta.deVehiculo({
    required int this.vehiculoId,
    required this.km,
    required this.estado,
    this.modeloCatalogoId,
  }) : marca = null,
       modelo = null,
       anio = null;

  /// Un auto capturado a mano.
  const NuevaEstimacionTomaCuenta.capturado({
    required String this.marca,
    required String this.modelo,
    required int this.anio,
    required this.km,
    required this.estado,
    this.modeloCatalogoId,
  }) : vehiculoId = null;

  final int? vehiculoId;
  final String? marca;

  /// Tipo del vehiculo (Versa), como `Vehiculo.modelo`.
  final String? modelo;
  final int? anio;
  final int km;
  final EstadoVehiculo estado;

  /// Modelo nuevo contra el que se estima, opcional.
  final int? modeloCatalogoId;

  Map<String, Object?> toJson() => {
    'vehiculoId': ?vehiculoId,
    'marca': ?marca,
    'modelo': ?modelo,
    'anio': ?anio,
    'km': km,
    'estado': estado.enElContrato,
    'modeloCatalogoId': ?modeloCatalogoId,
  };
}

/// Lo que uso la formula (`SupuestosEstimacion`).
class SupuestosEstimacion {
  const SupuestosEstimacion({
    required this.valorBase,
    required this.edadAnios,
    required this.kmEsperado,
    required this.ajusteKm,
    required this.ajusteEstado,
    required this.margen,
  });

  factory SupuestosEstimacion.fromJson(Map<String, Object?> json) =>
      SupuestosEstimacion(
        valorBase: leerDecimal(json['valorBase'], 'valorBase'),
        edadAnios: leerEntero(json['edadAnios'], 'edadAnios'),
        kmEsperado: leerEntero(json['kmEsperado'], 'kmEsperado'),
        ajusteKm: leerDecimal(json['ajusteKm'], 'ajusteKm'),
        ajusteEstado: leerDecimal(json['ajusteEstado'], 'ajusteEstado'),
        margen: leerDecimal(json['margen'], 'margen'),
      );

  final double valorBase;
  final int edadAnios;
  final int kmEsperado;

  /// Multiplicador por kilometraje, entre 0.5 y 1.2.
  final double ajusteKm;
  final double ajusteEstado;

  /// Fraccion que se resta y se suma al valor estimado para dar el rango.
  final double margen;

  Map<String, Object?> toJson() => {
    'valorBase': valorBase,
    'edadAnios': edadAnios,
    'kmEsperado': kmEsperado,
    'ajusteKm': ajusteKm,
    'ajusteEstado': ajusteEstado,
    'margen': margen,
  };
}

/// Una estimacion no vinculante (`EstimacionTomaCuenta`).
///
/// [minimo] y [maximo] son pesos con IVA, redondeados a 100. No es una oferta.
class EstimacionTomaCuenta {
  const EstimacionTomaCuenta({
    required this.id,
    required this.creadaEn,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.km,
    required this.estado,
    required this.minimo,
    required this.maximo,
    required this.supuestos,
    this.vehiculoId,
    this.modeloCatalogoId,
    this.modeloDestino,
    this.precioDestino,
  });

  factory EstimacionTomaCuenta.fromJson(Map<String, Object?> json) =>
      EstimacionTomaCuenta(
        id: leerEntero(json['id'], 'id'),
        creadaEn: _leerMomento(json['creadaEn']),
        vehiculoId: _entero(json['vehiculoId']),
        marca: leerTexto(json['marca'], 'marca'),
        modelo: leerTexto(json['modelo'], 'modelo'),
        anio: leerEntero(json['anio'], 'anio'),
        km: leerEntero(json['km'], 'km'),
        estado: EstadoVehiculo.desdeContrato(
          leerTexto(json['estado'], 'estado'),
        ),
        modeloCatalogoId: _entero(json['modeloCatalogoId']),
        modeloDestino: json['modeloDestino'] as String?,
        precioDestino: json['precioDestino'] == null
            ? null
            : leerDecimal(json['precioDestino'], 'precioDestino'),
        minimo: leerDecimal(json['minimo'], 'minimo'),
        maximo: leerDecimal(json['maximo'], 'maximo'),
        supuestos: SupuestosEstimacion.fromJson(
          (json['supuestos']! as Map).cast<String, Object?>(),
        ),
      );

  final int id;

  /// Momento en que se calculo, en UTC.
  final DateTime creadaEn;
  final int? vehiculoId;
  final String marca;
  final String modelo;
  final int anio;
  final int km;
  final EstadoVehiculo estado;
  final int? modeloCatalogoId;

  /// Nombre del modelo nuevo, escrito al momento de estimar.
  final String? modeloDestino;

  /// Precio de lista del modelo nuevo al momento de estimar, con IVA.
  final double? precioDestino;
  final double minimo;
  final double maximo;
  final SupuestosEstimacion supuestos;

  Map<String, Object?> toJson() => {
    'id': id,
    'creadaEn': creadaEn.toUtc().toIso8601String(),
    'vehiculoId': vehiculoId,
    'marca': marca,
    'modelo': modelo,
    'anio': anio,
    'km': km,
    'estado': estado.enElContrato,
    'modeloCatalogoId': modeloCatalogoId,
    'modeloDestino': modeloDestino,
    'precioDestino': precioDestino,
    'minimo': minimo,
    'maximo': maximo,
    'supuestos': supuestos.toJson(),
  };
}

int? _entero(Object? valor) => valor is num ? valor.toInt() : null;

/// Lee un `date-time` del contrato. Sin zona se toma como UTC, que es lo que
/// el contrato declara para este campo.
DateTime _leerMomento(Object? valor) {
  final texto = leerTexto(valor, 'creadaEn');
  final momento = DateTime.tryParse(texto);
  if (momento == null) {
    throw FormatException('El campo «creadaEn» no es una fecha: $texto');
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
          momento.millisecond,
        );
}
