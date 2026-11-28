import 'package:flutter/painting.dart';

import '../../../nucleo/autos/foto_de_modelo.dart';

/// La foto del modelo que viene en la app (`assets/autos/`), para cuando la
/// del catálogo falta o no carga (sin conexión). `null` si no hay para ese
/// modelo; entonces la tarjeta muestra la silueta.
ImageProvider? fotoIncluidaDeModelo(String titulo) {
  final ruta = fotoDeModelo(titulo);
  return ruta == null ? null : AssetImage(ruta);
}
