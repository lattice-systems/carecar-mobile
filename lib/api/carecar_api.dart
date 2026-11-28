import 'dart:typed_data';

import 'modelos/preferencias_notificacion.dart';
import 'modelos/notificacion.dart';
import 'modelos/modelos.dart';

/// Lo que la app puede pedirle a Agencia360.
///
/// **Esta es la frontera de TEC-5.** Las pantallas dependen de esta interfaz y
/// nunca de HTTP, de `ClienteApi` ni de la direccion del servidor. Por eso
/// cambiar de la API simulada a la real no obliga a rehacer pantallas: se
/// cambia la implementacion, no la interfaz.
///
/// Las operaciones son las del contrato `api/agencia360-api-app-v1.yaml`.
/// La prueba de contrato falla si el contrato gana o pierde alguna.
///
/// Todos los metodos lanzan subclases de `ExcepcionApi`:
/// `SinConexion`, `CredencialesInvalidas`, `CuentaDesactivada`,
/// `NoEncontrado`, `DatosInvalidos`, `Conflicto`, `ErrorDelServidor` y
/// `RespuestaInvalida`.
abstract interface class CarecarApi {
  // --- Acceso · APP-2.1 y APP-2.3 ---

  /// `POST /auth/login`. No existe registro publico.
  ///
  /// Lanza `CredencialesInvalidas` con 401 y `CuentaDesactivada` con 403.
  /// Si la respuesta trae `debeCambiarContrasena` en `true`, la app debe
  /// forzar el cambio.
  Future<RespuestaLogin> iniciarSesion(PeticionLogin peticion);

  /// `POST /auth/refrescar`. Cambia el refresh token por un par nuevo.
  ///
  /// Es publica: no lleva el access token, para que funcione aunque ya haya
  /// expirado. El refresh **se gasta al usarlo** (RIC-2), asi que la respuesta
  /// trae uno nuevo y hay que guardar siempre el ultimo.
  ///
  /// Lanza `CredencialesInvalidas` con 401, que aqui significa **la sesion
  /// termino**: el refresh venció, ya se habia usado o lo revocaron. Lanza
  /// `CuentaDesactivada` con 403 (RIC-3).
  Future<RespuestaLogin> refrescar(String refreshToken);

  /// `POST /auth/cerrar-sesion`. Revoca ese refresh token.
  ///
  /// Tambien es publica, por lo mismo. **El access token sigue valido hasta que
  /// expire**: es el riesgo que el contrato acepta a cambio de no consultar una
  /// lista negra en cada peticion. La app borra los dos tokens de todos modos.
  Future<void> cerrarSesion(String refreshToken);

  /// `POST /auth/cambiar-contrasena`. Obligatorio en el primer ingreso.
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  });

  /// `POST /auth/recuperar-contrasena`.
  ///
  /// Responde igual exista o no el correo, para no revelar que cuentas hay.
  Future<void> recuperarContrasena(String correo);

  /// `POST /auth/restablecer-contrasena` con el codigo de 6 digitos.
  ///
  /// En la v1.1 ya no hay enlace de un solo uso (RIC-18). Un codigo invalido,
  /// usado o vencido responde **400 con `CODIGO_INVALIDO`**, que es el mismo
  /// codigo HTTP que una contrasena que no cumple las reglas: hay que
  /// distinguirlos por `Problema.codigo`.
  Future<void> restablecerContrasena(PeticionRestablecer peticion);

  /// `GET /perfil`. Informacion de solo lectura del cliente autenticado.
  Future<Perfil> miPerfil();

  /// `PATCH /perfil`: pide cambiar el correo · V2-M01.07.
  ///
  /// **No cambia nada todavia**: crea una verificacion y manda un codigo de 6
  /// digitos al correo nuevo. Guardarlo antes de confirmarlo dejaria al cliente
  /// con un correo que no ha probado que es suyo y, como `cuenta_app.usuario`
  /// lo sigue, sin poder entrar.
  ///
  /// Pide la contrasena actual porque el correo es la identidad con la que se
  /// entra. Si no coincide, lanza `DatosInvalidos` con codigo
  /// `CREDENCIALES_INVALIDAS` -400 y no 401, para que la app no lo lea como
  /// sesion vencida-. Un correo mal escrito llega igual como `DatosInvalidos`
  /// pero con `DATOS_INVALIDOS`, y uno que ya es de otro cliente como
  /// `Conflicto`.
  Future<VerificacionPendiente> pedirCambioDeCorreo({
    required String correo,
    required String contrasenaActual,
  });

  /// `POST /perfil/verificaciones/{id}/confirmar`: aplica el cambio · V2-M01.07.
  ///
  /// Devuelve el perfil ya actualizado, asi que quien llame no tiene que volver
  /// a pedirlo. El codigo vence a los 15 minutos y sirve una sola vez:
  /// equivocado, usado o vencido llegan igual, como `DatosInvalidos` con
  /// `CODIGO_INVALIDO`.
  Future<Perfil> confirmarVerificacion({
    required int id,
    required String codigo,
  });

  // --- Sesiones y dispositivos activos · V2-M01.09 ---

  /// `GET /sesiones`: las sesiones **vigentes** de la cuenta, ni revocadas ni
  /// vencidas.
  ///
  /// Vienen ordenadas por `ultimoUso` descendente y las que nunca se
  /// refrescaron al final. La app **no reordena**: si lo hiciera tendria que
  /// decidir que hacer con los nulos y acabaria discrepando del servidor.
  Future<List<SesionActiva>> misSesiones();

  /// `DELETE /sesiones/{id}`: revoca esa sesion.
  ///
  /// Idempotente: una sesion ya revocada responde 204 igual. Una sesion de otra
  /// cuenta lanza `NoEncontrado` (404, no 403), que es la regla del contrato
  /// para un recurso ajeno: un 403 revelaria que existe.
  Future<void> cerrarSesionActiva(int sesionId);

  /// `DELETE /sesiones`: revoca **todas** las sesiones de la cuenta, **incluida
  /// la de quien llama**. Es «cerrar sesión en todos los dispositivos».
  ///
  /// Igual que `cerrarSesion`, el access token en curso sigue valiendo hasta
  /// que expire, asi que quien llame tiene que cerrar la sesion local tambien.
  Future<void> cerrarTodasLasSesiones();

  // --- Vehiculos · APP-3.1 y ADM-1 ---

  /// `GET /vehiculos`. Solo los del cliente de la sesion.
  Future<List<Vehiculo>> misVehiculos();

  /// `GET /vehiculos/{id}/manuales`. Puede venir vacia (ADM-1 esta fuera del MVP).
  Future<List<Manual>> manualesDe(int vehiculoId);

  // --- Asistente · V2-M24.03 ---

  /// `POST /asistente/preguntas`. Respuesta con base en el manual del vehiculo.
  ///
  /// 409 `ASISTENTE_SIN_MANUAL`, 429 `ASISTENTE_LIMITE` y 503
  /// `ASISTENTE_NO_DISPONIBLE` llegan como `Conflicto`, `DemasiadosIntentos` y
  /// `ErrorDelServidor` con su `Problema.codigo`.
  Future<RespuestaAsistente> preguntarAlAsistente({
    required int vehiculoId,
    required String pregunta,
  });

  /// `POST /asistente/preguntas/flujo` (V2-M24.09): la respuesta mientras se
  /// escribe. Los errores de antes de empezar llegan como en
  /// [preguntarAlAsistente].
  Stream<EventoAsistente> preguntarAlAsistenteEnFlujo({
    required int vehiculoId,
    required String pregunta,
  });

  /// `POST /asistente/testigos` (V2-M24.05): identifica el testigo del tablero
  /// en una foto JPEG o PNG. Mismos errores que [preguntarAlAsistente], mas 400
  /// si no es una imagen.
  Future<TestigoAsistente> identificarTestigo({
    required int vehiculoId,
    required List<int> imagen,
    required String tipo,
  });

  /// `POST /asistente/consultas/{consultaId}/calificacion` (V2-M24.07): si la
  /// respuesta sirvio. 404 si la consulta no es del cliente.
  Future<void> calificarRespuestaDelAsistente({
    required int consultaId,
    required bool util,
  });

  // --- Servicios y tickets · APP-3.2 ---

  /// `GET /vehiculos/{id}/servicios`, del mas reciente al mas antiguo.
  Future<List<Servicio>> serviciosDe(int vehiculoId);

  /// `GET /vehiculos/{id}/servicios?anio=&pagina=&tamano=`, una pagina.
  /// `anio` nulo trae todos los años (V2-M02.05).
  Future<Pagina<Servicio>> paginaDeServicios(
    int vehiculoId, {
    int pagina = 0,
    int tamano = 20,
    int? anio,
  });

  /// `GET /vehiculos/{id}/servicios/anios`: años con servicios, del mas
  /// reciente al mas antiguo (V2-M02.05).
  Future<List<int>> aniosDeServicios(int vehiculoId);

  /// `GET /servicios/{id}`: el ticket con mano de obra y refacciones
  /// (V2-M02.06).
  Future<ServicioDetalle> detalleDeServicio(int servicioId);

  /// `GET /servicios/{id}/ticket`. Devuelve los bytes del PDF.
  Future<Uint8List> ticketDe(int servicioId);

  /// `GET /citas/{citaId}/ticket`. Devuelve los bytes del PDF.
  Future<Uint8List> ticketDeCita(int citaId);

  /// `GET /citas/{citaId}/comprobante` (V2-M02.11): el codigo firmado para el
  /// QR y los datos de la cita.
  Future<ComprobanteCita> comprobanteDeCita(int citaId);

  // --- Agenda · APP-3.3 ---

  /// `GET /agenda/disponibilidad`. Solo franjas con cupo.
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  });

  /// `GET /citas`. Solo las del cliente.
  Future<List<Cita>> misCitas();

  /// `GET /citas?pagina=&tamano=`, una pagina.
  Future<Pagina<Cita>> paginaDeCitas({int pagina = 0, int tamano = 20});

  /// La bandeja de avisos, del mas reciente · V2-M06.04.
  ///
  /// La pagina trae `noLeidas` de toda la cuenta, que es lo que la app pinta
  /// en el contador: asi no hace falta una segunda llamada en cada entrada.
  Future<PaginaDeNotificaciones> paginaDeNotificaciones({
    int pagina = 0,
    int tamano = 20,
  });

  /// Marca un aviso como leido. Idempotente: dos veces no mueve `leidaEn`.
  Future<void> marcarAvisoLeido(int notificacionId);

  /// Marca como leidos todos los que estuvieran sin leer.
  Future<void> marcarAvisosLeidos();

  /// Que avisos quiere recibir el cliente y su horario silencioso · V2-M06.05.
  ///
  /// Devuelve **todas** las categorias, tambien las que nunca toco, con su
  /// valor por omision: asi la app no tiene que saber cuales existen.
  Future<PreferenciasNotificacion> preferenciasDeAvisos();

  /// Reemplaza las preferencias completas y devuelve como quedaron.
  Future<PreferenciasNotificacion> guardarPreferenciasDeAvisos(
    PreferenciasNotificacion nuevas,
  );

  /// `POST /citas`. Lanza `Conflicto` si la franja ya no tiene cupo.
  Future<Cita> agendarCita(NuevaCita nueva);

  /// `POST /citas/{id}/cancelar`.
  ///
  /// Lanza `Conflicto` si ya no esta confirmada o si quedo fuera del plazo.
  /// Cual es ese plazo sigue pendiente del PO (pregunta PO-4).
  Future<Cita> cancelarCita(int citaId);

  /// `POST /citas/{id}/reprogramar` (propuesto en V2-M02.13; aun no esta en el
  /// contrato v1). Cambia la cita a otra franja y libera la anterior en la
  /// misma operacion.
  ///
  /// Lanza `Conflicto` con `FRANJA_SIN_CUPO` si la franja nueva se lleno, o sin
  /// codigo reconocido si la cita ya no esta confirmada o paso el plazo.
  Future<Cita> reprogramarCita(
    int citaId, {
    required int franjaId,
    required DateTime fecha,
  });

  // --- Catalogo · APP-4.1 (fuera del MVP) ---

  /// `GET /catalogo`. Solo los modelos vigentes.
  Future<List<ModeloCatalogo>> catalogo();

  /// `GET /catalogo/{id}`. El modelo con galeria, versiones y ficha resumida.
  ///
  /// Lanza `NoEncontrado` si no existe o ya esta retirado.
  Future<DetalleModeloCatalogo> detalleModelo(int id);

  // --- Sucursales · V2-M27.02 ---

  /// `GET /sucursales`. Las activas, la principal primero; puede venir vacia.
  ///
  /// `abiertaAhora` lo calcula el servidor con la hora de la agencia. Por eso
  /// la copia sin conexion no la guarda (ver `CarecarApiConCache`).
  Future<List<SucursalApi>> sucursales();

  // --- Toma a cuenta · V2-M03.04 y V2-M03.07 ---

  /// `POST /toma-a-cuenta/estimaciones`. Calcula el rango y lo guarda.
  ///
  /// Es una estimacion no vinculante, nunca una oferta. Lanza `NoEncontrado`
  /// si el vehiculo no es del cliente o el modelo ya no esta vigente,
  /// `DatosInvalidos` con datos fuera de rango y `SinParametrosDeValuacion`
  /// con 422 cuando la agencia aun no valua ese auto.
  Future<EstimacionTomaCuenta> estimarTomaACuenta(
    NuevaEstimacionTomaCuenta nueva,
  );

  /// `GET /toma-a-cuenta/estimaciones?pagina=&tamano=`, de la mas reciente a
  /// la mas antigua.
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  });

  // --- Estreno · V2-M16 ---

  /// `POST /estreno/cotizaciones/calculo`: mensualidad estimada, no guarda.
  /// 409 `ESTRENO_SIN_PRECIO`; 400 enganche o plazo no permitidos.
  Future<CotizacionEstreno> calcularMensualidad({
    required int modeloCatalogoId,
    required double enganche,
    required int plazoMeses,
  });

  /// `POST /estreno/solicitudes`: prueba de manejo o cotizacion.
  /// 409 `ESTRENO_DUPLICADA` o `ESTRENO_SIN_PRECIO`; 404 estimacion ajena.
  Future<SolicitudEstreno> crearSolicitudEstreno(NuevaSolicitudEstreno nueva);

  /// `GET /estreno/solicitudes`, mas recientes primero.
  Future<Pagina<SolicitudEstreno>> paginaDeSolicitudesEstreno({
    int pagina = 0,
    int tamano = 20,
  });

  // --- Privacidad · V2-M22.01 ---

  /// `GET /privacidad/aviso`: el aviso vigente y si esta cuenta ya lo acepto.
  Future<AvisoPrivacidad> avisoDePrivacidad();

  /// `POST /privacidad/aceptaciones`: registra que se leyo esa version. Es
  /// idempotente. 404 si el aviso no existe; 409 `AVISO_NO_VIGENTE` si ya hay
  /// una version mas nueva.
  Future<AceptacionAviso> aceptarAvisoDePrivacidad(int avisoId);

  // --- Derechos ARCO · V2-M22.02 ---

  /// `GET /privacidad/arco`: las ultimas solicitudes de esta cuenta, mas
  /// recientes primero.
  Future<List<SolicitudArco>> misSolicitudesArco();

  /// `POST /privacidad/arco/acceso`: pide una copia de mis datos. El archivo se
  /// prepara aparte; si ya habia una pendiente devuelve esa.
  Future<SolicitudArco> pedirAccesoArco();

  /// `GET /privacidad/arco/{id}/archivo`: el JSON con los datos. 404 si no es
  /// de esta cuenta, no esta lista o ya vencio.
  Future<Uint8List> descargarArchivoArco(int solicitudId);

  // --- Cancelacion de la cuenta · V2-M22.03 ---

  /// `POST /privacidad/arco/cancelacion`: borra mi cuenta. **No se puede
  /// deshacer.** La contrasena confirma que quien lo pide es el titular.
  ///
  /// Una contrasena equivocada es un 400 (`DatosInvalidos`), a proposito y no un
  /// 401: la app lee un 401 como sesion vencida y cerraria la sesion sin
  /// explicar nada. A los 5 intentos fallidos, `DemasiadosIntentos` (429) con el
  /// tiempo en `Retry-After`. Al terminar, cualquier token de la cuenta responde
  /// 403.
  Future<SolicitudArco> cancelarCuentaArco(String contrasena);
}
