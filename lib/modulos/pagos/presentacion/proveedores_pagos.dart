import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../datos/pasarela_simulada.dart';
import '../datos/repositorio_pagos_api.dart';
import '../dominio/pagos.dart';
import '../dominio/repositorio_pagos.dart';
import '../dominio/tarjetas.dart';

/// Aviso en vivo de que una orden del cliente quedo pagada (V2-M08.02).
const eventoPagoConfirmado = 'pago.confirmado';

/// Cuantos pagos se piden por pagina (V2-M08.07).
const tamanoPaginaPagos = 20;

/// Repositorio de pagos. En pruebas:
/// `repositorioPagosProvider.overrideWithValue(RepositorioPagosFake(...))`.
final repositorioPagosProvider = Provider<RepositorioPagos>(
  (ref) => RepositorioPagosApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioPagosProvider',
);

/// La pasarela que convierte la tarjeta escrita en token. Hoy, la simulada
/// (ADR 0009).
final pasarelaPagoProvider = Provider<PasarelaPago>(
  (ref) => const PasarelaSimulada(),
  name: 'pasarelaPagoProvider',
);

/// La fecha de hoy para revisar vencimientos. En pruebas se fija.
final hoyPagosProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'hoyPagosProvider',
);

/// Si [evento] pide volver a consultar los pagos: se confirmo uno o el canal
/// volvio tras una caida y pudo perderse algun aviso.
bool _cambiaronPagos(EventoEnVivo evento) =>
    evento.nombre == eventoPagoConfirmado || evento.nombre == eventoReconectado;

/// Lo que se cobra de una orden y si se puede pagar.
final ordenPorPagarProvider = FutureProvider.autoDispose
    .family<OrdenPorPagar, int>(
      (ref, ordenId) => ref.watch(repositorioPagosProvider).orden(ordenId),
      retry: (_, _) => null,
      name: 'ordenPorPagarProvider',
    );

/// Un pago. Se recarga solo con `pago.confirmado`.
class PagoNotifier extends AsyncNotifier<Pago> {
  PagoNotifier(this.pagoId);

  final int pagoId;

  @override
  Future<Pago> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value) when _cambiaronPagos(value)) {
        _recargar();
      }
    });
    return ref.watch(repositorioPagosProvider).pago(pagoId);
  }

  /// Responde el 3-D Secure; lanza [PagoRechazado] si ya no lo espera.
  Future<Pago> autenticar({required bool confirmada}) async {
    final pago = await ref
        .read(repositorioPagosProvider)
        .autenticar(pagoId, confirmada: confirmada);
    if (ref.mounted) state = AsyncData(pago);
    return pago;
  }

  Future<void> _recargar() async {
    try {
      final pago = await ref.read(repositorioPagosProvider).pago(pagoId);
      if (ref.mounted) state = AsyncData(pago);
    } on Object {
      return;
    }
  }
}

final pagoProvider = AsyncNotifierProvider.autoDispose
    .family<PagoNotifier, Pago, int>(
      PagoNotifier.new,
      retry: (_, _) => null,
      name: 'pagoProvider',
    );

/// Lo que mis pagos ya cargaron.
class EstadoPagos {
  const EstadoPagos({
    required this.pagos,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<Pago> pagos;
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoPagos copiaCon({bool? cargandoMas, bool? errorAlCargarMas}) =>
      EstadoPagos(
        pagos: pagos,
        pagina: pagina,
        hayMas: hayMas,
        cargandoMas: cargandoMas ?? this.cargandoMas,
        errorAlCargarMas: errorAlCargarMas ?? this.errorAlCargarMas,
      );
}

/// Mis pagos con paginacion infinita (V2-M08.07). `pago.confirmado` vuelve a
/// pedir la primera pagina sin pasar por carga; pedir mas no tumba lo que ya
/// se ve.
class PagosNotifier extends AsyncNotifier<EstadoPagos> {
  var _turno = 0;

  @override
  Future<EstadoPagos> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value) when _cambiaronPagos(value)) {
        recargar();
      }
    });
    return _primera(ref.watch(repositorioPagosProvider));
  }

  static Future<EstadoPagos> _primera(RepositorioPagos repositorio) async {
    final pagina = await repositorio.pagos(tamano: tamanoPaginaPagos);
    return EstadoPagos(
      pagos: pagina.pagos,
      pagina: pagina.pagina,
      hayMas: pagina.hayMas,
    );
  }

  Future<void> recargar() async {
    final turno = ++_turno;
    try {
      final valor = await _primera(ref.read(repositorioPagosProvider));
      if (ref.mounted && turno == _turno) state = AsyncData(valor);
    } on Object {
      return;
    }
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
          .read(repositorioPagosProvider)
          .pagos(pagina: actual.pagina + 1, tamano: tamanoPaginaPagos);
      if (!ref.mounted) return;
      state = AsyncData(
        EstadoPagos(
          pagos: [...actual.pagos, ...pagina.pagos],
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

final pagosProvider =
    AsyncNotifierProvider.autoDispose<PagosNotifier, EstadoPagos>(
      PagosNotifier.new,
      retry: (_, _) => null,
      name: 'pagosProvider',
    );

/// Mis tarjetas guardadas (V2-M08.04), la predeterminada primero. Marcar la
/// predeterminada o borrar vuelven a pedir la lista.
class MetodosPagoNotifier extends AsyncNotifier<List<MetodoPago>> {
  @override
  Future<List<MetodoPago>> build() =>
      ref.watch(repositorioPagosProvider).metodos();

  Future<void> predeterminar(int metodoPagoId) async {
    await ref.read(repositorioPagosProvider).predeterminar(metodoPagoId);
    await _recargar();
  }

  Future<void> borrar(int metodoPagoId) async {
    await ref.read(repositorioPagosProvider).borrarMetodo(metodoPagoId);
    await _recargar();
  }

  /// Vuelve a pedir sin pasar por carga; si falla, se queda lo que se veia.
  Future<void> recargar() => _recargar();

  Future<void> _recargar() async {
    if (!ref.mounted) return;
    try {
      final metodos = await ref.read(repositorioPagosProvider).metodos();
      if (ref.mounted) state = AsyncData(metodos);
    } on Object {
      return;
    }
  }
}

final metodosPagoProvider =
    AsyncNotifierProvider.autoDispose<MetodosPagoNotifier, List<MetodoPago>>(
      MetodosPagoNotifier.new,
      retry: (_, _) => null,
      name: 'metodosPagoProvider',
    );
