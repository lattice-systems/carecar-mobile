import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../config/flavor.dart';
import 'api_config.dart';
import 'cliente_http_fijado.dart';
import 'excepciones.dart';
import 'modelos/pagina.dart';
import 'modelos/problema.dart';

/// Tiempo que espera [ClienteApi] una respuesta antes de rendirse.
///
/// El backend corre en Azure Container Apps y se apaga sin trafico: el primer
/// acceso tras un rato de inactividad tarda ~35 s en despertar. Con 20 s el
/// primer inicio de sesion mostraba «Sin conexion» aunque el servidor si
/// estaba llegando; 60 s deja holgura sobre el arranque en frio (V2-M01.12).
const tiempoLimitePorOmision = Duration(seconds: 60);

/// Transporte HTTP de la API: arma peticiones, lee JSON y traduce los codigos
/// del contrato a excepciones de [ExcepcionApi].
///
/// Es la unica clase que sabe que detras hay HTTP. La interfaz que usan las
/// pantallas es `CarecarApi`, asi que cambiar de la API simulada a la real, o
/// incluso de cliente HTTP, no toca la interfaz.
/// ¿El fallo del saludo TLS es porque el certificado no valida? (V2-M22.15)
///
/// Dart no distingue el motivo con un tipo: viene en el texto del sistema.
/// `CERTIFICATE_VERIFY_FAILED` cubre una cadena que no llega a lo fijado, un
/// certificado vencido y un nombre que no coincide;
/// `cliente_http_fijado_test.dart` lo comprueba con un servidor real.
bool esCertificadoRechazado(HandshakeException e) =>
    '$e'.contains('CERTIFICATE_VERIFY_FAILED');

class ClienteApi {
  ClienteApi({
    required this.config,
    http.Client? http,
    this.obtenerToken,
    this.renovarSesion,
    this.alCuentaDesactivada,
    this.alVerificarCertificado,
    this.tiempoLimite = tiempoLimitePorOmision,
  }) : _http = http ?? _crearCliente(config);

  /// Avisa si el certificado del servidor se pudo verificar (`true`) o no
  /// (`false`), cada vez que hay respuesta o un rechazo del certificado.
  final void Function(bool verificado)? alVerificarCertificado;

  /// El cliente por omisión confía en lo que dice el flavor para la dirección de
  /// [config] (V2-M22.04): fija los certificados de Azure en `pruebas` y
  /// `produccion`.
  static http.Client _crearCliente(ApiConfig config) => crearClienteHttp(
    decidirConfianza(flavor: Flavor.actual, servidor: config.base),
  );

  final ApiConfig config;
  final http.Client _http;

  /// Devuelve el token de la sesion, o `null` si no hay.
  ///
  /// Es una funcion y no un valor para que la sesion pueda cambiar sin
  /// reconstruir el cliente. Donde se guarda el token es decision de APP-2.1.
  final Future<String?> Function()? obtenerToken;

  /// Renueva la sesion cuando el servidor contesta 401 (RIC-3).
  ///
  /// Devuelve `true` si consiguio un par de tokens nuevo, y entonces la
  /// peticion se reintenta **una sola vez**. Si devuelve `false`, el 401 sale
  /// como estaba y quien llamo decide que hacer.
  ///
  /// Es una funcion y no una dependencia a `ControladorSesion` porque si no,
  /// la capa de datos dependeria de la de sesion, que es la direccion
  /// contraria: el controlador usa el cliente, no al reves.
  final Future<bool> Function()? renovarSesion;

  /// Avisa que el servidor contesto 403 con un token puesto (V2-M01.08).
  ///
  /// En la app un 403 solo puede significar **cuenta desactivada**: un recurso
  /// ajeno responde 404 (RIC-3). Quien lo reciba borra la sesion local; aqui no
  /// se sabe que es una sesion, igual que con [renovarSesion].
  final Future<void> Function()? alCuentaDesactivada;

  final Duration tiempoLimite;

  void cerrar() => _http.close();

  Future<Map<String, String>> _encabezados({
    bool conCuerpo = false,
    bool conToken = true,
  }) async {
    final encabezados = <String, String>{'accept': 'application/json'};
    if (conCuerpo) encabezados['content-type'] = 'application/json';

    if (!conToken) return encabezados;

    final token = await obtenerToken?.call();
    if (token != null && token.isNotEmpty) {
      encabezados['authorization'] = 'Bearer $token';
    }
    return encabezados;
  }

  /// `true` si hay token para mandar.
  Future<bool> _haySesion() async {
    final token = await obtenerToken?.call();
    return token != null && token.isNotEmpty;
  }

  /// Ejecuta la peticion y, si el servidor contesta 401, la reintenta una vez
  /// con la sesion renovada.
  ///
  /// El reintento solo se intenta cuando la peticion original **llevaba un
  /// token**. Esa condicion es la que evita el error grave de esta tarea: el
  /// login tambien contesta 401 cuando las credenciales estan mal, y ahi no hay
  /// nada que refrescar. Sin ella, escribir mal la contrasena se veria como una
  /// sesion expirada.
  ///
  /// Nunca hay un segundo reintento: [hacer] se llama como maximo dos veces.
  Future<http.Response> _pedir(
    Future<http.Response> Function() hacer, {
    required bool conToken,
  }) async {
    final respuesta = await _ejecutar(hacer);

    // Se avisa aqui, en el embudo por el que pasan todas las peticiones con
    // token, y no en cada pantalla: la cuenta se puede desactivar mientras la
    // persona esta dentro, y entonces el 403 llega en cualquiera.
    if (respuesta.statusCode == 403 && conToken && await _haySesion()) {
      await alCuentaDesactivada?.call();
      return respuesta;
    }

    if (respuesta.statusCode != 401 || !conToken) return respuesta;

    final renovar = renovarSesion;
    if (renovar == null) return respuesta;
    if (!await _haySesion()) return respuesta;

    if (!await renovar()) return respuesta;
    return _ejecutar(hacer);
  }

  /// GET que devuelve un objeto.
  Future<T> obtener<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _pedir(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: await _encabezados(),
      ),
      conToken: true,
    );
    return _leerObjeto(respuesta, leer);
  }

  /// GET que devuelve una lista de enteros (`[2026, 2025]`).
  Future<List<int>> obtenerEnteros(String camino) async {
    final respuesta = await _pedir(
      () async => _http.get(config.ruta(camino), headers: await _encabezados()),
      conToken: true,
    );
    _verificarEstado(respuesta);
    final cuerpo = _decodificar(respuesta);
    if (cuerpo is! List || cuerpo.any((e) => e is! num)) {
      throw RespuestaInvalida(
        'Se esperaba una lista de números y llegó ${cuerpo.runtimeType}.',
      );
    }
    return [for (final e in cuerpo) (e as num).toInt()];
  }

  /// GET que devuelve un objeto, o `null` si el servidor contesta 204 porque
  /// no hay nada que mostrar (por ejemplo `GET /asistencia?activa=true`).
  Future<T?> obtenerOpcional<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _pedir(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: await _encabezados(),
      ),
      conToken: true,
    );
    if (respuesta.statusCode == 204) return null;
    return _leerObjeto(respuesta, leer);
  }

  /// GET que devuelve una lista.
  Future<List<T>> obtenerLista<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _pedir(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: await _encabezados(),
      ),
      conToken: true,
    );
    return _leerLista(respuesta, leer);
  }

  /// GET de una lista paginada (`{contenido, pagina, totalPaginas, ...}`).
  ///
  /// Si el servidor contesta una lista simple, se trata como pagina unica.
  Future<Pagina<T>> obtenerPagina<T>(
    String camino,
    T Function(Map<String, Object?>) leer, {
    required int pagina,
    required int tamano,
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _pedir(
      () async => _http.get(
        config.ruta(
          camino,
          consulta: {...?consulta, 'pagina': '$pagina', 'tamano': '$tamano'},
        ),
        headers: await _encabezados(),
      ),
      conToken: true,
    );
    final contenido = _leerLista(respuesta, leer);
    final cuerpo = _decodificar(respuesta);
    if (cuerpo is! Map) return Pagina(contenido: contenido);
    final numero = cuerpo['pagina'];
    final total = cuerpo['totalPaginas'];
    return Pagina(
      contenido: contenido,
      pagina: numero is num ? numero.toInt() : pagina,
      totalPaginas: total is num ? total.toInt() : pagina + 1,
    );
  }

  /// POST que devuelve un objeto.
  ///
  /// [conToken] en `false` para las rutas publicas del contrato. Ademas de no
  /// mandar el encabezado, apaga el reintento con sesion renovada, que en una
  /// ruta publica no tendria sentido.
  ///
  /// [encabezados] suma los que pida una ruta, como `Idempotency-Key`.
  Future<T> enviar<T>(
    String camino, {
    required Object? cuerpo,
    required T Function(Map<String, Object?>) leer,
    bool conToken = true,
    Map<String, String>? encabezados,
  }) async {
    final respuesta = await _pedir(
      () async => _http.post(
        config.ruta(camino),
        headers: {
          ...await _encabezados(conCuerpo: cuerpo != null, conToken: conToken),
          ...?encabezados,
        },
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
      conToken: conToken,
    );
    return _leerObjeto(respuesta, leer);
  }

  /// POST de los endpoints que contestan 202 o 204 sin cuerpo.
  Future<void> enviarSinRespuesta(
    String camino, {
    Object? cuerpo,
    bool conToken = true,
  }) async {
    final respuesta = await _pedir(
      () async => _http.post(
        config.ruta(camino),
        headers: await _encabezados(
          conCuerpo: cuerpo != null,
          conToken: conToken,
        ),
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
      conToken: conToken,
    );
    _verificarEstado(respuesta);
  }

  /// POST `multipart/form-data` con un archivo y campos de texto, que devuelve
  /// un objeto (V2-M24.05: la foto de un testigo).
  Future<T> enviarArchivo<T>(
    String camino, {
    required Map<String, String> campos,
    required String nombreArchivo,
    required List<int> bytes,
    required String tipo,
    required T Function(Map<String, Object?>) leer,
  }) async {
    final respuesta = await _pedir(() async {
      final peticion = http.MultipartRequest('POST', config.ruta(camino))
        ..headers.addAll(await _encabezados())
        ..fields.addAll(campos)
        ..files.add(
          http.MultipartFile.fromBytes(
            nombreArchivo,
            bytes,
            filename: nombreArchivo,
            contentType: MediaType.parse(tipo),
          ),
        );
      return http.Response.fromStream(await _http.send(peticion));
    }, conToken: true);
    return _leerObjeto(respuesta, leer);
  }

  /// POST que responde con Server-Sent Events (V2-M24.09). Cada evento llega
  /// con su nombre y su `data` ya decodificada como JSON. Un error antes de
  /// abrir el flujo (4xx/5xx con JSON) sale como la excepcion de siempre.
  Stream<EventoServidor> enviarFlujo(
    String camino, {
    required Object cuerpo,
  }) async* {
    Future<http.StreamedResponse> abrir() async {
      final peticion = http.Request('POST', config.ruta(camino))
        ..headers.addAll(await _encabezados(conCuerpo: true))
        ..headers['accept'] = 'text/event-stream, application/json'
        ..body = jsonEncode(cuerpo);
      try {
        final abierta = await _http.send(peticion).timeout(tiempoLimite);
        alVerificarCertificado?.call(true);
        return abierta;
      } on SocketException catch (e) {
        throw SinConexion(e);
      } on http.ClientException catch (e) {
        throw SinConexion(e);
      } on HandshakeException catch (e) {
        throw _porHandshake(e);
      } on TimeoutException catch (e) {
        throw SinConexion(e);
      }
    }

    var respuesta = await abrir();
    if (respuesta.statusCode == 401 && await _haySesion()) {
      final renovar = renovarSesion;
      if (renovar != null && await renovar()) respuesta = await abrir();
    }
    if (respuesta.statusCode != 200) {
      _verificarEstado(await http.Response.fromStream(respuesta));
    }

    String? evento;
    final datos = StringBuffer();
    try {
      await for (final linea
          in respuesta.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (linea.isEmpty) {
          if (evento != null || datos.isNotEmpty) {
            yield EventoServidor(
              evento ?? 'message',
              datos.isEmpty ? null : jsonDecode(datos.toString()),
            );
          }
          evento = null;
          datos.clear();
        } else if (linea.startsWith('event:')) {
          evento = linea.substring(6).trim();
        } else if (linea.startsWith('data:')) {
          if (datos.isNotEmpty) datos.write('\n');
          datos.write(linea.substring(5).trimLeft());
        }
      }
    } on http.ClientException catch (e) {
      throw SinConexion(e);
    } on SocketException catch (e) {
      throw SinConexion(e);
    }
  }

  /// PUT que devuelve un objeto (editar un recurso propio).
  Future<T> actualizar<T>(
    String camino, {
    required Object? cuerpo,
    required T Function(Map<String, Object?>) leer,
  }) async {
    final respuesta = await _pedir(
      () async => _http.put(
        config.ruta(camino),
        headers: await _encabezados(conCuerpo: cuerpo != null),
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
      conToken: true,
    );
    return _leerObjeto(respuesta, leer);
  }

  /// PATCH que devuelve un objeto (cambiar parte de un recurso propio).
  ///
  /// Se separa de [actualizar] porque el verbo importa: un PUT dice «esta es
  /// la version completa» y un PATCH «cambia solo esto», y el contrato declara
  /// PATCH donde el cliente manda un campo suelto.
  Future<T> parchar<T>(
    String camino, {
    required Object? cuerpo,
    required T Function(Map<String, Object?>) leer,
  }) async {
    final respuesta = await _pedir(
      () async => _http.patch(
        config.ruta(camino),
        headers: await _encabezados(conCuerpo: cuerpo != null),
        body: cuerpo == null ? null : jsonEncode(cuerpo),
      ),
      conToken: true,
    );
    return _leerObjeto(respuesta, leer);
  }

  /// DELETE de los endpoints que contestan 204 sin cuerpo.
  Future<void> eliminar(String camino) async {
    final respuesta = await _pedir(
      () async =>
          _http.delete(config.ruta(camino), headers: await _encabezados()),
      conToken: true,
    );
    _verificarEstado(respuesta);
  }

  /// GET de un archivo binario, como el ticket en PDF o el pase de Wallet.
  Future<Uint8List> descargar(
    String camino, {
    Map<String, String?>? consulta,
  }) async {
    final respuesta = await _pedir(
      () async => _http.get(
        config.ruta(camino, consulta: consulta),
        headers: {...await _encabezados(), 'accept': '*/*'},
      ),
      conToken: true,
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
      final respuesta = await llamada().timeout(tiempoLimite);
      alVerificarCertificado?.call(true);
      return respuesta;
    } on SocketException catch (e) {
      throw SinConexion(e);
    } on http.ClientException catch (e) {
      throw SinConexion(e);
    } on HandshakeException catch (e) {
      throw _porHandshake(e);
    } on TimeoutException catch (e) {
      throw SinConexion(e);
    }
  }

  /// Un fallo del saludo TLS es una [SinConexion], salvo que sea porque el
  /// certificado no valida (V2-M22.15): entonces es [ConexionNoSegura] y se
  /// avisa, para que la app lo explique en vez de decir «sin conexión».
  SinConexion _porHandshake(HandshakeException e) {
    if (!esCertificadoRechazado(e)) return SinConexion(e);
    alVerificarCertificado?.call(false);
    return ConexionNoSegura(e);
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
      422 when problema?.codigo == CodigoProblema.sinParametrosDeValuacion =>
        SinParametrosDeValuacion(mensaje, problema: problema),
      422 => SolicitudRechazada(mensaje, problema: problema),
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
        CodigoProblema.sinParametrosDeValuacion =>
          'Todavía no podemos estimar ese auto.',
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

    final decodificado = _decodificar(respuesta);
    // Servicios y citas llegan paginados (`PaginaServicios`, `PaginaCitas`):
    // se toma su `contenido`. Ver tambien [obtenerPagina].
    final cuerpo = decodificado is Map && decodificado['contenido'] is List
        ? decodificado['contenido']
        : decodificado;
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

/// Un evento de un flujo SSE: su nombre (`event:`) y su `data:` como JSON.
class EventoServidor {
  const EventoServidor(this.evento, this.datos);

  final String evento;
  final Object? datos;
}
