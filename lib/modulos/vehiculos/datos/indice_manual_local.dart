import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../manuales/servicio_manuales.dart'
    show FalloManual, ResolverManual;
import '../../../api/modelos/vehiculo.dart';
import '../dominio/indice_de_manual.dart';

/// Carga el índice de texto del manual empaquetado del vehículo (V2-M02.03).
///
/// El `indice.json` vive junto al PDF; se resuelve por modelo y año igual que el
/// manual. Devuelve `null` si el vehículo no tiene manual empaquetado o el
/// índice no se pudo leer: entonces la pantalla no ofrece buscar.
Future<IndiceDeManual?> cargarIndiceDeManual(
  Vehiculo vehiculo, {
  AssetBundle? bundle,
}) async {
  final paquete = bundle ?? rootBundle;
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(paquete);
    final pdf = ResolverManual.ruta(vehiculo, manifest.listAssets());
    final ruta = '${pdf.substring(0, pdf.lastIndexOf('/') + 1)}indice.json';
    final crudo = await paquete.loadString(ruta);
    return IndiceDeManual.desdeJson(jsonDecode(crudo) as Map<String, dynamic>);
  } on FalloManual {
    return null;
  } on Exception {
    return null;
  }
}
