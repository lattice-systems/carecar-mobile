import '../../../notificaciones/servicio_notificaciones.dart';
import '../../../nucleo/registro/registro.dart';
import '../../../nucleo/sistema/ajustes_de_la_app.dart';
import '../dominio/avisos_del_sistema.dart';

/// El [AvisosDelSistema] de verdad · V2-M06.01.
///
/// El permiso lo pide el mismo plugin que ya programa los recordatorios
/// (`flutter_local_notifications`), para que no haya dos caminos al sistema.
///
/// Los ajustes del sistema los abre `abrirAjustesDeLaApp()`, del nucleo: la
/// decision 0006 deja los paquetes de ubicacion dentro de `lib/nucleo/`, y
/// quien los abre hoy es `geolocator`.
class AvisosDelSistemaReal implements AvisosDelSistema {
  AvisosDelSistemaReal(this._plugin);

  final PluginNotificaciones _plugin;

  @override
  Future<bool> pedirPermiso() async {
    try {
      return await _plugin.pedirPermiso();
    } catch (e) {
      // Sin permiso la app sigue funcionando: es el criterio de la historia.
      Registro.depurar('No se pudo pedir el permiso de avisos', error: e);
      return false;
    }
  }

  @override
  Future<void> abrirAjustes() async {
    try {
      await abrirAjustesDeLaApp();
    } catch (e) {
      Registro.depurar(
        'No se pudieron abrir los ajustes del sistema',
        error: e,
      );
    }
  }
}
