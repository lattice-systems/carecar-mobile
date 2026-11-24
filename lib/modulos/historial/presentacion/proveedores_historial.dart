import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/compartir_ticket.dart';
import '../datos/repositorio_historial_api.dart';
import '../dominio/orden_historial.dart';
import '../dominio/repositorio_historial.dart';
import '../dominio/ticket_servicio.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioHistorialProvider.overrideWithValue(RepositorioHistorialFake())`.
final repositorioHistorialProvider = Provider<RepositorioHistorial>(
  (ref) => RepositorioHistorialApi(ref.watch(carecarApiProvider)),
  name: 'repositorioHistorialProvider',
);

/// Cuantas ordenes se piden por pagina.
final tamanoPaginaHistorialProvider = Provider<int>(
  (ref) => 20,
  name: 'tamanoPaginaHistorialProvider',
);

/// Que historial se consulta: el vehiculo y el año (nulo para todos).
typedef ConsultaHistorial = ({int vehiculoId, int? anio});

/// Lo que el historial ya cargo: las ordenes de las paginas pedidas.
class EstadoHistorial {
  const EstadoHistorial({
    required this.ordenes,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<OrdenHistorial> ordenes;
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoHistorial copiaCon({
    List<OrdenHistorial>? ordenes,
    int? pagina,
    bool? hayMas,
    bool? cargandoMas,
    bool? errorAlCargarMas,
  }) => EstadoHistorial(
    ordenes: ordenes ?? this.ordenes,
    pagina: pagina ?? this.pagina,
    hayMas: hayMas ?? this.hayMas,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    errorAlCargarMas: errorAlCargarMas ?? this.errorAlCargarMas,
  );
}

/// Historial de un vehiculo con paginacion infinita (V2-M02.05). Pedir mas no
/// tumba lo que ya se ve.
class HistorialNotifier extends AsyncNotifier<EstadoHistorial> {
  HistorialNotifier(this.consulta);

  final ConsultaHistorial consulta;

  @override
  Future<EstadoHistorial> build() async {
    final pagina = await ref
        .watch(repositorioHistorialProvider)
        .ordenes(
          consulta.vehiculoId,
          anio: consulta.anio,
          tamano: ref.watch(tamanoPaginaHistorialProvider),
        );
    return EstadoHistorial(
      ordenes: pagina.ordenes,
      pagina: pagina.pagina,
      hayMas: pagina.hayMas,
    );
  }

  /// Pide la pagina siguiente y la suma al final. Si falla, conserva lo
  /// cargado y marca `errorAlCargarMas`.
  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    state = AsyncData(
      actual.copiaCon(cargandoMas: true, errorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(repositorioHistorialProvider)
          .ordenes(
            consulta.vehiculoId,
            anio: consulta.anio,
            pagina: actual.pagina + 1,
            tamano: ref.read(tamanoPaginaHistorialProvider),
          );
      if (!ref.mounted) return;
      state = AsyncData(
        EstadoHistorial(
          ordenes: [...actual.ordenes, ...pagina.ordenes],
          pagina: pagina.pagina,
          hayMas: pagina.hayMas,
        ),
      );
    } on Object {
      if (!ref.mounted) return;
      state = AsyncData(
        actual.copiaCon(cargandoMas: false, errorAlCargarMas: true),
      );
    }
  }
}

final historialProvider = AsyncNotifierProvider.autoDispose
    .family<HistorialNotifier, EstadoHistorial, ConsultaHistorial>(
      HistorialNotifier.new,
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'historialProvider',
    );

/// Años con servicios del vehiculo, para el filtro.
final aniosHistorialProvider = FutureProvider.autoDispose
    .family<List<int>, int>(
      (ref, vehiculoId) =>
          ref.watch(repositorioHistorialProvider).anios(vehiculoId),
      retry: (_, _) => null,
      name: 'aniosHistorialProvider',
    );

/// Ticket de la orden `servicioId` (V2-M02.06).
final ticketServicioProvider = FutureProvider.autoDispose
    .family<TicketServicio, int>(
      (ref, servicioId) =>
          ref.watch(repositorioHistorialProvider).ticket(servicioId),
      retry: (_, _) => null,
      name: 'ticketServicioProvider',
    );

/// Abre la hoja de compartir con (bytes, nombre de archivo). Las pruebas lo
/// sustituyen.
final compartirTicketProvider =
    Provider<Future<void> Function(Uint8List, String)>(
      (ref) => compartirTicketConHojaDelSistema,
      name: 'compartirTicketProvider',
    );
