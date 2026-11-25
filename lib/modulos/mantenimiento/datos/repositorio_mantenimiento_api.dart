import '../../../api/excepciones.dart';
import '../../../api/modelos/mantenimiento.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/fallos_mantenimiento.dart';
import '../dominio/plan_mantenimiento.dart';
import '../dominio/repositorio_mantenimiento.dart';

/// Plan y lecturas de kilometraje con el cliente HTTP del núcleo.
///
/// Las excepciones de la API (`SinConexion`, `NoEncontrado`…) pasan tal cual:
/// la presentación decide cómo mostrarlas. Solo se traduce el 422
/// `KM_INVALIDO`, que el cliente HTTP entrega como `SinParametrosDeValuacion`
/// (todo 422 cae ahí); un 422 con otro código no se confunde con él.
class RepositorioMantenimientoApi implements RepositorioMantenimiento {
  const RepositorioMantenimientoApi(this._cliente);

  final ApiCliente _cliente;

  @override
  Future<PlanMantenimiento> plan(int vehiculoId) async {
    final dto = await _cliente.obtener(
      '/vehiculos/$vehiculoId/mantenimiento',
      PlanMantenimientoDto.fromJson,
    );
    return PlanMantenimiento(
      vehiculoId: dto.vehiculoId,
      kmActual: dto.kmActual,
      kmActualizadoEn: dto.kmActualizadoEn,
      kmFuente: FuenteKm.desde(dto.kmFuente),
      promedioKmDiario: dto.promedioKmDiario,
      servicios: [for (final s in dto.servicios) _servicio(s)],
      proximo: dto.proximo == null ? null : _proximo(dto.proximo!),
    );
  }

  @override
  Future<LecturaKm> registrarKm(int vehiculoId, int km) async {
    try {
      final dto = await _cliente.enviar(
        '/vehiculos/$vehiculoId/lecturas-km',
        cuerpo: {'km': km},
        leer: LecturaKmDto.fromJson,
      );
      return LecturaKm(id: dto.id, km: dto.km, registradaEn: dto.registradaEn);
    } on SinParametrosDeValuacion catch (e) {
      if (e.problema?.codigo == CodigoProblema.kmInvalido) {
        throw const KmInvalido();
      }
      rethrow;
    }
  }

  static ServicioMantenimiento _servicio(ServicioMantenimientoDto s) =>
      ServicioMantenimiento(
        id: s.id,
        nombre: s.nombre,
        km: s.km,
        meses: s.meses,
        precioEstimado: s.precioEstimado,
        conceptos: s.conceptos,
        estado: EstadoServicio.desde(s.estado),
        hechoEn: s.hechoEn,
      );

  static ProximoServicio _proximo(ProximoServicioDto p) => ProximoServicio(
    servicioId: p.servicioId,
    nombre: p.nombre,
    kmObjetivo: p.kmObjetivo,
    fechaEstimada: p.fechaEstimada,
    faltanKm: p.faltanKm,
    faltanDias: p.faltanDias,
    motivo: MotivoProximo.desde(p.motivo),
  );
}
