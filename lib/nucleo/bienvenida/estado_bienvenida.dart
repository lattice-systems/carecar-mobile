import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../idioma/proveedores_idioma.dart';

/// Clave con la que se recuerda que la bienvenida ya se vio.
const claveBienvenidaVista = 'bienvenida_vista';

/// Si falta ver la bienvenida · V2-M01.02.
///
/// Vive en el nucleo y no en el modulo `acceso` porque quien decide es la
/// guardia de rutas (`redirigirPorSesion`), que esta aqui y no puede importar
/// un modulo.
///
/// **Sin preferencias se responde que no falta.** Mostrarla sin poder recordar
/// que ya se vio la repetiria en cada arranque, y eso es peor que no
/// mostrarla: el criterio es que aparezca **una** vez.
class BienvenidaPendiente extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(preferenciasProvider);
    if (prefs == null) return false;
    return !(prefs.getBool(claveBienvenidaVista) ?? false);
  }

  /// La vio o la salto: da lo mismo, no se vuelve a mostrar.
  ///
  /// El estado cambia **antes** de guardar para que la navegacion no espere al
  /// disco; si el guardado fallara, lo peor es que vuelva a aparecer la
  /// proxima vez.
  Future<void> marcarVista() async {
    state = false;
    await ref.read(preferenciasProvider)?.setBool(claveBienvenidaVista, true);
  }
}

final bienvenidaPendienteProvider = NotifierProvider<BienvenidaPendiente, bool>(
  BienvenidaPendiente.new,
  name: 'bienvenidaPendienteProvider',
);
