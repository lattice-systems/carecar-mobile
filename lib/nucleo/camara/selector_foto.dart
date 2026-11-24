import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// De donde sale la foto.
enum OrigenFoto { camara, galeria }

/// Foto elegida, solo en memoria.
class FotoElegida {
  const FotoElegida({required this.bytes, required this.tipo});

  final List<int> bytes;

  /// `image/jpeg` o `image/png`.
  final String tipo;
}

/// La persona nego el permiso de camara o de fotos.
class PermisoFotoDenegado implements Exception {
  const PermisoFotoDenegado();
}

/// Toma o elige una foto (V2-M24.05). Los modulos usan esta interfaz y nunca
/// el paquete; en pruebas se reemplaza por un falso.
abstract interface class SelectorFoto {
  /// La foto elegida, o `null` si la persona cancelo.
  ///
  /// Falla con [PermisoFotoDenegado] si no hay permiso.
  Future<FotoElegida?> elegir(OrigenFoto origen);

  /// Abre los ajustes de la app para dar el permiso.
  Future<void> abrirAjustes();
}

/// [SelectorFoto] con `image_picker`. Pide la foto ya reducida (1600 px) y sin
/// metadatos completos, la lee y borra el archivo temporal: la foto no se
/// queda en el telefono.
class SelectorFotoDelSistema implements SelectorFoto {
  SelectorFotoDelSistema({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _ladoMaximo = 1600;
  static const int _calidad = 85;

  @override
  Future<FotoElegida?> elegir(OrigenFoto origen) async {
    final XFile? archivo;
    try {
      archivo = await _picker.pickImage(
        source: origen == OrigenFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _ladoMaximo,
        maxHeight: _ladoMaximo,
        imageQuality: _calidad,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      if (e.code.contains('access_denied')) throw const PermisoFotoDenegado();
      rethrow;
    }
    if (archivo == null) return null;
    final bytes = await archivo.readAsBytes();
    try {
      await File(archivo.path).delete();
    } on FileSystemException {
      // Si el sistema ya lo borro o no deja borrarlo, no pasa nada.
    }
    final png = archivo.path.toLowerCase().endsWith('.png');
    return FotoElegida(bytes: bytes, tipo: png ? 'image/png' : 'image/jpeg');
  }

  @override
  Future<void> abrirAjustes() => Geolocator.openAppSettings();
}
