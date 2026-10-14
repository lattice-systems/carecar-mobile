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
        cuerpo: {'correo': correo},
      );

  @override
  Future<void> restablecerContrasena({
    required String token,
    required String contrasenaNueva,
  }) => _cliente.enviarSinRespuesta(
    '/auth/restablecer-contrasena',
    cuerpo: {'token': token, 'contrasenaNueva': contrasenaNueva},
  );

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
  Future<Uint8List> ticketDe(int servicioId) =>
      _cliente.descargar('/servicios/$servicioId/ticket');

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
  Future<Cita> agendarCita(NuevaCita nueva) =>
      _cliente.enviar('/citas', cuerpo: nueva.toJson(), leer: Cita.fromJson);

  @override
  Future<Cita> cancelarCita(int citaId) => _cliente.enviar(
    '/citas/$citaId/cancelar',
    cuerpo: null,
    leer: Cita.fromJson,
  );

  @override
  Future<List<ModeloCatalogo>> catalogo() =>
      _cliente.obtenerLista('/catalogo', ModeloCatalogo.fromJson);
}
