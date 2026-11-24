import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/modelos/traslado.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_recoleccion_api.dart';
import '../dominio/cotizacion_recoleccion.dart';
import '../dominio/direccion_guardada.dart';
import '../dominio/repositorio_recoleccion.dart';

/// Repositorio del módulo. En pruebas:
/// `repositorioRecoleccionProvider.overrideWithValue(RepositorioRecoleccionFake())`.
final repositorioRecoleccionProvider = Provider<RepositorioRecoleccion>(
  (ref) => RepositorioRecoleccionApi(ref.watch(apiClienteProvider)),
  name: 'repositorioRecoleccionProvider',
);

/// Las direcciones guardadas. El `AsyncValue` trae cargando, datos y error;
/// guardar, editar y borrar actualizan la lista sin volver a pedirla.
class DireccionesNotifier extends AsyncNotifier<List<DireccionGuardada>> {
  @override
  Future<List<DireccionGuardada>> build() =>
      ref.watch(repositorioRecoleccionProvider).direcciones();

  RepositorioRecoleccion get _repo => ref.read(repositorioRecoleccionProvider);

  /// Guarda y suma al final. Relanza `FueraDeCobertura` y los errores de red.
  Future<DireccionGuardada> guardar(BorradorDireccion borrador) async {
    final creada = await _repo.guardar(borrador);
    state = AsyncData([...?state.value, creada]);
    return creada;
  }

  /// Edita y sustituye en la lista.
  Future<DireccionGuardada> editar(int id, BorradorDireccion borrador) async {
    final editada = await _repo.editar(id, borrador);
    state = AsyncData([
      for (final d in state.value ?? const <DireccionGuardada>[])
        d.id == id ? editada : d,
    ]);
    return editada;
  }

  /// Borra y quita de la lista. Si la dirección está en uso lanza
  /// `DireccionEnUso` y la lista queda igual.
  Future<void> borrar(int id) async {
    await _repo.borrar(id);
    state = AsyncData([
      for (final d in state.value ?? const <DireccionGuardada>[])
        if (d.id != id) d,
    ]);
  }
}

final direccionesProvider =
    AsyncNotifierProvider<DireccionesNotifier, List<DireccionGuardada>>(
      DireccionesNotifier.new,
      // El reintento es del usuario (botón de EstadoError), no automático.
      retry: (_, _) => null,
      name: 'direccionesProvider',
    );

/// Qué se cotiza: una dirección guardada y el día de la cita.
typedef ClaveCotizacion = ({int direccionId, DateTime fecha});

/// Costo y franjas de recoger y entregar. Se descarta al salir de la pantalla
/// para no mostrar un precio viejo.
final cotizacionRecoleccionProvider = FutureProvider.autoDispose
    .family<CotizacionRecoleccion, ClaveCotizacion>(
      (ref, clave) => ref
          .watch(repositorioRecoleccionProvider)
          .cotizar(direccionId: clave.direccionId, fecha: clave.fecha),
      retry: (_, _) => null,
      name: 'cotizacionRecoleccionProvider',
    );

/// El checklist del traslado `trasladoId`, o `null` si aún no existe. Se
/// descarta al salir de la pantalla: las URLs de las fotos vienen firmadas y
/// duran 15 minutos, así que nunca se reutiliza un checklist viejo.
final checklistTrasladoProvider = FutureProvider.autoDispose
    .family<ChecklistTraslado?, int>(
      (ref, trasladoId) =>
          ref.watch(repositorioRecoleccionProvider).checklist(trasladoId),
      retry: (_, _) => null,
      name: 'checklistTrasladoProvider',
    );
