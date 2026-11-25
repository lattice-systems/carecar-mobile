import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../dominio/lector_ticket.dart';
import '../dominio/parser_ticket.dart';

/// Lee el ticket con ML Kit **en el dispositivo** (V2-M18.02).
///
/// La foto la da `image_picker` (cámara o galería) y queda en un archivo
/// temporal que se borra en cuanto se reconoce el texto, haya salido bien o
/// no: nunca se sube ni se conserva. El texto reconocido pasa por [leerTicket].
class LectorTicketMlKit implements LectorTicket {
  LectorTicketMlKit({ImagePicker? selector, TextRecognizer? reconocedor})
    : _selector = selector ?? ImagePicker(),
      _reconocedor = reconocedor ?? TextRecognizer();

  final ImagePicker _selector;
  final TextRecognizer _reconocedor;

  @override
  Future<LecturaTicket?> leer(OrigenFoto origen) async {
    final XFile? foto;
    try {
      foto = await _selector.pickImage(
        source: origen == OrigenFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 90,
      );
    } on PlatformException catch (e) {
      throw FalloLecturaTicket(
        e.code == 'camera_access_denied' || e.code == 'photo_access_denied',
      );
    }
    if (foto == null) return null;
    try {
      final texto = await _reconocedor.processImage(
        InputImage.fromFilePath(foto.path),
      );
      return leerTicket(texto.text);
    } on Object {
      // Una foto que no se pudo reconocer deja el formulario vacío.
      return const LecturaTicket();
    } finally {
      try {
        await File(foto.path).delete();
      } on Object {
        // El archivo ya no existe o es de solo lectura: no hay nada que hacer.
      }
    }
  }
}
