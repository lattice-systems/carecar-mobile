/// Direccion de la API, configurable al compilar.
///
/// Cumple el criterio de TEC-5: «capa de acceso a datos con direccion
/// configurable, simulada o real». Cambiar de la API simulada a la real es
/// cambiar este valor, sin tocar una sola pantalla.
///
/// ```bash
/// flutter run --flavor desarrollo -t lib/main_desarrollo.dart \
///   --dart-define=API_BASE_URL=http://localhost:3000/api/v1/app
/// ```
///
/// Cada flavor (V2-T01.04) trae una direccion por omision, asi que
/// `--dart-define` solo hace falta para sobrescribirla.
///
/// El nombre que manda es `API_BASE_URL`, que es como lo nombro Ricardo en
/// RIC-20 para los tres ambientes. Se sigue aceptando `API_URL`, el nombre que
/// uso el Sprint 1, para no romper los comandos ya escritos.
library;

import 'dart:io' show Platform;

import '../config/flavor.dart';

/// La direccion configurada no sirve.
class ApiConfigInvalida implements Exception {
  ApiConfigInvalida(this.motivo);

  final String motivo;

  @override
  String toString() =>
      'La direccion de la API no es valida: $motivo.\n'
      'Pasala al compilar, por ejemplo:\n'
      '  flutter run --flavor desarrollo -t lib/main_desarrollo.dart --dart-define=API_BASE_URL=http://localhost:3000/api/v1/app\n'
      'Las direcciones segun donde corre la app estan en mock_api/README.md.';
}

class ApiConfig {
  ApiConfig._(this.base);

  /// Direccion del flavor en ejecucion, o la de `--dart-define=API_BASE_URL`.
  factory ApiConfig.desdeEntorno({Flavor? flavor}) => ApiConfig.resolver(
    flavor ?? Flavor.actual,
    sobrescritura: _base.isNotEmpty ? _base : _heredado,
    esAndroid: Platform.isAndroid,
  );

  /// Elige la direccion: [sobrescritura] si viene, si no la del [flavor].
  ///
  /// Un flavor sin permiso de http en claro (`pruebas`, `produccion`) rechaza
  /// `http://` aunque se lo pasen: asi coincide con el bloqueo nativo.
  factory ApiConfig.resolver(
    Flavor flavor, {
    String sobrescritura = '',
    required bool esAndroid,
  }) => ApiConfig.para(
    sobrescritura.trim().isNotEmpty
        ? sobrescritura
        : flavor.urlPorOmision(esAndroid: esAndroid),
    permitirHttp: flavor.permiteHttpEnClaro,
  );

  factory ApiConfig.para(String url, {bool permitirHttp = true}) {
    if (url.trim().isEmpty) {
      throw ApiConfigInvalida('esta vacia');
    }

    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.isAbsolute) {
      throw ApiConfigInvalida('«$url» no es una direccion absoluta');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ApiConfigInvalida('el esquema «${uri.scheme}» no es http ni https');
    }

    if (uri.scheme == 'http' && !permitirHttp) {
      throw ApiConfigInvalida(
        'este ambiente solo acepta https y «$url» usa http',
      );
    }

    // Se quita la diagonal final para que `ruta('/vehiculos')` no genere `//`.
    final sinDiagonal = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;

    return ApiConfig._(uri.replace(path: sinDiagonal));
  }

  static const String _base = String.fromEnvironment('API_BASE_URL');

  /// Nombre del Sprint 1. Se acepta para no romper comandos ya escritos.
  static const String _heredado = String.fromEnvironment('API_URL');

  /// Direccion base, siempre sin diagonal final.
  final Uri base;

  /// Arma la direccion de un endpoint del contrato.
  ///
  /// Los valores nulos de [consulta] se omiten, para no mandar
  /// `?estado=null` cuando un filtro es opcional.
  Uri ruta(String camino, {Map<String, String?>? consulta}) {
    final parametros = <String, String>{
      for (final p in (consulta ?? const <String, String?>{}).entries)
        if (p.value != null) p.key: p.value!,
    };

    return base.replace(
      path: '${base.path}$camino',
      queryParameters: parametros.isEmpty ? null : parametros,
    );
  }
}
