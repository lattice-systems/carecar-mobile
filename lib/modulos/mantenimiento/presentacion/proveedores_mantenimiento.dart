import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_mantenimiento_api.dart';
import '../dominio/plan_mantenimiento.dart';
import '../dominio/repositorio_mantenimiento.dart';

/// Repositorio del módulo. En pruebas:
/// `repositorioMantenimientoProvider.overrideWithValue(RepositorioMantenimientoFake())`.
final repositorioMantenimientoProvider = Provider<RepositorioMantenimiento>(
  (ref) => RepositorioMantenimientoApi(ref.watch(apiClienteProvider)),
  name: 'repositorioMantenimientoProvider',
);

/// El plan de mantenimiento del vehículo `vehiculoId`. El `AsyncValue` trae
/// cargando, datos y error. Se descarta al salir de las pantallas del módulo
/// para no mostrar un próximo servicio viejo; al registrar un km se invalida.
final planMantenimientoProvider = FutureProvider.autoDispose
    .family<PlanMantenimiento, int>(
      (ref, vehiculoId) =>
          ref.watch(repositorioMantenimientoProvider).plan(vehiculoId),
      // El reintento es del usuario (botón de EstadoError), no automático.
      retry: (_, _) => null,
      name: 'planMantenimientoProvider',
    );
