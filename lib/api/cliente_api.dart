import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'excepciones.dart';
import 'modelos/problema.dart';

/// Transporte HTTP de la API: arma peticiones, lee JSON y traduce los codigos
/// del contrato a excepciones de [ExcepcionApi].
///
/// Es la unica clase que sabe que detras hay HTTP. La interfaz que usan las
/// pantallas es `CarecarApi`, asi que cambiar de la API simulada a la real, o
/// incluso de cliente HTTP, no toca la interfaz.
class ClienteApi {
  ClienteApi({
    required this.config,
    http.Client? http,
    this.obtenerToken,
    this.tiempoLimite = const Duration(seconds: 20),
  }) : _http = http ?? _crearCliente();

  static http.Client _crearCliente() => http.Client();

  final ApiConfig config;
  final http.Client _http;

  /// Devuelve el token de la sesion, o `null` si no hay.
  ///
  /// Es una funcion y no un valor para que la sesion pueda cambiar sin
  /// reconstruir el cliente. Donde se guarda el token es decision de APP-2.1.
  final Future<String?> Function()? obtenerToken;

  final Duration tiempoLimite;

  void cerrar() => _http.close();

  Future<Map<String, String>> _encabezados({bool conCuerpo = false}) async {
    final encabezados = <String, String>{'accept': 'application/json'};
    if (conCuerpo) encabezados['content-type'] = 'application/json';

    final token = await obtenerToken?.call();
    if (token != null && token.isNotEmpty) {
      encabezados['authorization'] = 'Bearer $token';
    }
    return encabezados;
  }

  /// GET que devuelve un objeto.
  Future<T> obtener<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _ejecutar(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: await _encabezados(),
      ),
    );
    return _leerObjeto(respuesta, leer);
  }

  /// GET que devuelve una lista.
  Future<List<T>> obtenerLista<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _ejecutar(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: await _encabezados(),
      ),
    );
    return _leerLista(respuesta, leer);
  }

  /// POST que devuelve un objeto.
  Future<T> enviar<T>(
    String camino, {
    required Object? cuerpo,
    required T Function(Map<String, Object?>) leer,
  }) async {
    final respuesta = await _ejecutar(
      () async => _http.post(
        config.ruta(camino),
        headers: await _encabezados(conCuerpo: cuerpo != null),
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
    );
    return _leerObjeto(respuesta, leer);
  }

  /// POST de los endpoints que contestan 202 o 204 sin cuerpo.
  Future<void> enviarSinRespuesta(String camino, {Object? cuerpo}) async {
    final respuesta = await _ejecutar(
      () async => _http.post(
        config.ruta(camino),
        headers: await _encabezados(conCuerpo: cuerpo != null),
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
    );
    _verificarEstado(respuesta);
  }

  /// GET de un archivo binario, como el ticket en PDF.
  Future<Uint8List> descargar(String camino) async {
    final respuesta = await _ejecutar(
      () async => _http.get(
        config.ruta(camino),
        headers: {...await _encabezados(), 'accept': '*/*'},
      ),
    );
    _verificarEstado(respuesta);
    return respuesta.bodyBytes;
  }

  /// Envuelve la llamada para que cualquier fallo de red salga como
  /// [SinConexion] y nunca como un error de servidor.
  Future<http.Response> _ejecutar(
    Future<http.Response> Function() llamada,
  ) async {
    try {
      return await llamada().timeout(tiempoLimite);
    } on SocketException catch (e) {
      throw SinConexion(e);
    } on http.ClientException catch (e) {
      throw SinConexion(e);
    } on HandshakeException catch (e) {
      throw SinConexion(e);
    } on TimeoutException catch (e) {
      throw SinConexion(e);
    }
  }

  void _verificarEstado(http.Response respuesta) {
    final status = respuesta.statusCode;
    if (status >= 200 && status < 300) return;

    // El cuerpo deberia venir con el formato `Problema`, pero un proxy o un
    // 502 pueden devolver HTML: el mapeo no debe depender de poder leerlo.
    Problema? problema;
    try {
      final decodificado = jsonDecode(respuesta.body);
      if (decodificado is Map<String, Object?>) {
        problema = Problema.fromJson(decodificado);
      }
    } catch (_) {
      problema = null;
    }

    // RIC-14: el `message` del servidor solo se muestra en 401, 403, 404, 409 y
    // 429. En 400 trae nombres de campos y en 5xx el detalle tecnico de la
    // excepcion, asi que ahi va un texto de la app.
    final mensaje = (problema != null && problema.mensajeEsParaElUsuario)
        ? problema.message
        : _mensajePorOmision(status, problema?.codigo);

    if (status == 429) {
      throw DemasiadosIntentos(
        mensaje,
        problema: problema,
        esperaSegundos: _segundosDeEspera(respuesta),
      );
    }

    throw switch (status) {
      400 => DatosInvalidos(mensaje, problema: problema),
      401 => CredencialesInvalidas(mensaje, problema: problema),
      403 => CuentaDesactivada(mensaje, problema: problema),
      404 => NoEncontrado(mensaje, problema: problema),
      409 => Conflicto(mensaje, problema: problema),
      _ => ErrorDelServidor(mensaje, problema: problema, status: status),
    };
  }

  /// Lee `Retry-After`, que el contrato manda en segundos con el 429 (RIC-5).
  static int? _segundosDeEspera(http.Response respuesta) {
    final valor = respuesta.headers['retry-after'];
    return valor == null ? null : int.tryParse(valor.trim());
  }

  /// Texto propio de la app cuando el del servidor no sirve para mostrarse.
  ///
  /// Cuando viene `codigo` se usa ese, porque distingue cosas que el `status`
  /// solo no distingue: el codigo de recuperacion invalido y una contrasena
  /// que no cumple las reglas son los dos un 400 (RIC-15).
  static String _mensajePorOmision(int status, CodigoProblema? codigo) =>
      switch (codigo) {
        CodigoProblema.codigoInvalido =>
          'El código no es válido o ya venció. Pide uno nuevo.',
        CodigoProblema.datosInvalidos => 'Revisa los datos e intenta de nuevo.',
        CodigoProblema.credencialesInvalidas =>
          'Correo o contraseña incorrectos.',
        CodigoProblema.cuentaDesactivada =>
          'Tu cuenta está desactivada. Comunícate con la agencia.',
        CodigoProblema.demasiadosIntentos =>
          'Demasiados intentos. Espera un momento e intenta de nuevo.',
        CodigoProblema.franjaSinCupo => 'Esa hora ya no tiene lugar.',
        CodigoProblema.fueraDePlazo => 'Ya pasó el plazo para cancelar.',
        CodigoProblema.citaNoCancelable => 'Esa cita ya no se puede cancelar.',
        _ => switch (status) {
          400 => 'Revisa los datos e intenta de nuevo.',
          401 => 'Correo o contraseña incorrectos.',
          403 => 'Tu cuenta está desactivada. Comunícate con la agencia.',
          404 => 'No encontramos lo que buscabas.',
          409 => 'No se pudo completar la operación. Intenta de nuevo.',
          429 => 'Demasiados intentos. Espera un momento e intenta de nuevo.',
          _ => 'Ocurrió un error inesperado. Intenta de nuevo.',
        },
      };

  T _leerObjeto<T>(
    http.Response respuesta,
    T Function(Map<String, Object?>) leer,
  ) {
    _verificarEstado(respuesta);

    final cuerpo = _decodificar(respuesta);
    if (cuerpo is! Map<String, Object?>) {
      throw RespuestaInvalida(
        'Se esperaba un objeto JSON y llego ${cuerpo.runtimeType}.',
      );
    }
    try {
      return leer(cuerpo);
    } on FormatException catch (e) {
      throw RespuestaInvalida(
        'La respuesta no respeta el contrato: ${e.message}',
        causa: e,
      );
    }
  }

  List<T> _leerLista<T>(
    http.Response respuesta,
    T Function(Map<String, Object?>) leer,
  ) {
    _verificarEstado(respuesta);

    final cuerpo = _decodificar(respuesta);
    if (cuerpo is! List) {
      throw RespuestaInvalida(
        'Se esperaba una lista JSON y llego ${cuerpo.runtimeType}.',
      );
    }
    try {
      return cuerpo
          .map((e) => leer((e as Map).cast<String, Object?>()))
          .toList(growable: false);
    } on FormatException catch (e) {
      throw RespuestaInvalida(
        'La respuesta no respeta el contrato: ${e.message}',
        causa: e,
      );
    } on TypeError catch (e) {
      throw RespuestaInvalida(
        'La lista traia un elemento que no es un objeto JSON.',
        causa: e,
      );
    }
  }

  Object? _decodificar(http.Response respuesta) {
    if (respuesta.body.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(respuesta.bodyBytes));
    } catch (e) {
      throw RespuestaInvalida('El servidor no devolvio JSON valido.', causa: e);
    }
  }
}
