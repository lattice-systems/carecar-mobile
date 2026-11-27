import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
import '../api/modelos/comun.dart';
import '../api/modelos/modelos.dart';
import '../nucleo/seguridad/politica_datos_locales.dart';
import 'cifrador_de_cache.dart';

/// Decorador de [CarecarApi] que guarda la ultima respuesta buena de las
/// lecturas y la devuelve cuando no hay conexion.
///
/// Los demas metodos delegan sin cambio. La cache se limpia al cerrar sesion
/// y al iniciar una nueva, para que otro usuario nunca vea datos ajenos.
///
/// V2-M22.13: las copias se guardan **cifradas** (AES-GCM, ver
/// [CifradorDeCache]) y atadas a su clave, porque llevan correo, VIN y placas.
/// Si no se puede cifrar, no se guarda copia: nunca se guarda en claro.
class CarecarApiConCache implements CarecarApi {
  /// Con [politica] (V2-M22.05), en un equipo con root o jailbreak no se
  /// guarda ni se lee ninguna copia, y las que hubiera se borran.
  CarecarApiConCache(
    this._api,
    this._prefs,
    this._cifrador, {
    PoliticaDatosLocales? politica,
  }) : _politica = politica {
    politica?.addListener(_purgarSiNoSePermite);
    _purgarSiNoSePermite();
    unawaited(_borrarCopiasSinCifrar());
  }

  /// Todas las claves de la caché, de cualquier versión.
  static const _prefijoBase = 'cache_carecar_';

  /// Las copias cifradas. Las de antes (`cache_carecar_vehiculos`...) estaban en
  /// claro y por eso cambia el prefijo: así no se confunden ni se leen.
  static const _prefijo = '${_prefijoBase}v2_';

  final CarecarApi _api;
  final SharedPreferences _prefs;
  final CifradorDeCache _cifrador;
  final PoliticaDatosLocales? _politica;

  bool get _permiteCopias => _politica?.permiteCacheLocal ?? true;

  void _purgarSiNoSePermite() {
    if (!_permiteCopias) unawaited(limpiar());
  }

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
      if (!_permiteCopias) return datos;
      try {
        final cifrada = await _cifrador.cifrar(
          jsonEncode(aJson(datos)),
          contexto: clave,
        );
        await _prefs.setString('$_prefijo$clave', cifrada);
      } catch (_) {
        // Si no se puede cifrar o guardar, la lectura buena igual se entrega.
      }
      return datos;
    } on SinConexion {
      if (!_permiteCopias) rethrow;
      final datos = await _copia<T>(clave, deJson);
      if (datos == null) rethrow;
      sinConexion.value = true;
      return datos;
    }
  }

  /// La copia guardada de [clave], o `null` si no hay o no se puede usar: ya no
  /// descifra (alterada, de una llave que se olvidó) o tiene otra forma que la
  /// de ahora. Una copia inservible se borra para no volver a intentarla.
  Future<T?> _copia<T>(String clave, T Function(Object?) deJson) async {
    final guardado = _prefs.getString('$_prefijo$clave');
    if (guardado == null) return null;
    final claro = await _cifrador.descifrar(guardado, contexto: clave);
    if (claro != null) {
      try {
        return deJson(jsonDecode(claro));
      } catch (_) {
        // Con otra forma que la que lee esta versión: se descarta abajo.
      }
    }
    await _prefs.remove('$_prefijo$clave');
    return null;
  }

  /// Borra las copias en claro que dejaron las versiones anteriores a V2-M22.13.
  Future<void> _borrarCopiasSinCifrar() async {
    final viejas = _prefs.getKeys().where(
      (k) => k.startsWith(_prefijoBase) && !k.startsWith(_prefijo),
    );
    for (final clave in viejas.toList()) {
      await _prefs.remove(clave);
    }
  }

  /// Borra todas las copias guardadas y olvida la llave con la que se cifraron.
  Future<void> limpiar() async {
    for (final clave
        in _prefs.getKeys().where((k) => k.startsWith(_prefijoBase)).toList()) {
      await _prefs.remove(clave);
    }
    sinConexion.value = false;
    try {
      await _cifrador.olvidar();
    } catch (_) {
      // Sin copias no hay nada que descifrar; cerrar sesión no debe fallar si
      // el almacenamiento seguro no responde.
    }
  }

  static List<T> _lista<T>(Object? json, T Function(Map<String, Object?>) f) =>
      [for (final e in json! as List) f((e as Map).cast<String, Object?>())];

  @override
  Future<Perfil> miPerfil() => _leer<Perfil>(
    'perfil',
    _api.miPerfil,
    (p) => {
      'id': p.id,
      'nombre': p.nombre,
      'correo': p.correo,
      'telefono': p.telefono,
      // Como fecha, no como instante: el servidor ya la resolvio en la zona de
      // la agencia y guardarla con hora la correria un dia al releerla.
      'clienteDesde': escribirFecha(p.clienteDesde),
    },
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
          'fechaCierre': s.fechaCierre?.toIso8601String(),
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
    int? anio,
  }) => _api.paginaDeServicios(
    vehiculoId,
    pagina: pagina,
    tamano: tamano,
    anio: anio,
  );

  @override
  Future<List<int>> aniosDeServicios(int vehiculoId) =>
      _api.aniosDeServicios(vehiculoId);

  @override
  Future<ServicioDetalle> detalleDeServicio(int servicioId) =>
      _api.detalleDeServicio(servicioId);

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

  /// Sin copia local: «abierto ahora» lo calcula el servidor, y una copia
  /// vieja diría «abierto» con la agencia ya cerrada (V2-M27.02). Sin conexión
  /// la pantalla pide reintentar.
  @override
  Future<List<SucursalApi>> sucursales() => _api.sucursales();

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

  /// Pedir el cambio no toca nada guardado: todavia no cambia el perfil.
  @override
  Future<VerificacionPendiente> pedirCambioDeCorreo({
    required String correo,
    required String contrasenaActual,
  }) => _api.pedirCambioDeCorreo(
    correo: correo,
    contrasenaActual: contrasenaActual,
  );

  /// Confirmar **si** cambia el perfil, asi que la copia guardada queda con el
  /// correo viejo: se borra.
  ///
  /// No se vuelve a guardar con el perfil nuevo a proposito. La respuesta ya
  /// trae el dato fresco para la pantalla, y dejar que la siguiente lectura lo
  /// pida es mas simple que repetir aqui el cifrado de `_leer`. Sin conexion,
  /// mientras tanto, el perfil dira que no hay copia, que es cierto: la que
  /// habia mentia.
  @override
  Future<Perfil> confirmarVerificacion({
    required int id,
    required String codigo,
  }) async {
    final perfil = await _api.confirmarVerificacion(id: id, codigo: codigo);
    await _prefs.remove('${_prefijo}perfil');
    return perfil;
  }

  /// Las sesiones activas **nunca se guardan en copia** (V2-M01.09).
  ///
  /// No es por el tamano: una copia vieja le diria al cliente que la sesion
  /// que acaba de cerrar sigue abierta, o peor, que no hay ninguna intrusa
  /// cuando si la hay. Esta pantalla existe justo para responder «¿quien esta
  /// dentro de mi cuenta ahora?», y a eso o se responde con el servidor o no
  /// se responde: sin conexion sale `SinConexion` y la pantalla lo dice.
  @override
  Future<List<SesionActiva>> misSesiones() => _api.misSesiones();

  /// Cerrar todas incluye la sesion de este celular, asi que la copia local
  /// deja de tener dueno: se limpia igual que al cerrar sesion.
  @override
  Future<void> cerrarTodasLasSesiones() async {
    try {
      await _api.cerrarTodasLasSesiones();
    } finally {
      await limpiar();
    }
  }

  // Delegados sin cambio.

  @override
  Future<void> cerrarSesionActiva(int sesionId) =>
      _api.cerrarSesionActiva(sesionId);

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

  /// Sin copia: cada respuesta del asistente es nueva y no sirve sin conexion.
  @override
  Future<RespuestaAsistente> preguntarAlAsistente({
    required int vehiculoId,
    required String pregunta,
  }) => _api.preguntarAlAsistente(vehiculoId: vehiculoId, pregunta: pregunta);

  /// Sin copia, igual que [preguntarAlAsistente].
  @override
  Stream<EventoAsistente> preguntarAlAsistenteEnFlujo({
    required int vehiculoId,
    required String pregunta,
  }) => _api.preguntarAlAsistenteEnFlujo(
    vehiculoId: vehiculoId,
    pregunta: pregunta,
  );

  /// Sin copia: la foto y su respuesta no se guardan en el telefono.
  @override
  Future<TestigoAsistente> identificarTestigo({
    required int vehiculoId,
    required List<int> imagen,
    required String tipo,
  }) => _api.identificarTestigo(
    vehiculoId: vehiculoId,
    imagen: imagen,
    tipo: tipo,
  );

  @override
  Future<void> calificarRespuestaDelAsistente({
    required int consultaId,
    required bool util,
  }) => _api.calificarRespuestaDelAsistente(consultaId: consultaId, util: util);

  @override
  Future<Uint8List> ticketDe(int servicioId) => _api.ticketDe(servicioId);

  @override
  Future<Uint8List> ticketDeCita(int citaId) => _api.ticketDeCita(citaId);

  // El comprobante lleva un codigo firmado: nunca se guarda en cache.
  @override
  Future<ComprobanteCita> comprobanteDeCita(int citaId) =>
      _api.comprobanteDeCita(citaId);

  @override
  Future<List<Disponibilidad>> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) => _api.disponibilidad(desde: desde, hasta: hasta);

  @override
  Future<Cita> agendarCita(NuevaCita nueva) => _api.agendarCita(nueva);

  @override
  Future<Cita> cancelarCita(int citaId) => _api.cancelarCita(citaId);

  @override
  Future<Cita> reprogramarCita(
    int citaId, {
    required int franjaId,
    required DateTime fecha,
  }) => _api.reprogramarCita(citaId, franjaId: franjaId, fecha: fecha);

  // Estreno (V2-M16): sin copia; las solicitudes cambian en el CRM.
  @override
  Future<CotizacionEstreno> calcularMensualidad({
    required int modeloCatalogoId,
    required double enganche,
    required int plazoMeses,
  }) => _api.calcularMensualidad(
    modeloCatalogoId: modeloCatalogoId,
    enganche: enganche,
    plazoMeses: plazoMeses,
  );

  @override
  Future<SolicitudEstreno> crearSolicitudEstreno(NuevaSolicitudEstreno nueva) =>
      _api.crearSolicitudEstreno(nueva);

  @override
  Future<Pagina<SolicitudEstreno>> paginaDeSolicitudesEstreno({
    int pagina = 0,
    int tamano = 20,
  }) => _api.paginaDeSolicitudesEstreno(pagina: pagina, tamano: tamano);

  // Privacidad (V2-M22.01): sin copia. «Aceptado» tiene que ser lo que el
  // servidor sabe ahora; una copia vieja dejaria pasar sin aceptar una version
  // nueva.
  @override
  Future<AvisoPrivacidad> avisoDePrivacidad() => _api.avisoDePrivacidad();

  @override
  Future<AceptacionAviso> aceptarAvisoDePrivacidad(int avisoId) =>
      _api.aceptarAvisoDePrivacidad(avisoId);

  // Derechos ARCO (V2-M22.02): sin copia, y menos que nada el archivo: es una
  // copia de los datos de la persona y no se deja en el telefono.
  @override
  Future<List<SolicitudArco>> misSolicitudesArco() => _api.misSolicitudesArco();

  @override
  Future<SolicitudArco> pedirAccesoArco() => _api.pedirAccesoArco();

  @override
  Future<Uint8List> descargarArchivoArco(int solicitudId) =>
      _api.descargarArchivoArco(solicitudId);

  // La cancelacion no se guarda: la cache se limpia al cerrar la sesion que
  // viene despues.
  @override
  Future<SolicitudArco> cancelarCuentaArco(String contrasena) =>
      _api.cancelarCuentaArco(contrasena);
}
