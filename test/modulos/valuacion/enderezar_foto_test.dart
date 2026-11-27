import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carecar_mobile/modulos/valuacion/datos/enderezar_foto.dart';
import 'package:carecar_mobile/nucleo/camara/selector_foto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_valuacion.dart';

/// Un JPEG de 8 de ancho por 4 de alto, sin metadatos.
final _jpeg = base64Decode(
  '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAP//////////////////////////////////////'
  '////////////////////////////////////////////////2wBDAf//////////////////'
  '////////////////////////////////////////////////////////////////////wAAR'
  'CAAEAAgDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAL/xAAUEAEAAAAAAAAAAAAA'
  'AAAAAAAA/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAM'
  'AwEAAhEDEQA/AKYAH//Z',
);

/// [_jpeg] con un segmento EXIF que solo dice la orientacion, como lo deja
/// una camara en vertical.
Uint8List _conOrientacion(int orientacion) {
  final exif = <int>[
    0xFF, 0xE1, 0x00, 0x22, // APP1 de 34 bytes.
    0x45, 0x78, 0x69, 0x66, 0x00, 0x00, // "Exif".
    0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08, // TIFF Motorola.
    0x00, 0x01, // Una entrada.
    0x01, 0x12, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01,
    0x00, orientacion, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
  ];
  return Uint8List.fromList([..._jpeg.take(2), ...exif, ..._jpeg.skip(2)]);
}

Future<(int, int)> _medidas(List<int> bytes) async {
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  final imagen = (await codec.getNextFrame()).image;
  return (imagen.width, imagen.height);
}

void main() {
  test('lee la orientacion del EXIF', () {
    expect(orientacionExif(_conOrientacion(6)), 6);
    expect(orientacionExif(_conOrientacion(1)), 1);
    expect(orientacionExif(_jpeg), 1);
    expect(orientacionExif(pixel), 1);
    expect(orientacionExif(const []), 1);
    expect(orientacionExif(_conOrientacion(6).sublist(0, 14)), 1);
  });

  test(
    'una foto girada sale con los pixeles ya derechos y sin la marca',
    () async {
      final foto = FotoElegida(bytes: _conOrientacion(6), tipo: 'image/jpeg');

      final derecha = await enderezarFoto(foto);

      expect(derecha.tipo, 'image/png');
      expect(orientacionExif(derecha.bytes), 1);
      // De 8 x 4 acostada a 4 x 8 vertical.
      expect(await _medidas(derecha.bytes), (4, 8));
      expect(latin1.decode(derecha.bytes), isNot(contains('Exif')));
    },
  );

  test('una foto que ya viene derecha no se toca', () async {
    final foto = FotoElegida(bytes: _conOrientacion(1), tipo: 'image/jpeg');
    expect(await enderezarFoto(foto), same(foto));
  });

  test('si no se puede decodificar se manda como llego', () async {
    final rota = FotoElegida(
      bytes: _conOrientacion(6).sublist(0, 40),
      tipo: 'image/jpeg',
    );
    expect(await enderezarFoto(rota), same(rota));
  });
}
