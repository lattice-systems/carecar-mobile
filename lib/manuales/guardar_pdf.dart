import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Resultado de guardar el PDF.
enum ResultadoGuardado { guardado, cancelado }

/// Abre el selector del sistema y devuelve la ruta elegida, o `null` si el
/// usuario cancela.
typedef Guardador = Future<String?> Function(Uint8List bytes, String nombre);

Future<String?> _guardarConSelector(Uint8List bytes, String nombre) =>
    FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(data: bytes, fileName: nombre),
    );

/// Nombre de archivo limpio: «Manual Nissan Frontier 2024.pdf».
String nombreArchivoPdf(String titulo) {
  var base = titulo
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (base.isEmpty) base = 'Manual';
  if (!base.toLowerCase().startsWith('manual')) base = 'Manual $base';
  return '$base.pdf';
}

/// Guarda el PDF en el telefono con el selector del sistema (SAF), sin
/// permisos especiales. Lanza si el guardado falla.
Future<ResultadoGuardado> guardarPdf(
  Uint8List bytes,
  String titulo, {
  Guardador guardador = _guardarConSelector,
}) async {
  final ruta = await guardador(bytes, nombreArchivoPdf(titulo));
  return ruta == null
      ? ResultadoGuardado.cancelado
      : ResultadoGuardado.guardado;
}
