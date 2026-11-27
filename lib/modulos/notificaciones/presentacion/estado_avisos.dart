import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/avisos/explicacion_de_avisos.dart';
import '../../../nucleo/idioma/proveedores_idioma.dart';
import '../dominio/avisos_del_sistema.dart';

/// En que anda el permiso de avisos · V2-M06.01.
enum EstadoAvisos {
  /// Nadie ha explicado nada y el sistema no se ha tocado.
  sinPreguntar,

  /// La persona dijo que si y el sistema lo concedio.
  permitidos,

  /// Dijo «ahora no», o el sistema lo nego. **La app funciona igual.**
  negados,
}

/// El permiso de avisos, que **nunca se pide sin explicar antes**.
///
/// El orden importa y es el criterio de la historia: primero la pantalla que
/// dice para que sirven, y solo si la persona acepta se dispara el dialogo del
/// sistema. Pedirlo en frio es como se pierde el permiso para siempre: en
/// Android 13 y despues el dialogo **no se repite**.
///
/// **Sin preferencias se responde `sinPreguntar`.** Es el estado inofensivo:
/// no promete avisos que no van a llegar.
class PermisoDeAvisos extends Notifier<EstadoAvisos> {
  @override
  EstadoAvisos build() {
    final prefs = ref.read(preferenciasProvider);
    if (prefs == null) return EstadoAvisos.sinPreguntar;
    if (!(prefs.getBool(claveAvisosRespondido) ?? false)) {
      return EstadoAvisos.sinPreguntar;
    }
    return (prefs.getBool(claveAvisosPermitidos) ?? false)
        ? EstadoAvisos.permitidos
        : EstadoAvisos.negados;
  }

  /// La persona acepto en la pantalla previa: ahora si se le pide al sistema.
  Future<bool> pedir() async {
    final sistema = ref.read(avisosDelSistemaProvider);
    final concedido = (await sistema?.pedirPermiso()) ?? false;
    await _guardar(concedido);
    return concedido;
  }

  /// Dijo «ahora no». Al sistema no se le molesta: el dialogo se gasta una
  /// sola vez y conviene guardarlo para cuando de verdad lo quiera.
  Future<void> ahoraNo() => _guardar(false);

  /// Manda a la pantalla de ajustes del sistema, la unica salida cuando ya
  /// nego. No cambia el estado: se sabra al volver, cuando se vuelva a pedir.
  Future<void> abrirAjustes() async =>
      ref.read(avisosDelSistemaProvider)?.abrirAjustes();

  Future<void> _guardar(bool permitidos) async {
    state = permitidos ? EstadoAvisos.permitidos : EstadoAvisos.negados;
    // Contesto: la compuerta de la guardia se cierra y la app sigue su camino.
    ref.read(avisosPorExplicarProvider.notifier).listo();
    final prefs = ref.read(preferenciasProvider);
    await prefs?.setBool(claveAvisosRespondido, true);
    await prefs?.setBool(claveAvisosPermitidos, permitidos);
  }
}

final permisoDeAvisosProvider = NotifierProvider<PermisoDeAvisos, EstadoAvisos>(
  PermisoDeAvisos.new,
  name: 'permisoDeAvisosProvider',
);

/// El sistema de avisos. `main.dart` lo inyecta con el real.
///
/// Sin inyectar no hay avisos: la pantalla explica igual, pero aceptar no
/// concede nada. La app se comporta como antes de esta historia.
final avisosDelSistemaProvider = Provider<AvisosDelSistema?>(
  (ref) => null,
  name: 'avisosDelSistemaProvider',
);
