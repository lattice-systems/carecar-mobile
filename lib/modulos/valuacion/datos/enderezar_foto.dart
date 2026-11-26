import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../nucleo/camara/selector_foto.dart';

/// La orientacion EXIF de un JPEG, de 1 a 8. Devuelve 1 (derecha) si no la
/// trae, si no es un JPEG o si los metadatos vienen rotos.
int orientacionExif(List<int> bytes) {
  final datos = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final vista = ByteData.sublistView(datos);
  if (datos.length < 4 || vista.getUint16(0) != 0xFFD8) return 1;
  try {
    var posicion = 2;
    while (posicion + 4 <= datos.length) {
      final marca = vista.getUint16(posicion);
      // Desde la imagen comprimida ya no hay metadatos.
      if (marca == 0xFFDA || marca >> 8 != 0xFF) return 1;
      final largo = vista.getUint16(posicion + 2);
      // El segmento APP1 que empieza con "Exif".
      if (marca == 0xFFE1 &&
          largo >= 8 &&
          vista.getUint32(posicion + 4) == 0x45786966) {
        return _orientacionTiff(vista, posicion + 10);
      }
      posicion += 2 + largo;
    }
    return 1;
  } on RangeError {
    return 1;
  }
}

int _orientacionTiff(ByteData vista, int inicio) {
  // "II" es el orden de bytes de Intel y "MM" el de Motorola.
  final orden = vista.getUint16(inicio) == 0x4949 ? Endian.little : Endian.big;
  final directorio = inicio + vista.getUint32(inicio + 4, orden);
  final entradas = vista.getUint16(directorio, orden);
  for (var i = 0; i < entradas; i++) {
    final entrada = directorio + 2 + i * 12;
    if (vista.getUint16(entrada, orden) == 0x0112) {
      final valor = vista.getUint16(entrada + 8, orden);
      return valor >= 1 && valor <= 8 ? valor : 1;
    }
  }
  return 1;
}

/// Entrega la foto con los pixeles ya girados.
///
/// El servidor borra el EXIF sin aplicar la orientacion, y en Android el
/// selector reduce la foto sin girarla: solo copia esa marca. Una foto
/// vertical llegaria acostada. El motor si respeta la marca al decodificar,
/// asi que se vuelve a escribir lo decodificado. `dart:ui` solo escribe PNG,
/// que el contrato acepta. Una foto que ya viene derecha no se toca, y si no
/// se puede decodificar se manda como llego para que el servidor decida.
Future<FotoElegida> enderezarFoto(FotoElegida foto) async {
  if (orientacionExif(foto.bytes) == 1) return foto;
  try {
    final codec = await ui.instantiateImageCodec(
      Uint8List.fromList(foto.bytes),
    );
    final imagen = (await codec.getNextFrame()).image;
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    codec.dispose();
    if (png == null) return foto;
    return FotoElegida(bytes: png.buffer.asUint8List(), tipo: 'image/png');
  } on Exception {
    return foto;
  }
}
