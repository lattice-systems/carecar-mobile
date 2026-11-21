import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
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
    // El backend real no manda `tipo`; su `modelo` es el mismo dato.
    final tipo = (vehiculo.tipo ?? vehiculo.modelo).trim();
    if (marca == null ||
        marca.isEmpty ||
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
          '${vehiculo.marca!.trim()} ${(vehiculo.tipo ?? vehiculo.modelo).trim()} ${vehiculo.anio}',
      identificador: ruta,
      bytes: datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
    );
  }
}

/// Primero el manual que publica la agencia (`GET /vehiculos/{id}/manuales`,
/// URL firmada y temporal); si no hay, el PDF incluido en la app.
///
/// Asi el cliente ve el manual exacto de su unidad aunque la app no lo traiga,
/// y sin red sigue viendo los que si vienen incluidos.
class ManualesDeLaAgencia implements ServicioManuales {
  ManualesDeLaAgencia({
    required this.api,
    ServicioManuales? respaldo,
    http.Client? cliente,
  }) : _respaldo = respaldo ?? ManualesLocales(),
       _cliente = cliente ?? http.Client();

  final CarecarApi api;
  final ServicioManuales _respaldo;
  final http.Client _cliente;

  static const _limite = Duration(seconds: 30);

  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async {
    try {
      final manuales = await api.manualesDe(vehiculo.id);
      if (manuales.isNotEmpty) {
        final manual = manuales.first;
        final respuesta = await _cliente
            .get(Uri.parse(manual.url))
            .timeout(_limite);
        if (respuesta.statusCode == 200 && respuesta.bodyBytes.isNotEmpty) {
          return DocumentoManual(
            // El backend manda «Nissan Frontier 2024 Manual de propietario»; la
            // pantalla ya antepone «Manual», asi que se quita el sufijo.
            titulo:
                (manual.titulo ??
                        '${manual.marca ?? ''} ${manual.modelo} ${manual.anio}')
                    .replaceAll(
                      RegExp(
                        r'\s*manual de propietario$',
                        caseSensitive: false,
                      ),
                      '',
                    )
                    .trim(),
            identificador: 'agencia:${manual.id}',
            bytes: respuesta.bodyBytes,
          );
        }
      }
    } on ExcepcionApi {
      // Sin respuesta de la agencia se intenta con el incluido en la app.
    } on Exception {
      // Igual con un fallo de red al bajar el PDF.
    }
    return _respaldo.cargar(vehiculo);
  }
}
