import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_catalogo_api.dart';
import '../dominio/modelo_vigente.dart';
import '../dominio/repositorio_catalogo.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioCatalogoProvider.overrideWithValue(...)`.
final repositorioCatalogoProvider = Provider<RepositorioCatalogo>(
  (ref) => RepositorioCatalogoApi(ref.watch(carecarApiProvider)),
  name: 'repositorioCatalogoProvider',
);

/// Modelos vigentes. El `AsyncValue` ya trae cargando, datos y error.
final catalogoProvider = FutureProvider<List<ModeloVigente>>(
  (ref) => ref.watch(repositorioCatalogoProvider).modelos(),
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'catalogoProvider',
);
