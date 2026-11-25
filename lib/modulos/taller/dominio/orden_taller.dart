import 'etapa_taller.dart';

/// Semaforo de un punto de la inspeccion multipunto (V2-M04.04).
enum ResultadoInspeccion {
  verde('VERDE'),
  amarillo('AMARILLO'),
  rojo('ROJO');

  const ResultadoInspeccion(this.enElContrato);

  final String enElContrato;

  static ResultadoInspeccion? desde(String? valor) {
    for (final resultado in values) {
      if (resultado.enElContrato == valor) return resultado;
    }
    return null;
  }
}

enum TipoEvidencia {
  foto('FOTO'),
  video('VIDEO');

  const TipoEvidencia(this.enElContrato);

  final String enElContrato;

  static TipoEvidencia? desde(String? valor) {
    for (final tipo in values) {
      if (tipo.enElContrato == valor) return tipo;
    }
    return null;
  }
}

/// Respuesta del cliente a un trabajo adicional (V2-M04.05).
enum EstadoAdicional {
  pendiente('PENDIENTE'),
  aprobado('APROBADO'),
  rechazado('RECHAZADO');

  const EstadoAdicional(this.enElContrato);

  final String enElContrato;

  static EstadoAdicional? desde(String? valor) {
    for (final estado in values) {
      if (estado.enElContrato == valor) return estado;
    }
    return null;
  }
}

/// Una orden sin entregar, para la tarjeta de Inicio (V2-M04.01).
class OrdenEnCurso {
  const OrdenEnCurso({
    required this.id,
    required this.vehiculoId,
    required this.vehiculo,
    required this.etapa,
    required this.avance,
    required this.adicionalesPendientes,
    this.entregaEstimada,
    this.asesor,
  });

  final int id;
  final int vehiculoId;
  final String vehiculo;
  final EtapaTaller etapa;

  /// De 0 a 100.
  final int avance;
  final int adicionalesPendientes;

  /// Hora de la agencia; nula si aun no se estima.
  final DateTime? entregaEstimada;
  final String? asesor;
}

/// Una etapa que ya empezo; `fin` es nulo mientras siga en curso.
class PasoEtapa {
  const PasoEtapa({
    required this.etapa,
    required this.inicio,
    this.fin,
    this.nota,
  });

  final EtapaTaller etapa;
  final DateTime inicio;
  final DateTime? fin;
  final String? nota;
}

/// Un paso de la linea de tiempo como se dibuja: las etapas recorridas con su
/// hora y, despues de la actual, las que faltan.
class PasoLineaTaller {
  const PasoLineaTaller({
    required this.etapa,
    required this.estado,
    this.inicio,
    this.nota,
  });

  final EtapaTaller etapa;
  final EstadoEtapa estado;
  final DateTime? inicio;
  final String? nota;
}

class Evidencia {
  const Evidencia({required this.id, required this.tipo, required this.url});

  final int id;
  final TipoEvidencia tipo;

  /// Temporal y firmada: vence a los 15 minutos.
  final Uri url;
}

class PuntoRevisado {
  const PuntoRevisado({
    required this.id,
    required this.punto,
    required this.resultado,
    required this.evidencias,
    this.comentario,
  });

  final int id;
  final String punto;
  final ResultadoInspeccion resultado;
  final String? comentario;
  final List<Evidencia> evidencias;
}

/// Trabajo que el taller propone ademas de lo acordado. Los montos traen el
/// IVA incluido y el total es la mano de obra mas las refacciones.
class TrabajoAdicional {
  const TrabajoAdicional({
    required this.id,
    required this.concepto,
    required this.manoDeObra,
    required this.refacciones,
    required this.total,
    required this.estado,
    this.respondidoEn,
  });

  final int id;
  final String concepto;
  final double manoDeObra;
  final double refacciones;
  final double total;
  final EstadoAdicional estado;
  final DateTime? respondidoEn;

  bool get pendiente => estado == EstadoAdicional.pendiente;
}

/// La orden en el taller (V2-M04.02, V2-M04.04 y V2-M04.05).
class OrdenEnVivo {
  const OrdenEnVivo({
    required this.id,
    required this.vehiculoId,
    required this.vehiculo,
    required this.etapa,
    required this.avance,
    required this.etapas,
    required this.inspeccion,
    required this.evidencias,
    required this.adicionales,
    required this.totalOrden,
    required this.totalAdicionalesAprobados,
    required this.totalAdicionalesPendientes,
    required this.totalEstimado,
    this.entregaEstimada,
    this.asesor,
  });

  final int id;
  final int vehiculoId;
  final String vehiculo;
  final EtapaTaller etapa;
  final int avance;
  final DateTime? entregaEstimada;
  final String? asesor;

  /// Solo las etapas que ya empezaron, en orden; la ultima es la actual.
  final List<PasoEtapa> etapas;
  final List<PuntoRevisado> inspeccion;

  /// Fotos y videos de la orden que no son de un punto revisado.
  final List<Evidencia> evidencias;
  final List<TrabajoAdicional> adicionales;
  final double totalOrden;
  final double totalAdicionalesAprobados;
  final double totalAdicionalesPendientes;

  /// Total de la orden mas los adicionales aprobados.
  final double totalEstimado;

  List<TrabajoAdicional> get pendientes =>
      adicionales.where((a) => a.pendiente).toList();

  /// Las etapas recorridas con su hora y despues las que faltan. La actual es
  /// la ultima recorrida, salvo que la orden ya se entrego: entonces todas
  /// quedan hechas. Las etapas que el taller salto no aparecen.
  List<PasoLineaTaller> lineaDeTiempo() {
    final recorridas = etapas.isEmpty
        ? [PasoEtapa(etapa: etapa, inicio: DateTime(0))]
        : etapas;
    final actual = recorridas.last.etapa;
    final entregada = actual == EtapaTaller.entregado;
    return [
      for (final paso in recorridas)
        PasoLineaTaller(
          etapa: paso.etapa,
          estado: paso.etapa == actual && !entregada
              ? EstadoEtapa.actual
              : EstadoEtapa.hecha,
          inicio: etapas.isEmpty ? null : paso.inicio,
          nota: paso.nota,
        ),
      for (final siguiente in EtapaTaller.values)
        if (siguiente.index > actual.index)
          PasoLineaTaller(etapa: siguiente, estado: EstadoEtapa.pendiente),
    ];
  }
}
