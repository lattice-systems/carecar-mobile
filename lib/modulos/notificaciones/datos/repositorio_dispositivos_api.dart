import '../../../nucleo/api/api_cliente.dart';
import '../dominio/push.dart';

/// `PUT` y `DELETE /dispositivos/{instalacionId}` (V2-M06.02) con el cliente
/// del núcleo. Sin caché ni reintentos propios: quien llama decide. El token
/// no se registra en logs.
class RepositorioDispositivosApi implements RepositorioDispositivos {
  RepositorioDispositivosApi(this._cliente);

  final ApiCliente _cliente;

  static String _ruta(String instalacionId) =>
      '/dispositivos/${Uri.encodeComponent(instalacionId)}';

  @override
  Future<void> registrar({
    required String instalacionId,
    required String tokenFcm,
    required PlataformaPush plataforma,
    String? idioma,
  }) => _cliente.actualizarSinRespuesta(
    _ruta(instalacionId),
    cuerpo: {
      'tokenFcm': tokenFcm,
      'plataforma': plataforma.valor,
      'idioma': ?idioma,
    },
  );

  @override
  Future<void> darDeBaja(String instalacionId) =>
      _cliente.eliminar(_ruta(instalacionId));
}
