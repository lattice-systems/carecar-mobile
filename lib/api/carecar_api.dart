import 'dart:typed_data';

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

  // --- Vehiculos · APP-3.1 y ADM-1 ---

  /// `GET /vehiculos`. Solo los del cliente de la sesion.
  Future<List<Vehiculo>> misVehiculos();

  /// `GET /vehiculos/{id}/manuales`. Puede venir vacia (ADM-1 esta fuera del MVP).
  Future<List<Manual>> manualesDe(int vehiculoId);

  // --- Servicios y tickets · APP-3.2 ---

  /// `GET /vehiculos/{id}/servicios`, del mas reciente al mas antiguo.
  Future<List<Servicio>> serviciosDe(int vehiculoId);

  /// `GET /vehiculos/{id}/servicios?pagina=&tamano=`, una pagina.
  Future<Pagina<Servicio>> paginaDeServicios(
    int vehiculoId, {
    int pagina = 0,
    int tamano = 20,
  });

  /// `GET /servicios/{id}/ticket`. Devuelve los bytes del PDF.
  Future<Uint8List> ticketDe(int servicioId);

  /// `GET /citas/{citaId}/ticket`. Devuelve los bytes del PDF.
  Future<Uint8List> ticketDeCita(int citaId);

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

  /// `POST /citas`. Lanza `Conflicto` si la franja ya no tiene cupo.
  Future<Cita> agendarCita(NuevaCita nueva);

  /// `POST /citas/{id}/cancelar`.
  ///
  /// Lanza `Conflicto` si ya no esta confirmada o si quedo fuera del plazo.
  /// Cual es ese plazo sigue pendiente del PO (pregunta PO-4).
  Future<Cita> cancelarCita(int citaId);

  // --- Catalogo · APP-4.1 (fuera del MVP) ---

  /// `GET /catalogo`. Solo los modelos vigentes.
  Future<List<ModeloCatalogo>> catalogo();

  /// `GET /catalogo/{id}`. El modelo con galeria, versiones y ficha resumida.
  ///
  /// Lanza `NoEncontrado` si no existe o ya esta retirado.
  Future<DetalleModeloCatalogo> detalleModelo(int id);

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
}
