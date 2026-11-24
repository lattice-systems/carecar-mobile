import 'comun.dart';

/// Un servicio del plan de mantenimiento del modelo (`ServicioMantenimiento`
/// del contrato de V2-M05).
///
/// `estado` y `hechoEn` ya vienen resueltos por el servidor, que cruza el plan
/// con el historial del vehículo; la app solo los muestra.
class ServicioMantenimientoDto {
  const ServicioMantenimientoDto({
    required this.id,
    required this.nombre,
    required this.km,
    required this.meses,
    required this.precioEstimado,
    required this.conceptos,
    required this.estado,
    this.hechoEn,
  });

  factory ServicioMantenimientoDto.fromJson(Map<String, Object?> json) {
    final conceptos = json['conceptos'];
    if (conceptos is! List) {
      throw const FormatException('conceptos: se esperaba una lista');
    }
    return ServicioMantenimientoDto(
      id: leerEntero(json['id'], 'id'),
      nombre: leerTexto(json['nombre'], 'nombre'),
      km: leerEntero(json['km'], 'km'),
      meses: leerEntero(json['meses'], 'meses'),
      precioEstimado: leerDecimal(json['precioEstimado'], 'precioEstimado'),
      conceptos: [for (final c in conceptos) leerTexto(c, 'conceptos')],
      estado: leerTexto(json['estado'], 'estado'),
      hechoEn: json['hechoEn'] == null
          ? null
          : leerFecha(json['hechoEn'], 'hechoEn'),
    );
  }

  final int id;
  final String nombre;
  final int km;
  final int meses;

  /// Estimación no vinculante.
  final double precioEstimado;
  final List<String> conceptos;

  /// `hecho`, `pendiente`, `proximo` o `vencido`.
  final String estado;
  final DateTime? hechoEn;
}

/// El servicio que sigue y cuándo toca (`ProximoServicio`).
class ProximoServicioDto {
  const ProximoServicioDto({
    required this.servicioId,
    required this.nombre,
    required this.kmObjetivo,
    required this.fechaEstimada,
    required this.faltanKm,
    required this.faltanDias,
    required this.motivo,
  });

  factory ProximoServicioDto.fromJson(Map<String, Object?> json) =>
      ProximoServicioDto(
        servicioId: leerEntero(json['servicioId'], 'servicioId'),
        nombre: leerTexto(json['nombre'], 'nombre'),
        kmObjetivo: leerEntero(json['kmObjetivo'], 'kmObjetivo'),
        fechaEstimada: leerFecha(json['fechaEstimada'], 'fechaEstimada'),
        faltanKm: leerEntero(json['faltanKm'], 'faltanKm'),
        faltanDias: leerEntero(json['faltanDias'], 'faltanDias'),
        motivo: leerTexto(json['motivo'], 'motivo'),
      );

  final int servicioId;
  final String nombre;
  final int kmObjetivo;
  final DateTime fechaEstimada;
  final int faltanKm;
  final int faltanDias;

  /// `km` o `tiempo`: lo que llegue primero.
  final String motivo;
}

/// `GET /vehiculos/{id}/mantenimiento` (`PlanMantenimiento`).
///
/// Sin plan para el modelo y año el servidor contesta 200 con `servicios` vacío
/// y `proximo` nulo.
class PlanMantenimientoDto {
  const PlanMantenimientoDto({
    required this.vehiculoId,
    required this.servicios,
    this.kmActual,
    this.kmActualizadoEn,
    this.kmFuente,
    this.promedioKmDiario,
    this.proximo,
  });

  factory PlanMantenimientoDto.fromJson(Map<String, Object?> json) {
    final servicios = json['servicios'];
    if (servicios is! List) {
      throw const FormatException('servicios: se esperaba una lista');
    }
    final proximo = json['proximo'];
    if (proximo != null && proximo is! Map<String, Object?>) {
      throw const FormatException('proximo: se esperaba un objeto');
    }
    return PlanMantenimientoDto(
      vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
      kmActual: json['kmActual'] == null
          ? null
          : leerEntero(json['kmActual'], 'kmActual'),
      kmActualizadoEn: json['kmActualizadoEn'] == null
          ? null
          : leerFecha(json['kmActualizadoEn'], 'kmActualizadoEn'),
      kmFuente: json['kmFuente'] == null
          ? null
          : leerTexto(json['kmFuente'], 'kmFuente'),
      promedioKmDiario: json['promedioKmDiario'] == null
          ? null
          : leerDecimal(json['promedioKmDiario'], 'promedioKmDiario'),
      servicios: [
        for (final s in servicios)
          ServicioMantenimientoDto.fromJson(_objeto(s, 'servicios')),
      ],
      proximo: proximo == null
          ? null
          : ProximoServicioDto.fromJson(proximo as Map<String, Object?>),
    );
  }

  final int vehiculoId;

  /// Kilometraje vigente: el del taller (oficial) o el del cliente si es más
  /// reciente. Nulo si el auto aún no tiene lectura.
  final int? kmActual;
  final DateTime? kmActualizadoEn;

  /// `taller` o `cliente`.
  final String? kmFuente;
  final double? promedioKmDiario;
  final List<ServicioMantenimientoDto> servicios;
  final ProximoServicioDto? proximo;
}

/// `POST /vehiculos/{id}/lecturas-km` (`LecturaKm`).
class LecturaKmDto {
  const LecturaKmDto({
    required this.id,
    required this.km,
    required this.fuente,
    required this.registradaEn,
  });

  factory LecturaKmDto.fromJson(Map<String, Object?> json) => LecturaKmDto(
    id: leerEntero(json['id'], 'id'),
    km: leerEntero(json['km'], 'km'),
    fuente: leerTexto(json['fuente'], 'fuente'),
    registradaEn: leerFechaHoraOpcional(json['registradaEn'], 'registradaEn')!,
  );

  final int id;
  final int km;

  /// Siempre `cliente`: el servidor no deja registrar lecturas del taller.
  final String fuente;
  final DateTime registradaEn;
}

Map<String, Object?> _objeto(Object? valor, String campo) {
  if (valor is Map<String, Object?>) return valor;
  throw FormatException('El campo «$campo» no es un objeto: $valor');
}
