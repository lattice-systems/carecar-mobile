import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/estreno.dart';
import '../../../api/modelos/problema.dart';
import '../dominio/estreno.dart';

/// [RepositorioEstreno] contra el contrato 2.10.0 (V2-M16). Decide los fallos
/// por el `codigo`, nunca por el texto.
class RepositorioEstrenoApi implements RepositorioEstreno {
  const RepositorioEstrenoApi(this._api);

  final CarecarApi _api;

  @override
  Future<MensualidadEstimada> calcular({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
  }) => _traducir(() async {
    final c = await _api.calcularMensualidad(
      modeloCatalogoId: modeloId,
      enganche: enganche,
      plazoMeses: plazoMeses,
    );
    return _mensualidad(c);
  });

  @override
  Future<SolicitudDeEstreno> pedirPrueba({
    required int modeloId,
    required DateTime fecha,
    required FranjaPreferida franja,
    int? estimacionId,
  }) => _traducir(
    () async => _solicitud(
      await _api.crearSolicitudEstreno(
        NuevaSolicitudEstreno(
          tipo: 'PRUEBA_MANEJO',
          modeloCatalogoId: modeloId,
          preferenciaFecha: fecha,
          preferenciaFranja: franja == FranjaPreferida.manana
              ? 'MANANA'
              : 'TARDE',
          estimacionTomaCuentaId: estimacionId,
        ),
      ),
    ),
  );

  @override
  Future<SolicitudDeEstreno> pedirCotizacion({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
    int? estimacionId,
  }) => _traducir(
    () async => _solicitud(
      await _api.crearSolicitudEstreno(
        NuevaSolicitudEstreno(
          tipo: 'COTIZACION',
          modeloCatalogoId: modeloId,
          enganche: enganche,
          plazoMeses: plazoMeses,
          estimacionTomaCuentaId: estimacionId,
        ),
      ),
    ),
  );

  @override
  Future<PaginaDeSolicitudes> solicitudes({int pagina = 0}) =>
      _traducir(() async {
        final p = await _api.paginaDeSolicitudesEstreno(pagina: pagina);
        return PaginaDeSolicitudes(
          solicitudes: p.contenido.map(_solicitud).toList(),
          pagina: p.pagina,
          hayMas: p.pagina + 1 < p.totalPaginas,
        );
      });

  static Future<T> _traducir<T>(Future<T> Function() llamada) async {
    try {
      return await llamada();
    } on SinConexion {
      throw const EstrenoSinConexion();
    } on ExcepcionApi catch (e) {
      throw switch (e.problema?.codigo) {
        CodigoProblema.estrenoSinPrecio => const EstrenoSinPrecio(),
        CodigoProblema.estrenoDuplicada => const EstrenoDuplicada(),
        CodigoProblema.datosInvalidos => EstrenoDatosInvalidos(e.mensaje),
        _ when e is DatosInvalidos => EstrenoDatosInvalidos(e.mensaje),
        _ => const EstrenoNoDisponible(),
      };
    }
  }

  static MensualidadEstimada _mensualidad(CotizacionEstreno c) =>
      MensualidadEstimada(
        precio: c.precio,
        enganche: c.enganche,
        montoFinanciado: c.montoFinanciado,
        tasaAnual: c.tasaAnual,
        plazoMeses: c.plazoMeses,
        mensualidad: c.mensualidad,
        leyenda: c.leyenda,
      );

  static SolicitudDeEstreno _solicitud(SolicitudEstreno s) =>
      SolicitudDeEstreno(
        id: s.id,
        tipo: s.tipo == 'COTIZACION'
            ? TipoSolicitud.cotizacion
            : TipoSolicitud.pruebaManejo,
        modelo: s.modelo,
        estado: switch (s.estado) {
          'EN_ATENCION' => EstadoSolicitud.enAtencion,
          'CERRADA' => EstadoSolicitud.cerrada,
          _ => EstadoSolicitud.recibida,
        },
        creadaEn: s.creadaEn,
        vendedor: s.vendedor,
        fecha: s.preferenciaFecha,
        franja: switch (s.preferenciaFranja) {
          'MANANA' => FranjaPreferida.manana,
          'TARDE' => FranjaPreferida.tarde,
          _ => null,
        },
        cotizacion: s.cotizacion == null ? null : _mensualidad(s.cotizacion!),
      );
}
