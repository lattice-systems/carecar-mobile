import '../dominio/campana_seguridad.dart';
import '../dominio/garantia_vehiculo.dart';
import '../dominio/repositorio_garantia.dart';

/// Repositorio en memoria para pruebas. Agendar una campana abierta la deja
/// agendada con su cita, como el backend; una ya agendada lanza
/// [AgendaCampanaRechazada]. Los datos de ejemplo viven en las pruebas.
class RepositorioGarantiaFake implements RepositorioGarantia {
  RepositorioGarantiaFake({
    GarantiaVehiculo? garantia,
    List<CampanaSeguridad> campanas = const [],
    this.falla,
    this.rechazo,
  }) : garantiaActual =
           garantia ?? const GarantiaVehiculo(vehiculoId: 1, coberturas: []),
       campanasActuales = campanas;

  GarantiaVehiculo garantiaActual;
  List<CampanaSeguridad> campanasActuales;

  /// Si no es nulo, cada lectura lo lanza.
  Object? falla;

  /// Si no es nulo, agendar lo lanza como [AgendaCampanaRechazada].
  MotivoRechazoCampana? rechazo;

  /// Lo que se agendo, en orden: (vehiculoId, campanaId, franjaId, fecha).
  final agendadas = <(int, int, int, DateTime)>[];

  /// Cuantas veces se pidieron las campanas, para saber si se recargo.
  var campanasPedidas = 0;

  /// Cuantas veces se pidio la garantia.
  var garantiasPedidas = 0;

  @override
  Future<GarantiaVehiculo> garantia(int vehiculoId) async {
    garantiasPedidas++;
    if (falla != null) throw falla!;
    return garantiaActual;
  }

  @override
  Future<List<CampanaSeguridad>> campanas(int vehiculoId) async {
    campanasPedidas++;
    if (falla != null) throw falla!;
    return List.unmodifiable(campanasActuales);
  }

  @override
  Future<CitaDeCampana> agendarCampana({
    required int vehiculoId,
    required int campanaId,
    required int franjaId,
    required DateTime fecha,
  }) async {
    if (rechazo != null) throw AgendaCampanaRechazada(rechazo!);
    final campana = campanasActuales.firstWhere((c) => c.id == campanaId);
    if (!campana.abierta) {
      throw const AgendaCampanaRechazada(MotivoRechazoCampana.yaAgendada);
    }
    agendadas.add((vehiculoId, campanaId, franjaId, fecha));
    final cita = CitaDeCampana(
      id: 900 + agendadas.length,
      fecha: fecha,
      horaInicio: '09:00',
      horaFin: '10:00',
    );
    campanasActuales = [
      for (final c in campanasActuales)
        c.id == campanaId
            ? CampanaSeguridad(
                id: c.id,
                codigo: c.codigo,
                titulo: c.titulo,
                descripcion: c.descripcion,
                queHacer: c.queHacer,
                gravedad: c.gravedad,
                estado: EstadoCampana.agendada,
                citaId: cita.id,
                publicadaEn: c.publicadaEn,
              )
            : c,
    ];
    return cita;
  }
}
