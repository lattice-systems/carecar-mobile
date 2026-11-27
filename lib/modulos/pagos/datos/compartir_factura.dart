import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../dominio/pagos.dart';

/// Abre la hoja de compartir del sistema con el PDF o el XML de la factura
/// (V2-M08.06). Los bytes viajan en memoria: no se escribe nada en disco ni
/// se piden permisos.
Future<void> compartirFacturaConHojaDelSistema(ArchivoFactura archivo) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          Uint8List.fromList(archivo.bytes),
          mimeType: archivo.formato.tipoContenido,
        ),
      ],
      fileNameOverrides: [archivo.nombre],
    ),
  );
}
