import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/modelos/traslado.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import 'proveedores_recoleccion.dart';

/// Sigue un traslado (V2-M17.03): lo consulta al abrir y lo mantiene al día
/// con `traslado.estado` y `traslado.ubicacion`.
///
/// La ubicacion del chofer solo se acepta mientras el traslado esta en camino
/// o de regreso, que es cuando el contrato la manda; al pasar a cualquier otro
/// estado se descarta. Al reconectar el canal se vuelve a consultar, por si
/// algo se perdio. Solo escucha mientras una pantalla lo mira (`autoDispose`).
class SeguimientoTrasladoNotifier extends AsyncNotifier<TrasladoDetalle> {
  SeguimientoTrasladoNotifier(this.id);

  final int id;

  @override
  Future<TrasladoDetalle> build() {
    ref.listen(eventosProvider, (_, evento) => evento.whenData(_alLlegar));
    return ref.read(repositorioRecoleccionProvider).traslado(id);
  }

  void _alLlegar(EventoEnVivo evento) {
    if (evento.nombre == eventoReconectado) {
      refrescar();
      return;
    }
    final actual = state.value;
    if (actual == null || evento.datos['trasladoId'] != id) return;
    switch (evento.nombre) {
      case 'traslado.estado':
        state = AsyncData(
          actual.conEstado(
            EstadoTraslado.desde(evento.datos['estado'] as String?),
          ),
        );
      case 'traslado.ubicacion':
        final lat = evento.datos['lat'];
        final lng = evento.datos['lng'];
        final cuando = DateTime.tryParse('${evento.datos['actualizadaEn']}');
        if (!actual.estado.muestraChofer ||
            lat is! num ||
            lng is! num ||
            cuando == null) {
          return;
        }
        state = AsyncData(
          actual.conUbicacion(
            UbicacionChofer(
              lat: lat.toDouble(),
              lng: lng.toDouble(),
              actualizadaEn: cuando,
            ),
          ),
        );
    }
  }

  /// Vuelve a consultar sin borrar lo que ya se muestra. Si falla, el estado
  /// queda con el error **y** el ultimo valor conocido (`hasError` y `value`).
  Future<void> refrescar() async {
    // Riverpod conserva el ultimo valor al pasar a cargando o a error.
    state = const AsyncLoading<TrasladoDetalle>();
    try {
      final nuevo = await ref.read(repositorioRecoleccionProvider).traslado(id);
      if (ref.mounted) state = AsyncData(nuevo);
    } on Object catch (error, pila) {
      if (ref.mounted) state = AsyncError<TrasladoDetalle>(error, pila);
    }
  }
}

/// Seguimiento en vivo del traslado `id`.
final seguimientoTrasladoProvider = AsyncNotifierProvider.autoDispose
    .family<SeguimientoTrasladoNotifier, TrasladoDetalle, int>(
      SeguimientoTrasladoNotifier.new,
      // El reintento es de la persona (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'seguimientoTrasladoProvider',
    );
