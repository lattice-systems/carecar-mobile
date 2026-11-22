import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_garaje_api.dart';
import '../dominio/repositorio_garaje.dart';
import '../dominio/vehiculo_garaje.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioGarajeProvider.overrideWithValue(...)`.
final repositorioGarajeProvider = Provider<RepositorioGaraje>(
  (ref) => RepositorioGarajeApi(ref.watch(carecarApiProvider)),
  name: 'repositorioGarajeProvider',
);

/// Vehiculos del cliente. El `AsyncValue` ya trae cargando, datos y error.
final garajeProvider = FutureProvider<List<VehiculoGaraje>>(
  (ref) => ref.watch(repositorioGarajeProvider).vehiculos(),
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'garajeProvider',
);

/// Un vehiculo del garaje por su id, o `null` si ya no esta. Sale de la misma
/// lectura que el garaje, asi comparte copia guardada y recarga.
final vehiculoProvider = FutureProvider.family<VehiculoGaraje?, int>((
  ref,
  id,
) async {
  final lista = await ref.watch(garajeProvider.future);
  for (final v in lista) {
    if (v.id == id) return v;
  }
  return null;
}, name: 'vehiculoProvider');
