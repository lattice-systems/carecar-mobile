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
