import 'dart:typed_data';

import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';

/// Implementacion de [CarecarApi] para las pruebas.
///
/// Que exista con tan poco codigo es la prueba de que la frontera de TEC-5
/// funciona: sustituir toda la API es implementar una interfaz, sin tocar las
/// pantallas ni levantar un servidor.
class ApiFalsa implements CarecarApi {
  ApiFalsa({this.alIniciarSesion});

  /// Que hace el login. Si es nulo, responde una sesion valida.
  Future<RespuestaLogin> Function(PeticionLogin)? alIniciarSesion;

  /// Lo que se recibio en la ultima llamada a [iniciarSesion].
  PeticionLogin? ultimaPeticion;

  int llamadasAlLogin = 0;

  /// Arma una respuesta de login con los cuatro campos de la v1.1.
  ///
  /// Existe para que agregar un campo al contrato se arregle en un solo lugar,
  /// que es lo que no pasaba antes de la v1.1.
  static RespuestaLogin respuesta({
    String accessToken = 'token.valido.firmado',
    int expiresIn = 3600,
    String refreshToken = 'refresco.valido',
    bool debeCambiarContrasena = false,
  }) => RespuestaLogin(
    accessToken: accessToken,
    expiresIn: expiresIn,
    refreshToken: refreshToken,
    debeCambiarContrasena: debeCambiarContrasena,
  );

  /// Atajo: el login falla con la excepcion que se le pase.
  static ApiFalsa queFalla(ExcepcionApi error) =>
      ApiFalsa(alIniciarSesion: (_) async => throw error);

  /// Atajo: el login responde con una contrasena temporal.
  static ApiFalsa conContrasenaTemporal() => ApiFalsa(
    alIniciarSesion: (_) async => respuesta(
      accessToken: 'token.temporal.firmado',
      debeCambiarContrasena: true,
    ),
  );

  /// Atajo: el login tarda hasta que se complete el futuro que devuelve.
  static ApiFalsa queTarda(Future<void> espera) => ApiFalsa(
    alIniciarSesion: (_) async {
      await espera;
      return respuesta(accessToken: 'token.lento.firmado');
    },
  );

  @override
  Future<RespuestaLogin> iniciarSesion(PeticionLogin peticion) async {
    llamadasAlLogin++;
    ultimaPeticion = peticion;

    if (alIniciarSesion != null) return alIniciarSesion!(peticion);

    return respuesta();
  }

  // --- La sesion con refresco · TEC-6 T4 ---

  /// Que hace el refresco. Si es nulo, devuelve un par nuevo.
  Future<RespuestaLogin> Function(String refreshToken)? alRefrescar;

  /// Los refresh tokens que se mandaron a refrescar, en orden.
  final refrescosPedidos = <String>[];

  /// Los refresh tokens que se mandaron a revocar, en orden.
  final cierresPedidos = <String>[];

  @override
  Future<RespuestaLogin> refrescar(String refreshToken) async {
    refrescosPedidos.add(refreshToken);
    if (alRefrescar != null) return alRefrescar!(refreshToken);

    // Por omision el par rota, igual que en el contrato: el refresh es de un
    // solo uso y cada respuesta trae uno nuevo.
    return respuesta(
      accessToken: 'token.renovado.firmado',
      refreshToken: 'refresco.renovado',
    );
  }

  @override
  Future<void> cerrarSesion(String refreshToken) async {
    cierresPedidos.add(refreshToken);
  }

  // El resto de las operaciones no las usa APP-2.1. Llegan en S2 y S4.

  // --- APP-2.3 ---

  /// Que hace el cambio de contrasena. Si es nulo, responde bien.
  Future<void> Function(String actual, String nueva)? alCambiarContrasena;

  /// Que hace el envio del codigo. Si es nulo, responde bien.
  Future<void> Function(String correo)? alRecuperarContrasena;

  /// Que hace el restablecimiento. Si es nulo, responde bien.
  Future<void> Function(PeticionRestablecer)? alRestablecerContrasena;

  String? ultimaActual;
  String? ultimaNueva;
  String? ultimoCorreoDeRecuperacion;
  PeticionRestablecer? ultimoRestablecimiento;
  int llamadasAlRecuperar = 0;

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) async {
    ultimaActual = actual;
    ultimaNueva = nueva;
    if (alCambiarContrasena != null) return alCambiarContrasena!(actual, nueva);
  }

  @override
  Future<void> recuperarContrasena(String correo) async {
    llamadasAlRecuperar++;
    ultimoCorreoDeRecuperacion = correo;
    if (alRecuperarContrasena != null) return alRecuperarContrasena!(correo);
  }

  @override
  Future<void> restablecerContrasena(PeticionRestablecer peticion) async {
    ultimoRestablecimiento = peticion;
    if (alRestablecerContrasena != null) {
      return alRestablecerContrasena!(peticion);
    }
  }

  @override
  Future<List<Vehiculo>> misVehiculos() async {
    llamadasAVehiculos++;
    return alPedirVehiculos == null ? [] : alPedirVehiculos!();
  }

  Future<List<Vehiculo>> Function()? alPedirVehiculos;
  int llamadasAVehiculos = 0;

  @override
  Future<Perfil> miPerfil() async {
    llamadasAPerfil++;
    return alPedirPerfil == null
        ? const Perfil(
            id: 1,
            nombre: 'María Robles',
            correo: 'cliente1@example.com',
          )
        : alPedirPerfil!();
  }

  Future<Perfil> Function()? alPedirPerfil;
  int llamadasAPerfil = 0;

  /// Que responde `GET /vehiculos/{id}/manuales`. Si es nulo, una lista vacia.
  Future<List<Manual>> Function(int)? alPedirManuales;

  @override
  Future<List<Manual>> manualesDe(int vehiculoId) =>
      alPedirManuales?.call(vehiculoId) ?? Future.value(const []);

  /// Que responde `GET /vehiculos/{id}/servicios`. Si es nulo, una lista vacia.
  Future<List<Servicio>> Function(int)? alPedirServicios;

  @override
  Future<List<Servicio>> serviciosDe(int vehiculoId) =>
      alPedirServicios?.call(vehiculoId) ?? Future.value(const []);

  @override
  Future<Pagina<Servicio>> paginaDeServicios(
    int vehiculoId, {
    int pagina = 0,
    int tamano = 20,
  }) async => _rebanar(await serviciosDe(vehiculoId), pagina, tamano);

  @override
  Future<Uint8List> ticketDe(int servicioId) =>
      throw UnimplementedError('APP-3.2');

  /// Que responde `GET /citas/{id}/ticket`. Si es nulo, un PDF minimo.
  Future<Uint8List> Function(int citaId)? alPedirTicketDeCita;

  final ticketsDeCitaPedidos = <int>[];

  @override
  Future<Uint8List> ticketDeCita(int citaId) {
    ticketsDeCitaPedidos.add(citaId);
    return alPedirTicketDeCita?.call(citaId) ??
        Future.value(Uint8List.fromList('%PDF-1.4\n%%EOF\n'.codeUnits));
  }

  /// Que responde `GET /citas/{id}/comprobante`. Si es nulo, uno de ejemplo.
  Future<ComprobanteCita> Function(int citaId)? alPedirComprobanteDeCita;

  final comprobantesDeCitaPedidos = <int>[];

  @override
  Future<ComprobanteCita> comprobanteDeCita(int citaId) {
    comprobantesDeCitaPedidos.add(citaId);
    return alPedirComprobanteDeCita?.call(citaId) ??
        Future.value(
          ComprobanteCita(
            citaId: citaId,
            codigo: 'CC1.$citaId.firma',
            fecha: DateTime(2026, 11, 24),
            horaInicio: '09:00',
            horaFin: '10:00',
          ),
        );
  }

  // --- Agenda · APP-3.3 ---

  /// Que responde `GET /citas`. Si es nulo, una lista vacia.
  Future<List<Cita>> Function()? alPedirCitas;

  /// Que responde `GET /agenda/disponibilidad`. Si es nulo, sin franjas.
  Future<List<Disponibilidad>> Function(DateTime desde, DateTime hasta)?
  alPedirDisponibilidad;

  /// Que hace `POST /citas`. Si es nulo, la cita queda confirmada.
  Future<Cita> Function(NuevaCita)? alAgendar;

  /// Que hace `POST /citas/{id}/cancelar`. Si es nulo, la cita queda cancelada.
  Future<Cita> Function(int citaId)? alCancelar;

  final citasAgendadas = <NuevaCita>[];
  final citasCanceladas = <int>[];
  int llamadasACitas = 0;
  int llamadasADisponibilidad = 0;

  @override
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) {
    llamadasADisponibilidad++;
    return alPedirDisponibilidad?.call(desde, hasta) ?? Future.value(const []);
  }

  @override
  Future<List<Cita>> misCitas() {
    llamadasACitas++;
    return alPedirCitas?.call() ?? Future.value(const []);
  }

  @override
  Future<Pagina<Cita>> paginaDeCitas({int pagina = 0, int tamano = 20}) async =>
      _rebanar(await misCitas(), pagina, tamano);

  static Pagina<T> _rebanar<T>(List<T> todo, int pagina, int tamano) {
    final inicio = (pagina * tamano).clamp(0, todo.length);
    final fin = (inicio + tamano).clamp(0, todo.length);
    return Pagina(
      contenido: todo.sublist(inicio, fin),
      pagina: pagina,
      totalPaginas: todo.isEmpty ? 0 : (todo.length / tamano).ceil(),
    );
  }

  @override
  Future<Cita> agendarCita(NuevaCita nueva) {
    citasAgendadas.add(nueva);
    return alAgendar?.call(nueva) ??
        Future.value(
          Cita(
            id: 99,
            vehiculoId: nueva.vehiculoId,
            fecha: nueva.fecha,
            horaInicio: '09:00',
            horaFin: '10:00',
            estado: EstadoCita.confirmada,
          ),
        );
  }

  @override
  Future<Cita> cancelarCita(int citaId) {
    citasCanceladas.add(citaId);
    return alCancelar?.call(citaId) ??
        Future.value(
          Cita(
            id: citaId,
            vehiculoId: 0,
            fecha: DateTime(2026),
            horaInicio: '09:00',
            horaFin: '10:00',
            estado: EstadoCita.cancelada,
          ),
        );
  }

  /// Que hace `POST /citas/{id}/reprogramar`. Si es nulo, la cita queda
  /// confirmada en la franja pedida.
  Future<Cita> Function(int citaId, int franjaId, DateTime fecha)?
  alReprogramar;

  final citasReprogramadas = <({int citaId, int franjaId, DateTime fecha})>[];

  @override
  Future<Cita> reprogramarCita(
    int citaId, {
    required int franjaId,
    required DateTime fecha,
  }) {
    citasReprogramadas.add((citaId: citaId, franjaId: franjaId, fecha: fecha));
    return alReprogramar?.call(citaId, franjaId, fecha) ??
        Future.value(
          Cita(
            id: citaId,
            vehiculoId: 0,
            franjaId: franjaId,
            fecha: fecha,
            horaInicio: '09:00',
            horaFin: '10:00',
            estado: EstadoCita.confirmada,
          ),
        );
  }

  @override
  Future<List<ModeloCatalogo>> catalogo() async => modelosCatalogo;

  List<ModeloCatalogo> modelosCatalogo = const [];

  /// Detalle por id. Un id que no esta aqui responde `NoEncontrado`.
  Map<int, DetalleModeloCatalogo> detallesCatalogo = {};

  @override
  Future<DetalleModeloCatalogo> detalleModelo(int id) async =>
      detallesCatalogo[id] ?? (throw const NoEncontrado('No existe el modelo'));

  /// Que hace `POST /toma-a-cuenta/estimaciones`. Si es nulo, calcula una
  /// estimacion fija de 100,000 a 120,000.
  Future<EstimacionTomaCuenta> Function(NuevaEstimacionTomaCuenta)? alEstimar;

  final estimacionesPedidas = <NuevaEstimacionTomaCuenta>[];

  /// Que responde `GET /toma-a-cuenta/estimaciones`.
  List<EstimacionTomaCuenta> estimaciones = const [];

  @override
  Future<EstimacionTomaCuenta> estimarTomaACuenta(
    NuevaEstimacionTomaCuenta nueva,
  ) {
    estimacionesPedidas.add(nueva);
    return alEstimar?.call(nueva) ??
        Future.value(
          EstimacionTomaCuenta(
            id: 1,
            creadaEn: DateTime.utc(2026, 11, 22),
            vehiculoId: nueva.vehiculoId,
            marca: nueva.marca ?? 'Nissan',
            modelo: nueva.modelo ?? 'Versa',
            anio: nueva.anio ?? 2021,
            km: nueva.km,
            estado: nueva.estado,
            modeloCatalogoId: nueva.modeloCatalogoId,
            minimo: 100000,
            maximo: 120000,
            supuestos: const SupuestosEstimacion(
              valorBase: 200000,
              edadAnios: 5,
              kmEsperado: 75000,
              ajusteKm: 1,
              ajusteEstado: 1,
              margen: 0.08,
            ),
          ),
        );
  }

  @override
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  }) async => _rebanar(estimaciones, pagina, tamano);
}
