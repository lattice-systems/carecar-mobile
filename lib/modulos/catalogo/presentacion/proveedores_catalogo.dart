import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_catalogo_api.dart';
import '../datos/repositorio_toma_a_cuenta_api.dart';
import '../dominio/detalle_modelo.dart';
import '../dominio/modelo_vigente.dart';
import '../dominio/repositorio_catalogo.dart';
import '../dominio/repositorio_toma_a_cuenta.dart';

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

/// El detalle de un modelo por su id. Un modelo retirado o inexistente falla
/// con `NoEncontrado`, y la pantalla lo explica.
final detalleModeloProvider = FutureProvider.family<DetalleModelo, int>(
  (ref, id) => ref.watch(repositorioCatalogoProvider).detalle(id),
  retry: (_, _) => null,
  name: 'detalleModeloProvider',
);

/// Los detalles de los modelos a comparar, en el orden pedido. La clave son los
/// ids separados por comas (`'1,2,3'`), porque una lista no se compara por valor.
/// Si un modelo ya no existe falla con `NoEncontrado`.
final comparativaProvider = FutureProvider.family<List<DetalleModelo>, String>(
  (ref, ids) {
    final repositorio = ref.watch(repositorioCatalogoProvider);
    return Future.wait([
      for (final id in ids.split(',')) repositorio.detalle(int.parse(id)),
    ]);
  },
  retry: (_, _) => null,
  name: 'comparativaProvider',
);

/// Repositorio de la toma a cuenta. En pruebas:
/// `repositorioTomaACuentaProvider.overrideWithValue(...)`.
final repositorioTomaACuentaProvider = Provider<RepositorioTomaACuenta>(
  (ref) => RepositorioTomaACuentaApi(ref.watch(carecarApiProvider)),
  name: 'repositorioTomaACuentaProvider',
);
