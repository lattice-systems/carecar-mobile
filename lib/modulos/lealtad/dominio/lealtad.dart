/// Nivel del cliente por los puntos ganados en 12 meses (V2-M12.01).
enum NivelLealtad {
  bronce('BRONCE'),
  plata('PLATA'),
  oro('ORO');

  const NivelLealtad(this.codigo);

  final String codigo;

  /// Un valor que la app no conoce se lee como bronce.
  static NivelLealtad desde(String? codigo) => values.firstWhere(
    (n) => n.codigo == codigo,
    orElse: () => NivelLealtad.bronce,
  );

  static NivelLealtad? desdeOpcional(String? codigo) =>
      codigo == null ? null : desde(codigo);
}

/// Mis puntos y nivel (V2-M12.01).
class ResumenLealtad {
  const ResumenLealtad({
    required this.saldo,
    required this.nivel,
    required this.ganados,
    required this.puntosParaSiguiente,
    required this.codigoReferido,
    this.siguienteNivel,
  });

  final int saldo;
  final NivelLealtad nivel;

  /// Puntos ganados en 12 meses; deciden el nivel.
  final int ganados;

  /// Nulo en oro.
  final NivelLealtad? siguienteNivel;
  final int puntosParaSiguiente;
  final String codigoReferido;

  /// Avance de 0 a 1 hacia el siguiente nivel; 1 en oro.
  double get avance {
    if (siguienteNivel == null) return 1;
    final meta = ganados + puntosParaSiguiente;
    return meta <= 0 ? 1 : (ganados / meta).clamp(0, 1).toDouble();
  }
}

/// Por que se movieron los puntos (V2-M12.05).
enum MotivoPuntos {
  servicio('SERVICIO'),
  canje('CANJE'),
  devolucionCanje('DEVOLUCION_CANJE'),
  referido('REFERIDO'),
  ajuste('AJUSTE'),
  desconocido('');

  const MotivoPuntos(this.codigo);

  final String codigo;

  static MotivoPuntos desde(String? codigo) => values.firstWhere(
    (m) => m.codigo == codigo && m != desconocido,
    orElse: () => MotivoPuntos.desconocido,
  );
}

/// Un movimiento de puntos: positivo si gano, negativo si gasto.
class MovimientoPuntos {
  const MovimientoPuntos({
    required this.id,
    required this.puntos,
    required this.motivo,
    required this.creadoEn,
    this.referenciaTipo,
    this.referenciaId,
  });

  final int id;
  final int puntos;
  final MotivoPuntos motivo;
  final String? referenciaTipo;
  final int? referenciaId;
  final DateTime creadoEn;
}

/// Una pagina de movimientos.
class PaginaMovimientos {
  const PaginaMovimientos({
    required this.movimientos,
    required this.pagina,
    required this.hayMas,
  });

  final List<MovimientoPuntos> movimientos;
  final int pagina;
  final bool hayMas;
}

/// Una recompensa del catalogo (V2-M12.03).
class Recompensa {
  const Recompensa({
    required this.id,
    required this.nombre,
    required this.puntos,
    this.descripcion,
    this.existencia,
  });

  final int id;
  final String nombre;
  final String? descripcion;
  final int puntos;

  /// Nula si no tiene limite.
  final int? existencia;

  bool get agotada => existencia == 0;
}

enum EstadoCanje {
  vigente('VIGENTE'),
  usado('USADO'),
  vencido('VENCIDO');

  const EstadoCanje(this.codigo);

  final String codigo;

  /// Un valor desconocido se lee como vencido: no se ofrece usarlo.
  static EstadoCanje desde(String? codigo) => values.firstWhere(
    (e) => e.codigo == codigo,
    orElse: () => EstadoCanje.vencido,
  );
}

/// Un canje con su codigo para mostrar como QR (V2-M12.03).
class Canje {
  const Canje({
    required this.id,
    required this.codigo,
    required this.recompensa,
    required this.puntos,
    required this.estado,
    required this.venceEn,
    required this.creadoEn,
    this.usadoEn,
  });

  final int id;
  final String codigo;
  final String recompensa;
  final int puntos;
  final EstadoCanje estado;
  final DateTime venceEn;
  final DateTime? usadoEn;
  final DateTime creadoEn;
}

enum EstadoReferido {
  registrado('REGISTRADO'),
  enSeguimiento('EN_SEGUIMIENTO'),
  compro('COMPRO'),
  descartado('DESCARTADO');

  const EstadoReferido(this.codigo);

  final String codigo;

  static EstadoReferido desde(String? codigo) => values.firstWhere(
    (e) => e.codigo == codigo,
    orElse: () => EstadoReferido.registrado,
  );
}

/// Un amigo referido (V2-M12.04).
class Referido {
  const Referido({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.puntos,
    required this.creadoEn,
  });

  final int id;
  final String nombre;
  final EstadoReferido estado;

  /// Los que gane si compro.
  final int puntos;
  final DateTime creadoEn;
}
