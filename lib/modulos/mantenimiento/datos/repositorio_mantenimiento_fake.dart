import '../dominio/fallos_mantenimiento.dart';
import '../dominio/plan_mantenimiento.dart';
import '../dominio/repositorio_mantenimiento.dart';

/// Repositorio con datos en memoria para pruebas y desarrollo.
///
/// Parte de un plan de ejemplo (taller en 9,000 km, próximo servicio a los
/// 10,000). `registrarKm` se comporta como el servidor: un km menor al último
/// lanza `KmInvalido`; uno válido queda como lectura del cliente y recalcula
/// lo que falta. Con `error` todo falla a pedido, como lo haría la red.
class RepositorioMantenimientoFake implements RepositorioMantenimiento {
  RepositorioMantenimientoFake({PlanMantenimiento? plan, this.error})
    : _plan = plan ?? planDeEjemplo();

  /// Si no es nulo, todas las operaciones lo lanzan.
  final Object? error;

  PlanMantenimiento _plan;
  int _siguienteId = 1;

  /// Los km que se han registrado, en orden.
  final List<int> lecturas = [];

  /// Plan de ejemplo: un servicio hecho, el próximo a 1,000 km y uno pendiente.
  static PlanMantenimiento planDeEjemplo() => PlanMantenimiento(
    vehiculoId: 5,
    kmActual: 9000,
    kmActualizadoEn: DateTime(2026, 11, 20),
    kmFuente: FuenteKm.taller,
    promedioKmDiario: 40,
    servicios: [
      ServicioMantenimiento(
        id: 1,
        nombre: 'Servicio de 5,000 km',
        km: 5000,
        meses: 6,
        precioEstimado: 1200,
        conceptos: const ['Cambio de aceite y filtro', 'Revisión de niveles'],
        estado: EstadoServicio.hecho,
        hechoEn: DateTime(2026, 6, 10),
      ),
      const ServicioMantenimiento(
        id: 2,
        nombre: 'Servicio de 10,000 km',
        km: 10000,
        meses: 12,
        precioEstimado: 1850,
        conceptos: [
          'Cambio de aceite y filtro',
          'Revisión de frenos',
          'Rotación de llantas',
        ],
        estado: EstadoServicio.proximo,
      ),
      const ServicioMantenimiento(
        id: 3,
        nombre: 'Servicio de 15,000 km',
        km: 15000,
        meses: 18,
        precioEstimado: 1500,
        conceptos: ['Cambio de aceite y filtro', 'Filtro de cabina'],
        estado: EstadoServicio.pendiente,
      ),
    ],
    proximo: ProximoServicio(
      servicioId: 2,
      nombre: 'Servicio de 10,000 km',
      kmObjetivo: 10000,
      fechaEstimada: DateTime(2026, 12, 16),
      faltanKm: 1000,
      faltanDias: 25,
      motivo: MotivoProximo.km,
    ),
  );

  void _fallaSiHayError() {
    final e = error;
    if (e != null) throw e;
  }

  @override
  Future<PlanMantenimiento> plan(int vehiculoId) async {
    _fallaSiHayError();
    return _plan;
  }

  @override
  Future<LecturaKm> registrarKm(int vehiculoId, int km) async {
    _fallaSiHayError();
    if (km < (_plan.kmActual ?? 0)) throw const KmInvalido();
    lecturas.add(km);
    final ahora = DateTime.now();
    final p = _plan.proximo;
    _plan = PlanMantenimiento(
      vehiculoId: _plan.vehiculoId,
      kmActual: km,
      kmActualizadoEn: ahora,
      kmFuente: FuenteKm.cliente,
      promedioKmDiario: _plan.promedioKmDiario,
      servicios: _plan.servicios,
      proximo: p == null
          ? null
          : ProximoServicio(
              servicioId: p.servicioId,
              nombre: p.nombre,
              kmObjetivo: p.kmObjetivo,
              fechaEstimada: p.fechaEstimada,
              faltanKm: p.kmObjetivo - km,
              faltanDias: p.faltanDias,
              motivo: p.motivo,
            ),
    );
    return LecturaKm(id: _siguienteId++, km: km, registradaEn: ahora);
  }
}
