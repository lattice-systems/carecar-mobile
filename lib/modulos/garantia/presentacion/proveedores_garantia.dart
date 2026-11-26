import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../datos/repositorio_garantia_api.dart';
import '../dominio/campana_seguridad.dart';
import '../dominio/garantia_vehiculo.dart';
import '../dominio/repositorio_garantia.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioGarantiaProvider.overrideWithValue(RepositorioGarantiaFake())`.
final repositorioGarantiaProvider = Provider<RepositorioGarantia>(
  (ref) => RepositorioGarantiaApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioGarantiaProvider',
);

/// Aviso en vivo de una campana nueva para un vehiculo (V2-M10.04).
const eventoCampanaNueva = 'campana.nueva';

/// Aviso en vivo de una garantia por vencer (V2-M10.05).
const eventoGarantiaPorVencer = 'garantia.por_vencer';

/// Si [evento] pide volver a consultar lo de [vehiculoId]: es el aviso
/// [nombre] de ese vehiculo o el canal volvio tras una caida y pudo perderse
/// alguno.
bool _tocaAlVehiculo(EventoEnVivo evento, String nombre, int vehiculoId) =>
    evento.nombre == eventoReconectado ||
    (evento.nombre == nombre && evento.datos['vehiculoId'] == vehiculoId);

/// La garantia del vehiculo (V2-M10.01). El aviso de garantia por vencer de
/// ese vehiculo la vuelve a pedir sin pasar por carga; si esa recarga falla,
/// se queda la que se ve.
class GarantiaNotifier extends AsyncNotifier<GarantiaVehiculo> {
  GarantiaNotifier(this.vehiculoId);

  final int vehiculoId;
  var _turno = 0;

  @override
  Future<GarantiaVehiculo> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when _tocaAlVehiculo(value, eventoGarantiaPorVencer, vehiculoId)) {
        _recargar();
      }
    });
    return ref.watch(repositorioGarantiaProvider).garantia(vehiculoId);
  }

  Future<void> _recargar() async {
    final turno = ++_turno;
    try {
      final garantia = await ref
          .read(repositorioGarantiaProvider)
          .garantia(vehiculoId);
      if (ref.mounted && turno == _turno) state = AsyncData(garantia);
    } on Object {
      return;
    }
  }
}

final garantiaProvider = AsyncNotifierProvider.autoDispose
    .family<GarantiaNotifier, GarantiaVehiculo, int>(
      GarantiaNotifier.new,
      retry: (_, _) => null,
      name: 'garantiaProvider',
    );

/// Las campanas de seguridad del vehiculo (V2-M10.02). Una campana nueva
/// publicada para ese vehiculo la vuelve a pedir sin pasar por carga
/// (V2-M10.04). Agendar vuelve a pedir la lista al backend.
class CampanasNotifier extends AsyncNotifier<List<CampanaSeguridad>> {
  CampanasNotifier(this.vehiculoId);

  final int vehiculoId;
  var _turno = 0;

  @override
  Future<List<CampanaSeguridad>> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when _tocaAlVehiculo(value, eventoCampanaNueva, vehiculoId)) {
        _recargar();
      }
    });
    return ref.watch(repositorioGarantiaProvider).campanas(vehiculoId);
  }

  Future<void> _recargar() async {
    final turno = ++_turno;
    try {
      final campanas = await ref
          .read(repositorioGarantiaProvider)
          .campanas(vehiculoId);
      if (ref.mounted && turno == _turno) state = AsyncData(campanas);
    } on Object {
      return;
    }
  }

  /// Agenda la atencion de la campana. Si falla, la lista no cambia y el
  /// error sube a quien llamo; si sale, se vuelve a pedir para ver la campana
  /// agendada.
  Future<CitaDeCampana> agendar({
    required int campanaId,
    required int franjaId,
    required DateTime fecha,
  }) async {
    final repositorio = ref.read(repositorioGarantiaProvider);
    final cita = await repositorio.agendarCampana(
      vehiculoId: vehiculoId,
      campanaId: campanaId,
      franjaId: franjaId,
      fecha: fecha,
    );
    if (ref.mounted) await _recargar();
    return cita;
  }
}

final campanasProvider = AsyncNotifierProvider.autoDispose
    .family<CampanasNotifier, List<CampanaSeguridad>, int>(
      CampanasNotifier.new,
      retry: (_, _) => null,
      name: 'campanasProvider',
    );

/// Si el vehiculo tiene alguna campana abierta, para la insignia del garaje
/// (V2-M10.02). Mientras carga o si falla, no hay insignia.
final hayCampanaAbiertaProvider = Provider.autoDispose.family<bool, int>(
  (ref, vehiculoId) =>
      ref
          .watch(campanasProvider(vehiculoId))
          .value
          ?.any((campana) => campana.abierta) ??
      false,
  name: 'hayCampanaAbiertaProvider',
);
