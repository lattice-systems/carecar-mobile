/// Estreno (M16): prueba de manejo y cotización de auto nuevo.
library;

/// Qué pide el cliente.
enum TipoSolicitud { pruebaManejo, cotizacion }

/// Cuándo prefiere la prueba.
enum FranjaPreferida { manana, tarde }

/// En qué va una solicitud (V2-M16.04).
enum EstadoSolicitud { recibida, enAtencion, cerrada }

/// Mensualidad estimada, no vinculante (V2-M16.02).
class MensualidadEstimada {
  const MensualidadEstimada({
    required this.precio,
    required this.enganche,
    required this.montoFinanciado,
    required this.tasaAnual,
    required this.plazoMeses,
    required this.mensualidad,
    required this.leyenda,
  });

  final double precio;
  final double enganche;
  final double montoFinanciado;
  final double tasaAnual;
  final int plazoMeses;
  final double mensualidad;
  final String leyenda;
}

/// Una solicitud de estreno con su estado.
class SolicitudDeEstreno {
  const SolicitudDeEstreno({
    required this.id,
    required this.tipo,
    required this.modelo,
    required this.estado,
    required this.creadaEn,
    this.vendedor,
    this.fecha,
    this.franja,
    this.cotizacion,
  });

  final int id;
  final TipoSolicitud tipo;
  final String modelo;
  final EstadoSolicitud estado;
  final DateTime creadaEn;

  /// Nombre del vendedor cuando ya hay uno asignado.
  final String? vendedor;
  final DateTime? fecha;
  final FranjaPreferida? franja;
  final MensualidadEstimada? cotizacion;
}

/// Una página de solicitudes.
class PaginaDeSolicitudes {
  const PaginaDeSolicitudes({
    required this.solicitudes,
    required this.pagina,
    required this.hayMas,
  });

  final List<SolicitudDeEstreno> solicitudes;
  final int pagina;
  final bool hayMas;
}

/// Por qué no se pudo; la pantalla elige el texto por tipo.
sealed class FalloEstreno implements Exception {
  const FalloEstreno();
}

class EstrenoSinConexion extends FalloEstreno {
  const EstrenoSinConexion();
}

/// El modelo no tiene precio publicado (409).
class EstrenoSinPrecio extends FalloEstreno {
  const EstrenoSinPrecio();
}

/// Ya hay una solicitud abierta del mismo modelo y tipo (409).
class EstrenoDuplicada extends FalloEstreno {
  const EstrenoDuplicada();
}

/// Enganche o plazo no permitidos u otro dato que el servidor rechaza (400),
/// con su mensaje.
class EstrenoDatosInvalidos extends FalloEstreno {
  const EstrenoDatosInvalidos(this.mensaje);
  final String mensaje;
}

/// Cualquier otro error.
class EstrenoNoDisponible extends FalloEstreno {
  const EstrenoNoDisponible();
}

/// Lo que el módulo necesita del backend (V2-M16).
abstract interface class RepositorioEstreno {
  /// Falla con un [FalloEstreno].
  Future<MensualidadEstimada> calcular({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
  });

  /// Falla con un [FalloEstreno].
  Future<SolicitudDeEstreno> pedirPrueba({
    required int modeloId,
    required DateTime fecha,
    required FranjaPreferida franja,
    int? estimacionId,
  });

  /// Falla con un [FalloEstreno].
  Future<SolicitudDeEstreno> pedirCotizacion({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
    int? estimacionId,
  });

  /// Falla con un [FalloEstreno].
  Future<PaginaDeSolicitudes> solicitudes({int pagina = 0});
}

/// Plazos permitidos; los mismos que `parametro_financiamiento`.
const plazosPermitidos = [12, 24, 36, 48, 60];

/// Enganche mínimo sugerido en la app (el backend manda la última palabra).
const engancheMinimoPct = 0.10;
