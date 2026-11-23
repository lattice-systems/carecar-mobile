import 'dart:typed_data';

/// Cartera digital donde se guarda el pase de una cita (V2-M25.03).
enum PlataformaWallet {
  apple('apple'),
  google('google');

  const PlataformaWallet(this.enElContrato);

  /// Valor del parametro `plataforma` de `GET /citas/{id}/pase`.
  final String enElContrato;
}

/// Pase de Wallet que firma el backend con el QR del comprobante.
///
/// Nunca se guarda en cache ni en disco: se pide al tocar el boton y se
/// entrega al sistema. Si la cita se cancela, el backend deja de emitirlo.
sealed class PaseDeWallet {
  const PaseDeWallet();
}

/// Archivo `.pkpass` para Apple Wallet.
class PaseApple extends PaseDeWallet {
  const PaseApple(this.bytes);

  final Uint8List bytes;
}

/// Enlace «Guardar en Google Wallet» (`https://pay.google.com/gp/v/save/...`).
class PaseGoogle extends PaseDeWallet {
  const PaseGoogle(this.enlace);

  final Uri enlace;
}

/// Pide al backend el pase de una cita.
abstract interface class RepositorioPaseWallet {
  Future<PaseDeWallet> obtener(int citaId, PlataformaWallet plataforma);
}

/// Pone el pase en manos del sistema (abrir Google Wallet o compartir el
/// `.pkpass`). Es un puerto para no tocar canales de plataforma en pruebas.
abstract interface class EntregaDePase {
  Future<void> entregar(PaseDeWallet pase, {required int citaId});
}
