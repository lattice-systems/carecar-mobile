import '../../../api/excepciones.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/pase_de_wallet.dart';

/// Lee `GET /citas/{id}/pase?plataforma=apple|google` con el cliente del
/// nucleo.
///
/// Apple responde el archivo `.pkpass`; Google, `{url}`. El enlace de Google
/// solo se acepta si es HTTPS de `pay.google.com`: es lo unico que la app abre
/// fuera de si misma, y un servidor comprometido no debe poder mandarla a otro
/// sitio.
class RepositorioPaseWalletApi implements RepositorioPaseWallet {
  const RepositorioPaseWalletApi(this._cliente);

  final ApiCliente _cliente;

  @override
  Future<PaseDeWallet> obtener(int citaId, PlataformaWallet plataforma) async {
    final camino = '/citas/$citaId/pase';
    final consulta = {'plataforma': plataforma.enElContrato};
    switch (plataforma) {
      case PlataformaWallet.apple:
        return PaseApple(await _cliente.descargar(camino, consulta: consulta));
      case PlataformaWallet.google:
        final url = await _cliente.obtener<Object?>(
          camino,
          (json) => json['url'],
          consulta: consulta,
        );
        final enlace = url is String ? Uri.tryParse(url) : null;
        if (enlace == null ||
            enlace.scheme != 'https' ||
            enlace.host != 'pay.google.com') {
          throw const RespuestaInvalida(
            'El servidor mando un enlace de Wallet que no es valido.',
          );
        }
        return PaseGoogle(enlace);
    }
  }
}
