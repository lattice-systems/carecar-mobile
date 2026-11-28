import 'dart:typed_data';

import 'package:image/image.dart' as im;

const maximoFotoDocumento = 5 * 1024 * 1024;

Uint8List prepararFotoDocumento(Uint8List original) {
  final decodificada = _decodificarFoto(original);

  var foto = im.bakeOrientation(decodificada);
  if (foto.width > 2200 || foto.height > 2200) {
    foto = foto.width > foto.height
        ? im.copyResize(
            foto,
            width: 2200,
            interpolation: im.Interpolation.average,
          )
        : im.copyResize(
            foto,
            height: 2200,
            interpolation: im.Interpolation.average,
          );
  }
  foto = _recortarBordes(foto)..exif = im.ExifData();

  for (final calidad in [85, 70, 55]) {
    final jpeg = im.encodeJpg(foto, quality: calidad);
    if (jpeg.length <= maximoFotoDocumento) return Uint8List.fromList(jpeg);
  }

  throw const FormatException('La foto comprimida supera los 5 MB.');
}

im.Image _decodificarFoto(Uint8List original) {
  const ilegible = FormatException('No se pudo leer la foto.');
  try {
    return im.decodeImage(original) ?? (throw ilegible);
  } on RangeError {
    throw ilegible;
  } on im.ImageException {
    throw ilegible;
  }
}

im.Image _recortarBordes(im.Image foto) {
  // Las proyecciones de una hoja clara sobre un fondo oscuro delimitan
  // sus bordes. Se conserva la foto completa cuando la detección es dudosa.
  final muestra = foto.width > foto.height
      ? im.copyResize(foto, width: 160)
      : im.copyResize(foto, height: 160);
  final ancho = muestra.width;
  final alto = muestra.height;
  final esquinas = [
    muestra.getPixel(0, 0),
    muestra.getPixel(ancho - 1, 0),
    muestra.getPixel(0, alto - 1),
    muestra.getPixel(ancho - 1, alto - 1),
  ].map(im.getLuminance);
  final fondo = esquinas.reduce((a, b) => a > b ? a : b);
  if (fondo > 155) return foto;

  final totalPorFila = List<int>.filled(alto, 0);
  final totalPorColumna = List<int>.filled(ancho, 0);
  for (var y = 0; y < alto; y++) {
    for (var x = 0; x < ancho; x++) {
      if (im.getLuminance(muestra.getPixel(x, y)) >= fondo + 45) {
        totalPorFila[y]++;
        totalPorColumna[x]++;
      }
    }
  }

  final izq = totalPorColumna.indexWhere((total) => total >= alto * .4);
  final der = totalPorColumna.lastIndexWhere((total) => total >= alto * .4);
  final arriba = totalPorFila.indexWhere((total) => total >= ancho * .4);
  final abajo = totalPorFila.lastIndexWhere((total) => total >= ancho * .4);
  if (izq <= 0 ||
      arriba <= 0 ||
      der >= ancho - 1 ||
      abajo >= alto - 1 ||
      der - izq < ancho * .45 ||
      abajo - arriba < alto * .45) {
    return foto;
  }

  final x = ((izq - 1) * foto.width / ancho).floor();
  final y = ((arriba - 1) * foto.height / alto).floor();
  final limiteX = ((der + 2) * foto.width / ancho).ceil().clamp(0, foto.width);
  final limiteY = ((abajo + 2) * foto.height / alto).ceil().clamp(
    0,
    foto.height,
  );
  return im.copyCrop(foto, x, y, limiteX - x, limiteY - y);
}
