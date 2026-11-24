import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Abre la hoja de compartir del sistema con el PDF del ticket. Los bytes
/// viajan en memoria: no se escribe nada en disco ni se piden permisos.
Future<void> compartirTicketConHojaDelSistema(
  Uint8List bytes,
  String nombreArchivo,
) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
      fileNameOverrides: [nombreArchivo],
    ),
  );
}
