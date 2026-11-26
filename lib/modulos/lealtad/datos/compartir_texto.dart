import 'package:share_plus/share_plus.dart';

/// Abre la hoja de compartir del sistema con un texto (el codigo de referido).
Future<void> compartirTextoConHojaDelSistema(String texto) async {
  await SharePlus.instance.share(ShareParams(text: texto));
}
