import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../datos/compartir_texto.dart';
import '../datos/repositorio_lealtad_api.dart';
import '../dominio/lealtad.dart';
import '../dominio/repositorio_lealtad.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioLealtadProvider.overrideWithValue(RepositorioLealtadFake())`.
final repositorioLealtadProvider = Provider<RepositorioLealtad>(
  (ref) => RepositorioLealtadApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioLealtadProvider',
);

/// Comparte un texto con la hoja del sistema. En pruebas se reemplaza.
final compartirTextoProvider = Provider<Future<void> Function(String)>(
  (ref) => compartirTextoConHojaDelSistema,
  name: 'compartirTextoProvider',
);

/// Aviso en vivo de que cambio el saldo de puntos (V2-M12.02).
const eventoPuntosMovidos = 'puntos.movidos';

/// Cuantos movimientos se piden por pagina.
const tamanoPaginaMovimientos = 20;

/// Si [evento] pide volver a consultar los puntos: cambiaron o el canal volvio
/// tras una caida y pudo perderse algun aviso.
bool _movieronPuntos(EventoEnVivo evento) =>
    evento.nombre == eventoPuntosMovidos || evento.nombre == eventoReconectado;

/// Base de lo que se recarga solo con `puntos.movidos` sin pasar por carga; si
/// la recarga falla, se queda lo que se ve.
abstract class _ConRecargaEnVivo<T> extends AsyncNotifier<T> {
  var _turno = 0;

  Future<T> pedir(RepositorioLealtad repositorio);

  @override
  Future<T> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value) when _movieronPuntos(value)) {
        recargar();
      }
    });
    return pedir(ref.watch(repositorioLealtadProvider));
  }

  /// Vuelve a pedir sin mostrar carga.
  Future<void> recargar() async {
    final turno = ++_turno;
    try {
      final valor = await pedir(ref.read(repositorioLealtadProvider));
      if (ref.mounted && turno == _turno) state = AsyncData(valor);
    } on Object {
      return;
    }
  }
}

/// Mis puntos y nivel (V2-M12.01).
class ResumenLealtadNotifier extends _ConRecargaEnVivo<ResumenLealtad> {
  @override
  Future<ResumenLealtad> pedir(RepositorioLealtad repositorio) =>
      repositorio.resumen();
}

final resumenLealtadProvider =
    AsyncNotifierProvider.autoDispose<ResumenLealtadNotifier, ResumenLealtad>(
      ResumenLealtadNotifier.new,
      retry: (_, _) => null,
      name: 'resumenLealtadProvider',
    );

/// Las recompensas del catalogo (V2-M12.03).
final recompensasProvider = FutureProvider.autoDispose<List<Recompensa>>(
  (ref) => ref.watch(repositorioLealtadProvider).recompensas(),
  retry: (_, _) => null,
  name: 'recompensasProvider',
);

/// Mis canjes (V2-M12.03). Canjear agrega el nuevo y vuelve a pedir el saldo
/// y las recompensas (la existencia pudo cambiar).
class CanjesNotifier extends _ConRecargaEnVivo<List<Canje>> {
  @override
  Future<List<Canje>> pedir(RepositorioLealtad repositorio) =>
      repositorio.canjes();

  /// Lanza [CanjeRechazado] si no alcanza o se agoto; la lista no cambia.
  Future<Canje> canjear(int recompensaId) async {
    final canje = await ref
        .read(repositorioLealtadProvider)
        .canjear(recompensaId);
    if (ref.mounted) {
      final actuales = state.value ?? const <Canje>[];
      state = AsyncData([canje, ...actuales.where((c) => c.id != canje.id)]);
      ref
        ..invalidate(resumenLealtadProvider)
        ..invalidate(recompensasProvider)
        ..invalidate(movimientosProvider);
    }
    return canje;
  }
}

final canjesProvider =
    AsyncNotifierProvider.autoDispose<CanjesNotifier, List<Canje>>(
      CanjesNotifier.new,
      retry: (_, _) => null,
      name: 'canjesProvider',
    );

/// Lo que los movimientos ya cargaron.
class EstadoMovimientos {
  const EstadoMovimientos({
    required this.movimientos,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<MovimientoPuntos> movimientos;
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoMovimientos copiaCon({bool? cargandoMas, bool? errorAlCargarMas}) =>
      EstadoMovimientos(
        movimientos: movimientos,
        pagina: pagina,
        hayMas: hayMas,
        cargandoMas: cargandoMas ?? this.cargandoMas,
        errorAlCargarMas: errorAlCargarMas ?? this.errorAlCargarMas,
      );
}

/// Mis movimientos con paginacion infinita (V2-M12.05). Un aviso
/// `puntos.movidos` vuelve a pedir la primera pagina; pedir mas no tumba lo
/// que ya se ve.
class MovimientosNotifier extends _ConRecargaEnVivo<EstadoMovimientos> {
  @override
  Future<EstadoMovimientos> pedir(RepositorioLealtad repositorio) async {
    final pagina = await repositorio.movimientos(
      tamano: tamanoPaginaMovimientos,
    );
    return EstadoMovimientos(
      movimientos: pagina.movimientos,
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
          .read(repositorioLealtadProvider)
          .movimientos(
            pagina: actual.pagina + 1,
            tamano: tamanoPaginaMovimientos,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        EstadoMovimientos(
          movimientos: [...actual.movimientos, ...pagina.movimientos],
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

final movimientosProvider =
    AsyncNotifierProvider.autoDispose<MovimientosNotifier, EstadoMovimientos>(
      MovimientosNotifier.new,
      retry: (_, _) => null,
      name: 'movimientosProvider',
    );

/// Mis referidos (V2-M12.04). Un aviso `puntos.movidos` los vuelve a pedir
/// porque un referido que compro da puntos.
class ReferidosNotifier extends _ConRecargaEnVivo<List<Referido>> {
  @override
  Future<List<Referido>> pedir(RepositorioLealtad repositorio) =>
      repositorio.referidos();

  /// Lanza [ReferidoRechazado] si ya es cliente, ya lo refirieron o hay el
  /// maximo abierto; la lista no cambia.
  Future<Referido> referir({
    required String nombre,
    String? telefono,
    String? correo,
  }) async {
    final referido = await ref
        .read(repositorioLealtadProvider)
        .referir(nombre: nombre, telefono: telefono, correo: correo);
    if (ref.mounted) {
      final actuales = state.value ?? const <Referido>[];
      state = AsyncData([referido, ...actuales]);
    }
    return referido;
  }
}

final referidosProvider =
    AsyncNotifierProvider.autoDispose<ReferidosNotifier, List<Referido>>(
      ReferidosNotifier.new,
      retry: (_, _) => null,
      name: 'referidosProvider',
    );
