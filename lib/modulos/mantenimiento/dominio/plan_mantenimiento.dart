/// Estado de un servicio del plan respecto al auto del cliente.
///
/// `hecho` ya está cruzado con el historial; `proximo` es el que sigue;
/// `vencido`, el que ya pasó de km o de tiempo sin hacerse.
enum EstadoServicio {
  hecho('hecho'),
  pendiente('pendiente'),
  proximo('proximo'),
  vencido('vencido');

  const EstadoServicio(this.codigo);

  final String codigo;

  /// El estado de un código del contrato. Uno que la app aún no conoce se
  /// trata como `pendiente`: se muestra sin romper el plan.
  static EstadoServicio desde(String codigo) => values.firstWhere(
    (e) => e.codigo == codigo,
    orElse: () => EstadoServicio.pendiente,
  );
}

/// Qué llegó primero para el próximo servicio: los kilómetros o los meses.
enum MotivoProximo {
  km('km'),
  tiempo('tiempo');

  const MotivoProximo(this.codigo);

  final String codigo;

  static MotivoProximo desde(String codigo) => values.firstWhere(
    (m) => m.codigo == codigo,
    orElse: () => MotivoProximo.km,
  );
}

/// Quién dejó el kilometraje vigente. El taller es la fuente oficial.
enum FuenteKm {
  taller('taller'),
  cliente('cliente');

  const FuenteKm(this.codigo);

  final String codigo;

  static FuenteKm? desde(String? codigo) {
    for (final f in values) {
      if (f.codigo == codigo) return f;
    }
    return null;
  }
}

/// Un servicio del plan de mantenimiento del modelo (V2-M05.01).
///
/// Dart puro. El precio es una estimación no vinculante: la pantalla siempre
/// lo muestra con esa leyenda.
class ServicioMantenimiento {
  const ServicioMantenimiento({
    required this.id,
    required this.nombre,
    required this.km,
    required this.meses,
    required this.precioEstimado,
    required this.conceptos,
    required this.estado,
    this.hechoEn,
  });

  final int id;
  final String nombre;
  final int km;
  final int meses;
  final double precioEstimado;
  final List<String> conceptos;
  final EstadoServicio estado;

  /// Día en que se hizo, si ya está hecho.
  final DateTime? hechoEn;

  /// Un servicio hecho no se vuelve a agendar desde el plan.
  bool get sePuedeAgendar => estado != EstadoServicio.hecho;
}

/// El servicio que sigue y cuándo toca (V2-M05.02).
class ProximoServicio {
  const ProximoServicio({
    required this.servicioId,
    required this.nombre,
    required this.kmObjetivo,
    required this.fechaEstimada,
    required this.faltanKm,
    required this.faltanDias,
    required this.motivo,
  });

  final int servicioId;
  final String nombre;
  final int kmObjetivo;
  final DateTime fechaEstimada;
  final int faltanKm;
  final int faltanDias;
  final MotivoProximo motivo;

  /// Ya llegó o pasó el momento: no falta kilometraje o no faltan días.
  bool get yaToca => faltanKm <= 0 || faltanDias <= 0;
}

/// El plan de mantenimiento de un vehículo con su estado.
class PlanMantenimiento {
  const PlanMantenimiento({
    required this.vehiculoId,
    required this.servicios,
    this.kmActual,
    this.kmActualizadoEn,
    this.kmFuente,
    this.promedioKmDiario,
    this.proximo,
  });

  final int vehiculoId;
  final int? kmActual;
  final DateTime? kmActualizadoEn;
  final FuenteKm? kmFuente;
  final double? promedioKmDiario;
  final List<ServicioMantenimiento> servicios;
  final ProximoServicio? proximo;

  /// El modelo y año del auto no tienen plan cargado.
  bool get sinPlan => servicios.isEmpty;

  int get hechos =>
      servicios.where((s) => s.estado == EstadoServicio.hecho).length;

  /// Cuánto del camino al próximo servicio ya se recorrió, de 0 a 1.
  ///
  /// Se mide en kilómetros desde el último servicio hecho (o desde cero si no
  /// hay ninguno) hasta el que toca. `null` si toca por tiempo, no hay
  /// kilometraje vigente o no hay próximo servicio: sin kilómetros no hay un
  /// avance que dibujar.
  double? get avanceDelProximo {
    final siguiente = proximo;
    final km = kmActual;
    if (siguiente == null || km == null) return null;
    if (siguiente.motivo != MotivoProximo.km) return null;
    var base = 0;
    for (final s in servicios) {
      if (s.estado == EstadoServicio.hecho &&
          s.km < siguiente.kmObjetivo &&
          s.km > base) {
        base = s.km;
      }
    }
    final tramo = siguiente.kmObjetivo - base;
    if (tramo <= 0) return null;
    return ((km - base) / tramo).clamp(0.0, 1.0);
  }

  ServicioMantenimiento? servicioPorId(int id) {
    for (final s in servicios) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// La lectura que devuelve el servidor al registrar un kilometraje.
class LecturaKm {
  const LecturaKm({
    required this.id,
    required this.km,
    required this.registradaEn,
  });

  final int id;
  final int km;
  final DateTime registradaEn;
}
