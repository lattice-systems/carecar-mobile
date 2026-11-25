import 'dart:typed_data';

import 'carecar_api.dart';
import 'cliente_api.dart';
import 'modelos/comun.dart';
import 'modelos/modelos.dart';

/// Implementacion de [CarecarApi] sobre HTTP.
///
/// Sirve igual contra la API simulada de `mock_api/` y contra la API real: la
/// diferencia esta en la direccion que recibe `ClienteApi`, no aqui.
class CarecarApiHttp implements CarecarApi {
  const CarecarApiHttp(this._cliente);

  final ClienteApi _cliente;

  @override
  Future<RespuestaLogin> iniciarSesion(PeticionLogin peticion) =>
      _cliente.enviar(
        '/auth/login',
        cuerpo: peticion.toJson(),
        leer: RespuestaLogin.fromJson,
      );

  @override
  Future<RespuestaLogin> refrescar(String refreshToken) => _cliente.enviar(
    '/auth/refrescar',
    cuerpo: {'refreshToken': refreshToken},
    leer: RespuestaLogin.fromJson,
    // Ruta publica: sin Bearer y sin reintento con sesion renovada. Si esta
    // responde 401, es que la sesion termino y no hay nada mas que intentar.
    conToken: false,
  );

  @override
  Future<void> cerrarSesion(String refreshToken) => _cliente.enviarSinRespuesta(
    '/auth/cerrar-sesion',
    cuerpo: {'refreshToken': refreshToken},
    conToken: false,
  );

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => _cliente.enviarSinRespuesta(
    '/auth/cambiar-contrasena',
    cuerpo: {'contrasenaActual': actual, 'contrasenaNueva': nueva},
  );

  @override
  Future<void> recuperarContrasena(String correo) =>
      _cliente.enviarSinRespuesta(
        '/auth/recuperar-contrasena',
        cuerpo: {'correo': correo.trim()},
      );

  @override
  Future<void> restablecerContrasena(PeticionRestablecer peticion) =>
      _cliente.enviarSinRespuesta(
        '/auth/restablecer-contrasena',
        cuerpo: peticion.toJson(),
      );

  @override
  Future<Perfil> miPerfil() => _cliente.obtener('/perfil', Perfil.fromJson);

  @override
  Future<List<Vehiculo>> misVehiculos() =>
      _cliente.obtenerLista('/vehiculos', Vehiculo.fromJson);

  @override
  Future<List<Manual>> manualesDe(int vehiculoId) =>
      _cliente.obtenerLista('/vehiculos/$vehiculoId/manuales', Manual.fromJson);

  @override
  Future<List<Servicio>> serviciosDe(int vehiculoId) => _cliente.obtenerLista(
    '/vehiculos/$vehiculoId/servicios',
    Servicio.fromJson,
  );

  @override
  Future<Pagina<Servicio>> paginaDeServicios(
    int vehiculoId, {
    int pagina = 0,
    int tamano = 20,
    int? anio,
  }) => _cliente.obtenerPagina(
    '/vehiculos/$vehiculoId/servicios',
    Servicio.fromJson,
    pagina: pagina,
    tamano: tamano,
    consulta: {'anio': anio?.toString()},
  );

  @override
  Future<List<int>> aniosDeServicios(int vehiculoId) =>
      _cliente.obtenerEnteros('/vehiculos/$vehiculoId/servicios/anios');

  @override
  Future<ServicioDetalle> detalleDeServicio(int servicioId) =>
      _cliente.obtener('/servicios/$servicioId', ServicioDetalle.fromJson);

  @override
  Future<Uint8List> ticketDe(int servicioId) =>
      _cliente.descargar('/servicios/$servicioId/ticket');

  @override
  Future<Uint8List> ticketDeCita(int citaId) =>
      _cliente.descargar('/citas/$citaId/ticket');

  @override
  Future<ComprobanteCita> comprobanteDeCita(int citaId) =>
      _cliente.obtener('/citas/$citaId/comprobante', ComprobanteCita.fromJson);

  @override
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) => _cliente.obtenerLista(
    '/agenda/disponibilidad',
    Disponibilidad.fromJson,
    consulta: {'desde': escribirFecha(desde), 'hasta': escribirFecha(hasta)},
  );

  @override
  Future<List<Cita>> misCitas() =>
      _cliente.obtenerLista('/citas', Cita.fromJson);

  @override
  Future<Pagina<Cita>> paginaDeCitas({int pagina = 0, int tamano = 20}) =>
      _cliente.obtenerPagina(
        '/citas',
        Cita.fromJson,
        pagina: pagina,
        tamano: tamano,
      );

  @override
  Future<RespuestaAsistente> preguntarAlAsistente({
    required int vehiculoId,
    required String pregunta,
  }) => _cliente.enviar(
    '/asistente/preguntas',
    cuerpo: {'vehiculoId': vehiculoId, 'pregunta': pregunta},
    leer: RespuestaAsistente.fromJson,
  );

  @override
  Stream<EventoAsistente> preguntarAlAsistenteEnFlujo({
    required int vehiculoId,
    required String pregunta,
  }) => _cliente
      .enviarFlujo(
        '/asistente/preguntas/flujo',
        cuerpo: {'vehiculoId': vehiculoId, 'pregunta': pregunta},
      )
      .map(
        (e) => switch (e.evento) {
          'texto' => TrozoAsistente(
            ((e.datos as Map<String, Object?>?)?['texto'] as String?) ?? '',
          ),
          'fin' => FinAsistente(
            RespuestaAsistente.fromJson(e.datos! as Map<String, Object?>),
          ),
          _ => ErrorAsistenteEnFlujo(
            (e.datos as Map<String, Object?>?)?['codigo'] as String?,
          ),
        },
      );

  @override
  Future<TestigoAsistente> identificarTestigo({
    required int vehiculoId,
    required List<int> imagen,
    required String tipo,
  }) => _cliente.enviarArchivo(
    '/asistente/testigos',
    campos: {'vehiculoId': '$vehiculoId'},
    nombreArchivo: 'imagen',
    bytes: imagen,
    tipo: tipo,
    leer: TestigoAsistente.fromJson,
  );

  @override
  Future<void> calificarRespuestaDelAsistente({
    required int consultaId,
    required bool util,
  }) => _cliente.enviarSinRespuesta(
    '/asistente/consultas/$consultaId/calificacion',
    cuerpo: {'util': util},
  );

  @override
  Future<Cita> agendarCita(NuevaCita nueva) =>
      _cliente.enviar('/citas', cuerpo: nueva.toJson(), leer: Cita.fromJson);

  @override
  Future<Cita> cancelarCita(int citaId) => _cliente.enviar(
    '/citas/$citaId/cancelar',
    cuerpo: null,
    leer: Cita.fromJson,
  );

  @override
  Future<Cita> reprogramarCita(
    int citaId, {
    required int franjaId,
    required DateTime fecha,
  }) => _cliente.enviar(
    '/citas/$citaId/reprogramar',
    cuerpo: {'franjaId': franjaId, 'fecha': escribirFecha(fecha)},
    leer: Cita.fromJson,
  );

  @override
  Future<List<ModeloCatalogo>> catalogo() =>
      _cliente.obtenerLista('/catalogo', ModeloCatalogo.fromJson);

  @override
  Future<DetalleModeloCatalogo> detalleModelo(int id) =>
      _cliente.obtener('/catalogo/$id', DetalleModeloCatalogo.fromJson);

  @override
  Future<EstimacionTomaCuenta> estimarTomaACuenta(
    NuevaEstimacionTomaCuenta nueva,
  ) => _cliente.enviar(
    '/toma-a-cuenta/estimaciones',
    cuerpo: nueva.toJson(),
    leer: EstimacionTomaCuenta.fromJson,
  );

  @override
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  }) => _cliente.obtenerPagina(
    '/toma-a-cuenta/estimaciones',
    EstimacionTomaCuenta.fromJson,
    pagina: pagina,
    tamano: tamano,
  );

  @override
  Future<CotizacionEstreno> calcularMensualidad({
    required int modeloCatalogoId,
    required double enganche,
    required int plazoMeses,
  }) => _cliente.enviar(
    '/estreno/cotizaciones/calculo',
    cuerpo: {
      'modeloCatalogoId': modeloCatalogoId,
      'enganche': enganche,
      'plazoMeses': plazoMeses,
    },
    leer: CotizacionEstreno.fromJson,
  );

  @override
  Future<SolicitudEstreno> crearSolicitudEstreno(NuevaSolicitudEstreno nueva) =>
      _cliente.enviar(
        '/estreno/solicitudes',
        cuerpo: nueva.toJson(),
        leer: SolicitudEstreno.fromJson,
      );

  @override
  Future<Pagina<SolicitudEstreno>> paginaDeSolicitudesEstreno({
    int pagina = 0,
    int tamano = 20,
  }) => _cliente.obtenerPagina(
    '/estreno/solicitudes',
    SolicitudEstreno.fromJson,
    pagina: pagina,
    tamano: tamano,
  );
}
