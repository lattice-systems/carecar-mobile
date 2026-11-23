import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
import '../api/modelos/comun.dart';
import '../api/modelos/modelos.dart';

/// Decorador de [CarecarApi] que guarda la ultima respuesta buena de las
/// lecturas y la devuelve cuando no hay conexion.
///
/// Los demas metodos delegan sin cambio. La cache se limpia al cerrar sesion
/// y al iniciar una nueva, para que otro usuario nunca vea datos ajenos.
class CarecarApiConCache implements CarecarApi {
  CarecarApiConCache(this._api, this._prefs);

  static const _prefijo = 'cache_carecar_';

  final CarecarApi _api;
  final SharedPreferences _prefs;

  /// `true` cuando la ultima lectura salio de la copia guardada.
  final ValueNotifier<bool> sinConexion = ValueNotifier(false);

  Future<T> _leer<T>(
    String clave,
    Future<T> Function() pedir,
    Object? Function(T) aJson,
    T Function(Object?) deJson,
  ) async {
    try {
      final datos = await pedir();
      sinConexion.value = false;
      try {
        await _prefs.setString('$_prefijo$clave', jsonEncode(aJson(datos)));
      } catch (_) {
        // Si no se puede guardar, la lectura buena igual se entrega.
      }
      return datos;
    } on SinConexion {
      final guardado = _prefs.getString('$_prefijo$clave');
      if (guardado == null) rethrow;
      final T datos;
      try {
        datos = deJson(jsonDecode(guardado));
      } catch (_) {
        rethrow;
      }
      sinConexion.value = true;
      return datos;
    }
  }

  /// Borra todas las copias guardadas.
  Future<void> limpiar() async {
    for (final clave in _prefs.getKeys().where((k) => k.startsWith(_prefijo))) {
      await _prefs.remove(clave);
    }
    sinConexion.value = false;
  }

  static List<T> _lista<T>(Object? json, T Function(Map<String, Object?>) f) =>
      [for (final e in json! as List) f((e as Map).cast<String, Object?>())];

  @override
  Future<Perfil> miPerfil() => _leer<Perfil>(
    'perfil',
    _api.miPerfil,
    (p) => {'id': p.id, 'nombre': p.nombre, 'correo': p.correo},
    (j) => Perfil.fromJson((j! as Map).cast<String, Object?>()),
  );

  @override
  Future<List<Vehiculo>> misVehiculos() => _leer<List<Vehiculo>>(
    'vehiculos',
    _api.misVehiculos,
    (l) => [
      for (final v in l)
        {
          'id': v.id,
          'vin': v.vin,
          'modelo': v.modelo,
          'anio': v.anio,
          'placas': v.placas,
          'kilometraje': v.kilometraje,
          'marca': v.marca,
          'tipo': v.tipo,
          'version': v.version,
          'color': v.color,
        },
    ],
    (j) => _lista(j, Vehiculo.fromJson),
  );

  @override
  Future<List<Servicio>> serviciosDe(int vehiculoId) => _leer<List<Servicio>>(
    'servicios_$vehiculoId',
    () => _api.serviciosDe(vehiculoId),
    (l) => [
      for (final s in l)
        {
          'id': s.id,
          'fecha': escribirFecha(s.fecha),
          'estatus': s.estatus,
          'total': s.total,
        },
    ],
    (j) => _lista(j, Servicio.fromJson),
  );

  // Las pantallas piden por paginas: esas respuestas no se guardan en disco.
  @override
  Future<Pagina<Servicio>> paginaDeServicios(
    int vehiculoId, {
    int pagina = 0,
    int tamano = 20,
  }) => _api.paginaDeServicios(vehiculoId, pagina: pagina, tamano: tamano);

  @override
  Future<Pagina<Cita>> paginaDeCitas({int pagina = 0, int tamano = 20}) =>
      _api.paginaDeCitas(pagina: pagina, tamano: tamano);

  @override
  Future<List<Cita>> misCitas() => _leer<List<Cita>>(
    'citas',
    _api.misCitas,
    (l) => [
      for (final c in l)
        {
          'id': c.id,
          'vehiculoId': c.vehiculoId,
          'fecha': escribirFecha(c.fecha),
          'horaInicio': c.horaInicio,
          'horaFin': c.horaFin,
          'estado': c.estado.enElContrato,
        },
    ],
    (j) => _lista(j, Cita.fromJson),
  );

  // Estimar guarda en el servidor y no tiene sentido sin conexion, y las
  // listas por paginas no se guardan en disco.
  @override
  Future<EstimacionTomaCuenta> estimarTomaACuenta(
    NuevaEstimacionTomaCuenta nueva,
  ) => _api.estimarTomaACuenta(nueva);

  @override
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  }) => _api.paginaDeEstimaciones(pagina: pagina, tamano: tamano);

  @override
  Future<List<ModeloCatalogo>> catalogo() => _leer<List<ModeloCatalogo>>(
    'catalogo',
    _api.catalogo,
    (l) => [for (final m in l) m.toJson()],
    (j) => _lista(j, ModeloCatalogo.fromJson),
  );

  @override
  Future<DetalleModeloCatalogo> detalleModelo(int id) =>
      _leer<DetalleModeloCatalogo>(
        'catalogo_$id',
        () => _api.detalleModelo(id),
        (d) => d.toJson(),
        (j) =>
            DetalleModeloCatalogo.fromJson((j! as Map).cast<String, Object?>()),
      );

  // Sesion: al iniciar o cerrar se limpia la cache.

  @override
  Future<RespuestaLogin> iniciarSesion(PeticionLogin peticion) async {
    final r = await _api.iniciarSesion(peticion);
    await limpiar();
    return r;
  }

  @override
  Future<void> cerrarSesion(String refreshToken) async {
    try {
      await _api.cerrarSesion(refreshToken);
    } finally {
      await limpiar();
    }
  }

  // Delegados sin cambio.

  @override
  Future<RespuestaLogin> refrescar(String refreshToken) =>
      _api.refrescar(refreshToken);

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => _api.cambiarContrasena(actual: actual, nueva: nueva);

  @override
  Future<void> recuperarContrasena(String correo) =>
      _api.recuperarContrasena(correo);

  @override
  Future<void> restablecerContrasena(PeticionRestablecer peticion) =>
      _api.restablecerContrasena(peticion);

  @override
  Future<List<Manual>> manualesDe(int vehiculoId) =>
      _api.manualesDe(vehiculoId);

  @override
  Future<Uint8List> ticketDe(int servicioId) => _api.ticketDe(servicioId);

  @override
  Future<Uint8List> ticketDeCita(int citaId) => _api.ticketDeCita(citaId);

  @override
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) => _api.disponibilidad(desde: desde, hasta: hasta);

  @override
  Future<Cita> agendarCita(NuevaCita nueva) => _api.agendarCita(nueva);

  @override
  Future<Cita> cancelarCita(int citaId) => _api.cancelarCita(citaId);
}
