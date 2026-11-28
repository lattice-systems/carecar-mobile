import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_preferencias_api.dart';
import '../dominio/aviso_cliente.dart';
import '../dominio/preferencias_de_avisos.dart';

final repositorioPreferenciasProvider = Provider<RepositorioPreferenciasAvisos>(
  (ref) => RepositorioPreferenciasAvisosApi(ref.watch(carecarApiProvider)),
  name: 'repositorioPreferenciasProvider',
);

/// Las preferencias de avisos, que **se guardan al tocar** · V2-M06.05.
///
/// No hay boton de guardar: una pantalla de interruptores con boton obliga a
/// recordar que falta confirmar, y la mitad de la gente se sale sin tocarlo.
///
/// El precio de eso es que cada cambio tiene que pintarse al instante y
/// **revertirse si el servidor falla**: un interruptor que se queda mintiendo
/// es peor que uno lento, porque la persona creeria que apago algo que sigue
/// encendido.
class PreferenciasDeAvisosNotifier extends AsyncNotifier<PreferenciasDeAvisos> {
  /// Si el ultimo intento de guardar fallo. La pantalla lo dice y se limpia
  /// solo en cuanto uno funciona.
  bool ultimoFallo = false;

  @override
  Future<PreferenciasDeAvisos> build() =>
      ref.watch(repositorioPreferenciasProvider).preferencias();

  Future<void> cambiar(CategoriaDeAviso categoria, bool recibir) async {
    final actual = state.value;
    if (actual == null) return;
    await _guardar(actual, actual.con(categoria, recibir));
  }

  Future<void> ponerHorario(HorarioSilencioso horario) async {
    final actual = state.value;
    if (actual == null) return;
    await _guardar(actual, actual.conHorario(horario));
  }

  Future<void> quitarHorario() async {
    final actual = state.value;
    if (actual == null) return;
    await _guardar(actual, actual.sinHorario());
  }

  /// Pinta [nuevas], guarda, y vuelve a [antes] si el servidor no acepto.
  Future<void> _guardar(
    PreferenciasDeAvisos antes,
    PreferenciasDeAvisos nuevas,
  ) async {
    ultimoFallo = false;
    state = AsyncData(nuevas);
    try {
      // Se usa lo que contesta el servidor, no lo que se mando: si el backend
      // normaliza algo, la pantalla queda con la verdad.
      state = AsyncData(
        await ref.read(repositorioPreferenciasProvider).guardar(nuevas),
      );
    } on Object {
      ultimoFallo = true;
      state = AsyncData(antes);
    }
  }
}

final preferenciasDeAvisosProvider =
    AsyncNotifierProvider<PreferenciasDeAvisosNotifier, PreferenciasDeAvisos>(
      PreferenciasDeAvisosNotifier.new,
      name: 'preferenciasDeAvisosProvider',
    );
