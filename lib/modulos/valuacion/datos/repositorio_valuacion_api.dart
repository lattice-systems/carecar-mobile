import '../../../api/excepciones.dart';
import '../../../api/modelos/comun.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/repositorio_valuacion.dart';
import '../dominio/valuacion.dart';
import 'lectura_valuacion.dart';

/// Las rutas `Valuación` del contrato con el cliente del nucleo. Las
/// excepciones de la API pasan tal cual: solo se traducen, por su codigo, los
/// rechazos que las pantallas explican.
class RepositorioValuacionApi implements RepositorioValuacion {
  const RepositorioValuacionApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaValuacion();

  @override
  Future<Valuacion> pedir(int estimacionId) => _traduciendo(
    () => _cliente.enviar(
      '/valuaciones',
      cuerpo: {'estimacionTomaCuentaId': estimacionId},
      leer: _lectura.valuacion,
    ),
  );

  @override
  Future<PaginaDeValuaciones> listar({int pagina = 0, int tamano = 20}) async {
    final p = await _cliente.obtenerPagina(
      '/valuaciones',
      _lectura.valuacion,
      pagina: pagina,
      tamano: tamano,
    );
    return PaginaDeValuaciones(
      valuaciones: p.contenido,
      pagina: p.pagina,
      hayMas: p.hayMas,
    );
  }

  @override
  Future<Valuacion> una(int valuacionId) =>
      _cliente.obtener('/valuaciones/$valuacionId', _lectura.valuacion);

  @override
  Future<Valuacion> subirFoto({
    required int valuacionId,
    required TomaValuacion toma,
    required List<int> bytes,
    required String tipo,
  }) => _traduciendo(
    () => _cliente.enviarArchivo(
      '/valuaciones/$valuacionId/fotos/${tomasEnElContrato[toma]}',
      campos: const {},
      nombreArchivo: 'imagen',
      bytes: bytes,
      tipo: tipo,
      leer: _lectura.valuacion,
    ),
  );

  @override
  Future<InspeccionValuacion> agendar({
    required int valuacionId,
    required int franjaId,
    required DateTime fecha,
  }) => _traduciendo(
    () => _cliente.enviar(
      '/valuaciones/$valuacionId/cita',
      cuerpo: {'franjaId': franjaId, 'fecha': escribirFecha(fecha)},
      leer: _lectura.cita,
    ),
  );

  @override
  Future<Valuacion> responder({
    required int valuacionId,
    required bool aceptada,
    required double monto,
  }) => _traduciendo(
    () => _cliente.enviar(
      '/valuaciones/$valuacionId/respuesta',
      cuerpo: {'aceptada': aceptada, 'monto': monto},
      leer: _lectura.valuacion,
    ),
  );

  @override
  Future<List<PuntoValorEstimado>> valorEstimado(
    int vehiculoId, {
    int meses = 12,
  }) => _cliente.obtener(
    '/vehiculos/$vehiculoId/valor-estimado',
    _lectura.valorEstimado,
    consulta: {'meses': '$meses'},
  );

  Future<T> _traduciendo<T>(Future<T> Function() pedir) async {
    try {
      return await pedir();
    } on Conflicto catch (e) {
      throw _rechazo(e) ?? e;
    } on SolicitudRechazada catch (e) {
      throw _rechazo(e) ?? e;
    }
  }

  static ValuacionRechazada? _rechazo(ExcepcionApi error) {
    final motivo = switch (error.problema?.codigo) {
      CodigoProblema.valuacionSinVehiculo => MotivoRechazoValuacion.sinVehiculo,
      CodigoProblema.valuacionCerrada => MotivoRechazoValuacion.cerrada,
      CodigoProblema.valuacionNoAgendable => MotivoRechazoValuacion.noAgendable,
      CodigoProblema.franjaSinCupo => MotivoRechazoValuacion.sinCupo,
      CodigoProblema.citaDuplicada => MotivoRechazoValuacion.citaDuplicada,
      CodigoProblema.ofertaVencida => MotivoRechazoValuacion.ofertaVencida,
      CodigoProblema.ofertaNoDisponible =>
        MotivoRechazoValuacion.ofertaNoDisponible,
      _ => null,
    };
    return motivo == null ? null : ValuacionRechazada(motivo);
  }
}
