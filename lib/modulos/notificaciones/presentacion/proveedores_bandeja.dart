import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_avisos_api.dart';
import '../dominio/aviso_cliente.dart';

final repositorioAvisosProvider = Provider<RepositorioAvisos>(
  (ref) => RepositorioAvisosApi(ref.watch(carecarApiProvider)),
  name: 'repositorioAvisosProvider',
);

/// Cuantos avisos trae cada pagina.
final tamanoPaginaAvisosProvider = Provider<int>(
  (ref) => 20,
  name: 'tamanoPaginaAvisosProvider',
);

/// La bandeja cargada hasta ahora · V2-M06.04.
class EstadoBandeja {
  const EstadoBandeja({
    required this.avisos,
    required this.pagina,
    required this.hayMas,
    required this.noLeidos,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<AvisoCliente> avisos;

  /// Ultima pagina ya cargada, empezando en 0.
  final int pagina;
  final bool hayMas;

  /// Sin leer en **toda la cuenta**, no en lo cargado: es lo que va en el
  /// contador. Con la bandeja a medio paginar, contar lo cargado dejaria un
  /// numero mas chico que el real.
  final int noLeidos;

  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoBandeja copiaCon({
    List<AvisoCliente>? avisos,
    int? pagina,
    bool? hayMas,
    int? noLeidos,
    bool? cargandoMas,
    bool? errorAlCargarMas,
  }) => EstadoBandeja(
    avisos: avisos ?? this.avisos,
    pagina: pagina ?? this.pagina,
    hayMas: hayMas ?? this.hayMas,
    noLeidos: noLeidos ?? this.noLeidos,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    errorAlCargarMas: errorAlCargarMas ?? this.errorAlCargarMas,
  );
}

class BandejaNotifier extends AsyncNotifier<EstadoBandeja> {
  @override
  Future<EstadoBandeja> build() async {
    final pagina = await ref
        .watch(repositorioAvisosProvider)
        .bandeja(pagina: 0, tamano: ref.watch(tamanoPaginaAvisosProvider));
    return EstadoBandeja(
      avisos: pagina.avisos,
      pagina: pagina.pagina,
      hayMas: pagina.hayMas,
      noLeidos: pagina.noLeidos,
    );
  }

  /// Pide la pagina siguiente y la suma al final. Si falla, conserva lo
  /// cargado y lo marca para que la pantalla lo diga.
  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    state = AsyncData(
      actual.copiaCon(cargandoMas: true, errorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(repositorioAvisosProvider)
          .bandeja(
            pagina: actual.pagina + 1,
            tamano: ref.read(tamanoPaginaAvisosProvider),
          );
      state = AsyncData(
        EstadoBandeja(
          avisos: [...actual.avisos, ...pagina.avisos],
          pagina: pagina.pagina,
          hayMas: pagina.hayMas,
          noLeidos: pagina.noLeidos,
        ),
      );
    } on Object {
      state = AsyncData(
        actual.copiaCon(cargandoMas: false, errorAlCargarMas: true),
      );
    }
  }

  /// Marca uno como leido. Se pinta leido **antes** de que el servidor
  /// conteste: abrir un aviso no debe sentirse lento, y si la llamada falla lo
  /// peor es que vuelva a verse sin leer al recargar.
  Future<void> marcarLeido(int avisoId) async {
    final actual = state.value;
    if (actual == null) return;
    final estaba = actual.avisos.firstWhere((a) => a.id == avisoId).leida;
    if (estaba) return;
    state = AsyncData(
      actual.copiaCon(
        avisos: [
          for (final a in actual.avisos) a.id == avisoId ? a.comoLeida() : a,
        ],
        noLeidos: (actual.noLeidos - 1).clamp(0, actual.noLeidos),
      ),
    );
    try {
      await ref.read(repositorioAvisosProvider).marcarLeido(avisoId);
    } on Object {
      // Se deja como leido en la pantalla: el servidor es idempotente y la
      // proxima carga manda la verdad.
    }
  }

  /// Marca todos como leidos.
  Future<void> marcarTodosLeidos() async {
    final actual = state.value;
    if (actual == null || actual.noLeidos == 0) return;
    state = AsyncData(
      actual.copiaCon(
        avisos: [for (final a in actual.avisos) a.comoLeida()],
        noLeidos: 0,
      ),
    );
    try {
      await ref.read(repositorioAvisosProvider).marcarTodosLeidos();
    } on Object {
      // Si falla, al recargar la bandeja vuelven a aparecer sin leer. Mejor
      // eso que dejar la lista a medias mientras la persona mira.
    }
  }
}

final bandejaProvider = AsyncNotifierProvider<BandejaNotifier, EstadoBandeja>(
  BandejaNotifier.new,
  name: 'bandejaProvider',
);

/// Cuantos avisos sin leer hay, para el contador.
///
/// Es `0` mientras la bandeja carga o si falla: un contador no debe inventar
/// un numero ni quedarse pegado en el anterior.
final avisosSinLeerProvider = Provider<int>(
  (ref) => ref.watch(bandejaProvider).value?.noLeidos ?? 0,
  name: 'avisosSinLeerProvider',
);
