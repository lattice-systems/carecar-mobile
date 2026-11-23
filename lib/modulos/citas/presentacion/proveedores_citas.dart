import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_citas_api.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/comprobante_de_cita.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/repositorio_citas.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioCitasProvider.overrideWithValue(RepositorioCitasFake())`.
final repositorioCitasProvider = Provider<RepositorioCitas>(
  (ref) => RepositorioCitasApi(ref.watch(carecarApiProvider)),
  name: 'repositorioCitasProvider',
);

/// Reloj del modulo: de donde sale "hoy". Se sustituye en pruebas para que no
/// dependan de la fecha real.
final relojCitasProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'relojCitasProvider',
);

/// Cuantos dias hacia adelante se puede agendar.
const diasAgendables = 60;

/// Primer y ultimo dia que el calendario deja elegir: de hoy a `diasAgendables`.
final rangoAgendableProvider = Provider<({DateTime desde, DateTime hasta})>((
  ref,
) {
  final ahora = ref.watch(relojCitasProvider)();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  return (
    desde: hoy,
    hasta: DateTime(hoy.year, hoy.month, hoy.day + diasAgendables),
  );
}, name: 'rangoAgendableProvider');

/// Disponibilidad del taller en el rango agendable. El `AsyncValue` ya trae
/// cargando, datos y error.
final disponibilidadProvider = FutureProvider<DisponibilidadTaller>(
  (ref) {
    final rango = ref.watch(rangoAgendableProvider);
    return ref
        .watch(repositorioCitasProvider)
        .disponibilidad(desde: rango.desde, hasta: rango.hasta);
  },
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'disponibilidadProvider',
);

/// Cuantas citas se piden por página en «Mis citas».
final tamanoPaginaCitasProvider = Provider<int>(
  (ref) => 20,
  name: 'tamanoPaginaCitasProvider',
);

/// Lo que «Mis citas» ya cargó: las citas de las páginas pedidas hasta ahora.
class EstadoMisCitas {
  const EstadoMisCitas({
    required this.citas,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<CitaCliente> citas;

  /// Última página ya cargada, empezando en 0.
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoMisCitas copiaCon({
    List<CitaCliente>? citas,
    int? pagina,
    bool? hayMas,
    bool? cargandoMas,
    bool? errorAlCargarMas,
  }) => EstadoMisCitas(
    citas: citas ?? this.citas,
    pagina: pagina ?? this.pagina,
    hayMas: hayMas ?? this.hayMas,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    errorAlCargarMas: errorAlCargarMas ?? this.errorAlCargarMas,
  );
}

/// Citas del cliente con paginación. El `AsyncValue` ya trae cargando, datos y
/// error de la primera página; pedir más no tumba lo que ya se ve.
class MisCitasNotifier extends AsyncNotifier<EstadoMisCitas> {
  @override
  Future<EstadoMisCitas> build() async {
    final pagina = await ref
        .watch(repositorioCitasProvider)
        .misCitas(pagina: 0, tamano: ref.watch(tamanoPaginaCitasProvider));
    return EstadoMisCitas(
      citas: pagina.citas,
      pagina: pagina.pagina,
      hayMas: pagina.hayMas,
    );
  }

  /// Pide la página siguiente y la suma al final. Si falla, conserva lo
  /// cargado y marca `errorAlCargarMas` para que la pantalla lo diga.
  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    state = AsyncData(
      actual.copiaCon(cargandoMas: true, errorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(repositorioCitasProvider)
          .misCitas(
            pagina: actual.pagina + 1,
            tamano: ref.read(tamanoPaginaCitasProvider),
          );
      state = AsyncData(
        EstadoMisCitas(
          citas: [...actual.citas, ...pagina.citas],
          pagina: pagina.pagina,
          hayMas: pagina.hayMas,
        ),
      );
    } on Object {
      state = AsyncData(
        actual.copiaCon(cargandoMas: false, errorAlCargarMas: true),
      );
    }
  }

  /// Sustituye en la lista la cita que cambió (cancelada o reprogramada) sin
  /// volver a pedir todo.
  void reemplazar(CitaCliente nueva) {
    final actual = state.value;
    if (actual == null) return;
    state = AsyncData(
      actual.copiaCon(
        citas: [for (final c in actual.citas) c.id == nueva.id ? nueva : c],
      ),
    );
  }
}

final misCitasProvider =
    AsyncNotifierProvider<MisCitasNotifier, EstadoMisCitas>(
      MisCitasNotifier.new,
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'misCitasProvider',
    );

/// Comprobante de la cita `citaId` con el codigo firmado para el QR
/// (V2-M02.11). Se descarta al salir de la pantalla: el codigo no se conserva.
final comprobanteCitaProvider = FutureProvider.autoDispose
    .family<ComprobanteDeCita, int>(
      (ref, citaId) => ref.watch(repositorioCitasProvider).comprobante(citaId),
      retry: (_, _) => null,
      name: 'comprobanteCitaProvider',
    );
