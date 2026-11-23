import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dominio/pase_de_wallet.dart';

/// Entrega el pase al sistema operativo.
///
/// Google: abre el enlace «Guardar en Google Wallet» fuera de la app. Apple:
/// ofrece el `.pkpass` en la hoja de compartir, que lo abre en Wallet. Los
/// bytes viajan en memoria; la app no los escribe en disco ni los conserva.
class EntregaDePaseDelSistema implements EntregaDePase {
  const EntregaDePaseDelSistema();

  static const tipoPkpass = 'application/vnd.apple.pkpass';

  @override
  Future<void> entregar(PaseDeWallet pase, {required int citaId}) async {
    switch (pase) {
      case PaseGoogle(:final enlace):
        final abierto = await launchUrl(
          enlace,
          mode: LaunchMode.externalApplication,
        );
        if (!abierto) {
          throw StateError('El sistema no pudo abrir Google Wallet.');
        }
      case PaseApple(:final bytes):
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: tipoPkpass)],
            fileNameOverrides: ['cita-$citaId.pkpass'],
          ),
        );
    }
  }
}
