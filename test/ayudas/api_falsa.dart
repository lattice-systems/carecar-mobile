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

  /// Atajo: el login falla con la excepcion que se le pase.
  static ApiFalsa queFalla(ExcepcionApi error) =>
      ApiFalsa(alIniciarSesion: (_) async => throw error);

  /// Atajo: el login responde con una contrasena temporal.
  static ApiFalsa conContrasenaTemporal() => ApiFalsa(
    alIniciarSesion: (_) async => const RespuestaLogin(
      accessToken: 'token.temporal.firmado',
      debeCambiarContrasena: true,
    ),
  );

  /// Atajo: el login tarda hasta que se complete el futuro que devuelve.
  static ApiFalsa queTarda(Future<void> espera) => ApiFalsa(
    alIniciarSesion: (_) async {
      await espera;
      return const RespuestaLogin(
        accessToken: 'token.lento.firmado',
        debeCambiarContrasena: false,
      );
    },
  );

  @override
  Future<RespuestaLogin> iniciarSesion(PeticionLogin peticion) async {
    llamadasAlLogin++;
    ultimaPeticion = peticion;

    if (alIniciarSesion != null) return alIniciarSesion!(peticion);

    return const RespuestaLogin(
      accessToken: 'token.valido.firmado',
      debeCambiarContrasena: false,
    );
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
  Future<List<Vehiculo>> misVehiculos() => throw UnimplementedError('APP-3.1');

  @override
  Future<List<Manual>> manualesDe(int vehiculoId) =>
      throw UnimplementedError('ADM-1');

  @override
  Future<List<Servicio>> serviciosDe(int vehiculoId) =>
      throw UnimplementedError('APP-3.2');

  @override
  Future<Uint8List> ticketDe(int servicioId) =>
      throw UnimplementedError('APP-3.2');

  @override
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) => throw UnimplementedError('APP-3.3');

  @override
  Future<List<Cita>> misCitas() => throw UnimplementedError('APP-3.3');

  @override
  Future<Cita> agendarCita(NuevaCita nueva) =>
      throw UnimplementedError('APP-3.3');

  @override
  Future<Cita> cancelarCita(int citaId) => throw UnimplementedError('APP-3.3');

  @override
  Future<List<ModeloCatalogo>> catalogo() =>
      throw UnimplementedError('APP-4.1');
}
