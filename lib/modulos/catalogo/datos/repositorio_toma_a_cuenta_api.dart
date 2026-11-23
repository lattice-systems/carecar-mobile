import '../../../api/carecar_api.dart';
import '../../../api/modelos/estimacion_toma_cuenta.dart';
import '../dominio/repositorio_toma_a_cuenta.dart';
import '../dominio/toma_a_cuenta.dart';

/// Estima con `POST /toma-a-cuenta/estimaciones` y traduce a dominio.
///
/// Las excepciones de la API pasan tal cual: la presentacion decide como
/// mostrarlas.
class RepositorioTomaACuentaApi implements RepositorioTomaACuenta {
  const RepositorioTomaACuentaApi(this._api);

  final CarecarApi _api;

  @override
  Future<Estimacion> estimar(SolicitudEstimacion solicitud) async {
    final estado = _aContrato(solicitud.estado);
    final peticion = switch (solicitud) {
      SolicitudDeVehiculo() => NuevaEstimacionTomaCuenta.deVehiculo(
        vehiculoId: solicitud.vehiculoId,
        km: solicitud.km,
        estado: estado,
        modeloCatalogoId: solicitud.modeloDestinoId,
      ),
      SolicitudCapturada() => NuevaEstimacionTomaCuenta.capturado(
        marca: solicitud.marca.trim(),
        modelo: solicitud.modelo.trim(),
        anio: solicitud.anio,
        km: solicitud.km,
        estado: estado,
        modeloCatalogoId: solicitud.modeloDestinoId,
      ),
    };
    return _aEstimacion(await _api.estimarTomaACuenta(peticion));
  }

  @override
  Future<PaginaDeEstimaciones> guardadas({
    int pagina = 0,
    int tamano = 20,
  }) async {
    final p = await _api.paginaDeEstimaciones(pagina: pagina, tamano: tamano);
    return PaginaDeEstimaciones(
      estimaciones: [for (final e in p.contenido) _aEstimacion(e)],
      pagina: p.pagina,
      hayMas: p.hayMas,
    );
  }

  static Estimacion _aEstimacion(EstimacionTomaCuenta dto) {
    return Estimacion(
      id: dto.id,
      creadaEn: dto.creadaEn,
      marca: dto.marca,
      modelo: dto.modelo,
      anio: dto.anio,
      km: dto.km,
      estado: _aDominio(dto.estado),
      minimo: dto.minimo,
      maximo: dto.maximo,
      edadAnios: dto.supuestos.edadAnios,
      kmEsperado: dto.supuestos.kmEsperado,
      margen: dto.supuestos.margen,
      modeloDestino: dto.modeloDestino,
      precioDestino: dto.precioDestino,
    );
  }

  static EstadoVehiculo _aContrato(EstadoAuto e) => switch (e) {
    EstadoAuto.excelente => EstadoVehiculo.excelente,
    EstadoAuto.bueno => EstadoVehiculo.bueno,
    EstadoAuto.regular => EstadoVehiculo.regular,
    EstadoAuto.malo => EstadoVehiculo.malo,
  };

  // Un estado que el contrato aun no declara se lee como el mas neutro.
  static EstadoAuto _aDominio(EstadoVehiculo e) => switch (e) {
    EstadoVehiculo.excelente => EstadoAuto.excelente,
    EstadoVehiculo.regular => EstadoAuto.regular,
    EstadoVehiculo.malo => EstadoAuto.malo,
    EstadoVehiculo.bueno || EstadoVehiculo.desconocido => EstadoAuto.bueno,
  };
}
