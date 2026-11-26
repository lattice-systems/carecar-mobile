import 'package:http/http.dart' as http;

/// Cliente HTTP de las teselas que no deja su dirección en los errores.
///
/// La ruta de una tesela (acercamiento, columna y fila) dice qué zona está
/// mirando la persona, y el paquete del mapa escribe en la consola cada error
/// de descarga. Por eso todo fallo sale de aquí sin la dirección. La descarga
/// cancelada se deja pasar porque el mapa la reconoce por su tipo y no la
/// reporta.
class ClienteTeselas extends http.BaseClient {
  ClienteTeselas(this._interno);

  final http.Client _interno;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final http.StreamedResponse respuesta;
    try {
      respuesta = await _interno.send(request);
    } on http.RequestAbortedException {
      rethrow;
    } on Exception {
      throw http.ClientException('No se pudo descargar una tesela.');
    }
    if (respuesta.statusCode >= 400) {
      await respuesta.stream.drain<void>();
      throw http.ClientException(
        'No se pudo descargar una tesela (estado ${respuesta.statusCode}).',
      );
    }
    return respuesta;
  }

  @override
  void close() => _interno.close();
}
