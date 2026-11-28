import 'dart:typed_data';

import 'package:carecar_mobile/modulos/documentos/datos/preparar_foto_documento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as im;

void main() {
  test('recorta los bordes de una hoja clara y devuelve JPEG', () {
    final original = im.Image(240, 320);
    im.fill(original, im.getColor(25, 25, 25));
    im.fillRect(original, 25, 30, 214, 289, im.getColor(235, 235, 235));

    final jpeg = prepararFotoDocumento(
      Uint8List.fromList(im.encodePng(original)),
    );
    final foto = im.decodeJpg(jpeg)!;

    expect(foto.width, inInclusiveRange(190, 198));
    expect(foto.height, inInclusiveRange(260, 268));
    expect(jpeg.length, lessThanOrEqualTo(maximoFotoDocumento));
  });

  test('conserva el encuadre cuando no se detectan bordes seguros', () {
    final original = im.Image(120, 150);
    im.fill(original, im.getColor(225, 225, 225));

    final jpeg = prepararFotoDocumento(
      Uint8List.fromList(im.encodePng(original)),
    );
    final foto = im.decodeJpg(jpeg)!;

    expect((foto.width, foto.height), (120, 150));
  });

  test('rechaza una foto ilegible', () {
    expect(() => prepararFotoDocumento(Uint8List(0)), throwsFormatException);
  });
}
