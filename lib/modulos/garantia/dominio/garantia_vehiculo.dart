/// Como va una cobertura de garantia (V2-M10.01).
enum EstadoCobertura {
  vigente('VIGENTE'),
  porVencer('POR_VENCER'),
  vencida('VENCIDA');

  const EstadoCobertura(this.codigo);

  final String codigo;

  /// Un estado que esta version no conoce se trata como vigente: no se
  /// alarma al cliente por algo que no se entiende.
  static EstadoCobertura desde(String? codigo) => values.firstWhere(
    (estado) => estado.codigo == codigo,
    orElse: () => vigente,
  );
}

/// El limite que se alcanza primero, o el que vencio la cobertura.
enum LimiteCobertura {
  fecha('fecha'),
  km('km');

  const LimiteCobertura(this.codigo);

  final String codigo;

  static LimiteCobertura desde(String? codigo) =>
      codigo == km.codigo ? km : fecha;
}

/// Lo que cubre la garantia de un componente y hasta cuando (V2-M10.01).
class CoberturaGarantia {
  const CoberturaGarantia({
    required this.id,
    required this.componente,
    required this.iniciaEn,
    required this.venceEn,
    required this.diasRestantes,
    required this.consumo,
    required this.estado,
    required this.limite,
    this.descripcion,
    this.kmLimite,
    this.kmRestantes,
  });

  final int id;
  final String componente;
  final String? descripcion;
  final DateTime iniciaEn;
  final DateTime venceEn;
  final int? kmLimite;

  /// Dias hasta [venceEn]; 0 si ya paso.
  final int diasRestantes;

  /// Nulo si no tiene km limite o no se conoce el km del auto.
  final int? kmRestantes;

  /// De 0 a 100: lo usado del tiempo o del km, lo que vaya mas adelante.
  final int consumo;
  final EstadoCobertura estado;
  final LimiteCobertura limite;
}

/// La garantia de un vehiculo: sus coberturas contra el km actual.
class GarantiaVehiculo {
  const GarantiaVehiculo({
    required this.vehiculoId,
    required this.coberturas,
    this.kmActual,
  });

  final int vehiculoId;

  /// Nulo si no se conoce el km del auto.
  final int? kmActual;
  final List<CoberturaGarantia> coberturas;
}
