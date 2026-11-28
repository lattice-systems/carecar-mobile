import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_local.dart';

/// La base local cifrada de los datos del cliente (V2-M21.01).
///
/// La arma `main.dart` (necesita la carpeta de la app y el almacenamiento
/// seguro) y la inyecta con `overrides`; en pruebas se usa `BaseLocalEnMemoria`.
/// Los módulos la leen de aquí y nunca importan `drift`.
final baseLocalProvider = Provider<BaseLocal>(
  (ref) => throw StateError(
    'baseLocalProvider no esta inyectado. Agrega '
    '`baseLocalProvider.overrideWithValue(...)` en el ProviderScope.',
  ),
  name: 'baseLocalProvider',
);
