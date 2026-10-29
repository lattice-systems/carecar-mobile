import 'package:flutter/services.dart';

import '../api/modelos/vehiculo.dart';

class FalloManual implements Exception {
  const FalloManual(this.mensaje);
  final String mensaje;
}

class DocumentoManual {
  const DocumentoManual({
    required this.titulo,
    required this.identificador,
    required this.bytes,
  });
  final String titulo;
  final String identificador;
  final Uint8List bytes;
}

abstract interface class ServicioManuales {
  Future<DocumentoManual> cargar(Vehiculo vehiculo);
}

/// Identifica un manual exacto sin deducir marca/tipo del nombre o del VIN.
abstract final class ResolverManual {
  static String _normalizar(String valor) =>
      valor.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

  static String identificar(Vehiculo vehiculo) {
    final marca = vehiculo.marca?.trim();
    final tipo = vehiculo.tipo?.trim();
    if (marca == null ||
        marca.isEmpty ||
        tipo == null ||
        tipo.isEmpty ||
        vehiculo.anio < 1886 ||
        [marca, tipo].any((v) => v.contains(RegExp(r'[/\\.]')))) {
      throw const FalloManual(
        'No fue posible identificar el manual correspondiente. Faltan datos válidos de marca, tipo o modelo.',
      );
    }
    final nombre = '$marca$tipo${vehiculo.anio}Manual.pdf';
    return 'assets/Manuales/$marca/$tipo/${vehiculo.anio}/$nombre';
  }

  static String ruta(Vehiculo vehiculo, Iterable<String> disponibles) {
    final esperada = identificar(vehiculo);
    final coincidencias = disponibles
        .where((ruta) => _normalizar(ruta) == _normalizar(esperada))
        .toList();
    if (coincidencias.length != 1) {
      throw const FalloManual(
        'El manual de este vehículo todavía no está disponible.',
      );
    }
    // Se devuelve el nombre real del manifest, conservando su capitalizacion.
    return coincidencias.single;
  }
}

class ManualesLocales implements ServicioManuales {
  ManualesLocales({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async {
    ResolverManual.identificar(vehiculo);
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final ruta = ResolverManual.ruta(vehiculo, manifest.listAssets());
    final datos = await _bundle.load(ruta);
    return DocumentoManual(
      titulo:
          '${vehiculo.marca!.trim()} ${vehiculo.tipo!.trim()} ${vehiculo.anio}',
      identificador: ruta,
      bytes: datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
    );
  }
}
