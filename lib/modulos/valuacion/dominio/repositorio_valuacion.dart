import 'valuacion.dart';

/// Por que el servidor no dejo hacer algo. La pantalla lo explica en vez de
/// mostrar un error generico.
enum MotivoRechazoValuacion {
  /// La estimacion se capturo a mano: esa valuacion se pide en la agencia.
  sinVehiculo,

  /// La valuacion ya no admite fotos.
  cerrada,

  /// La valuacion ya tiene cita o ya no se puede agendar.
  noAgendable,

  /// La franja se lleno mientras el cliente la elegia.
  sinCupo,

  /// El vehiculo ya tiene una cita ese dia.
  citaDuplicada,

  /// La vigencia de la oferta ya paso.
  ofertaVencida,

  /// La oferta cambio o ya se respondio lo contrario.
  ofertaNoDisponible,
}

/// Fallo esperado de una valuacion.
class ValuacionRechazada implements Exception {
  const ValuacionRechazada(this.motivo);

  final MotivoRechazoValuacion motivo;

  @override
  String toString() => 'ValuacionRechazada(${motivo.name})';
}

/// Una pagina de valuaciones, de la mas reciente a la mas antigua.
class PaginaDeValuaciones {
  const PaginaDeValuaciones({
    required this.valuaciones,
    required this.pagina,
    required this.hayMas,
  });

  final List<Valuacion> valuaciones;

  /// Indice de esta pagina, empezando en 0.
  final int pagina;
  final bool hayMas;
}

/// Lo que el modulo `valuacion` necesita de la API (V2-M26.01 a V2-M26.05).
///
/// Un recurso ajeno o inexistente falla con `NoEncontrado`.
abstract interface class RepositorioValuacion {
  /// Pide la valuacion de una estimacion. Si el vehiculo ya tiene una abierta,
  /// devuelve esa. Lanza [ValuacionRechazada] con `sinVehiculo`.
  Future<Valuacion> pedir(int estimacionId);

  Future<PaginaDeValuaciones> listar({int pagina = 0, int tamano = 20});

  Future<Valuacion> una(int valuacionId);

  /// Sube o reemplaza una toma. [tipo] es `image/jpeg` o `image/png`. Lanza
  /// [ValuacionRechazada] con `cerrada`.
  Future<Valuacion> subirFoto({
    required int valuacionId,
    required TomaValuacion toma,
    required List<int> bytes,
    required String tipo,
  });

  /// Agenda la inspeccion. Lanza [ValuacionRechazada] con `noAgendable`,
  /// `sinCupo` o `citaDuplicada`.
  Future<InspeccionValuacion> agendar({
    required int valuacionId,
    required int franjaId,
    required DateTime fecha,
  });

  /// Acepta o rechaza la oferta de [monto], que es el que el cliente vio.
  /// Lanza [ValuacionRechazada] con `ofertaVencida` u `ofertaNoDisponible`.
  Future<Valuacion> responder({
    required int valuacionId,
    required bool aceptada,
    required double monto,
  });

  /// Un punto por mes con estimacion guardada, del mas antiguo al mas
  /// reciente.
  Future<List<PuntoValorEstimado>> valorEstimado(
    int vehiculoId, {
    int meses = 12,
  });
}
