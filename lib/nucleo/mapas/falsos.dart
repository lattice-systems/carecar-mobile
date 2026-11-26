import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'coordenada.dart';
import 'errores_mapas.dart';
import 'fuente_teselas.dart';
import 'geocodificador.dart';
import 'proveedor_ubicacion.dart';

/// [ProveedorUbicacion] para pruebas: no toca el sistema.
///
/// Con [error] fallan las lecturas; con [permisoTrasPedir] se simula lo que
/// responde la persona al diálogo.
class UbicacionFalsa implements ProveedorUbicacion {
  UbicacionFalsa({
    this.posicion = const Coordenada(19.4326, -99.1332),
    this.error,
    PermisoUbicacion permiso = PermisoUbicacion.concedido,
    PermisoUbicacion? permisoTrasPedir,
  }) : _permiso = permiso,
       _permisoTrasPedir = permisoTrasPedir ?? permiso;

  Coordenada posicion;
  ErrorUbicacion? error;
  PermisoUbicacion _permiso;
  final PermisoUbicacion _permisoTrasPedir;

  /// Cuántas veces se pidió la posición y el permiso.
  int consultasDePosicion = 0;
  int peticionesDePermiso = 0;

  @override
  Future<PermisoUbicacion> estadoDelPermiso() async => _permiso;

  @override
  Future<PermisoUbicacion> pedirPermiso() async {
    peticionesDePermiso++;
    return _permiso = _permisoTrasPedir;
  }

  @override
  Future<Coordenada> posicionActual({
    Duration limite = const Duration(seconds: 15),
  }) async {
    consultasDePosicion++;
    final e = error;
    if (e != null) throw e;
    return posicion;
  }
}

/// [Geocodificador] para pruebas, con tablas fijas.
class GeocodificadorFalso implements Geocodificador {
  GeocodificadorFalso({
    this.coordenadasPorDireccion = const {},
    this.direccionesPorCoordenada = const {},
    this.error,
  });

  Map<String, Coordenada> coordenadasPorDireccion;
  Map<Coordenada, Direccion> direccionesPorCoordenada;
  ErrorGeocodificacion? error;

  @override
  Future<Coordenada?> coordenadasDe(String direccion) async {
    final e = error;
    if (e != null) throw e;
    return coordenadasPorDireccion[direccion];
  }

  @override
  Future<Direccion?> direccionDe(Coordenada coordenada) async {
    final e = error;
    if (e != null) throw e;
    return direccionesPorCoordenada[coordenada];
  }
}

/// [FuenteTeselas] sin red: cuadros de un color con su orilla marcada, para ver
/// en una prueba o en la galería dónde empieza cada tesela.
class TeselasLisas implements FuenteTeselas {
  TeselasLisas({
    this.fondo = const Color(0xFFDCE3EA),
    this.linea = const Color(0xFFB8C2CC),
  });

  final Color fondo;
  final Color linea;

  /// Cuántas teselas se pidieron.
  int pedidas = 0;

  late final ImageProvider _cuadro = _TeselaLisa(fondo, linea);

  @override
  ImageProvider tesela({required int x, required int y, required int zoom}) {
    pedidas++;
    return _cuadro;
  }
}

/// [FuenteTeselas] que falla como si no hubiera conexión, hasta que
/// [hayConexion] sea verdadero.
class TeselasSinConexion implements FuenteTeselas {
  bool hayConexion = false;

  final TeselasLisas _lisas = TeselasLisas();

  @override
  ImageProvider tesela({required int x, required int y, required int zoom}) =>
      hayConexion
      ? _lisas.tesela(x: x, y: y, zoom: zoom)
      : _TeselaRota('$zoom/$x/$y');
}

/// Se dibuja en memoria y llega al instante, sin decodificar ningún archivo.
@immutable
class _TeselaLisa extends ImageProvider<_TeselaLisa> {
  const _TeselaLisa(this.fondo, this.linea);

  final Color fondo;
  final Color linea;

  static const int _lado = 256;

  @override
  Future<_TeselaLisa> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_TeselaLisa key, ImageDecoderCallback decode) {
    final grabadora = ui.PictureRecorder();
    final cuadro = Offset.zero & Size.square(_lado.toDouble());
    ui.Canvas(grabadora)
      ..drawRect(cuadro, Paint()..color = fondo)
      ..drawRect(
        cuadro.deflate(1),
        Paint()
          ..color = linea
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    final imagen = grabadora.endRecording().toImageSync(_lado, _lado);
    return OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: imagen)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _TeselaLisa && other.fondo == fondo && other.linea == linea;

  @override
  int get hashCode => Object.hash(fondo, linea);
}

@immutable
class _TeselaRota extends ImageProvider<_TeselaRota> {
  const _TeselaRota(this.clave);

  final String clave;

  @override
  Future<_TeselaRota> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_TeselaRota key, ImageDecoderCallback decode) {
    // Como la descarga real, no deja el fallo en la caché: así se reintenta.
    scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
    return OneFrameImageStreamCompleter(
      Future.error(Exception('Sin conexión (simulada).')),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _TeselaRota && other.clave == clave;

  @override
  int get hashCode => clave.hashCode;
}
