import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Abre la hoja de compartir del sistema con la bitácora exportada. Los bytes
/// viajan en memoria: no se escribe nada en disco ni se piden permisos.
Future<void> compartirBitacoraConHojaDelSistema(
  Uint8List bytes,
  String nombreArchivo,
  String tipoMime,
) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: tipoMime)],
      fileNameOverrides: [nombreArchivo],
    ),
  );
}
