import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Abre la hoja de compartir del sistema con la copia de los datos (V2-M22.02):
/// desde ahí la persona la guarda donde quiera. No se escribe en una carpeta de
/// la app: el archivo es de la persona, no se queda en el teléfono.
Future<void> compartirDatosConHojaDelSistema(
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
