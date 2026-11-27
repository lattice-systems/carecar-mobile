import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sesion/controlador_sesion.dart';
import '../idioma/proveedores_idioma.dart';
import '../sesion/proveedores_sesion.dart';

/// Si ya se le explicaron los avisos y contesto algo.
const claveAvisosRespondido = 'avisos.respondido';

/// Lo ultimo que se supo del permiso del sistema.
const claveAvisosPermitidos = 'avisos.permitidos';

/// Que toca explicar los avisos en cuanto se pueda.
const claveAvisosPorExplicar = 'avisos.por_explicar';

/// Si falta explicar los avisos antes de pedirlos · V2-M06.01.
///
/// Vive en el nucleo y no en el modulo `notificaciones` porque quien decide es
/// la guardia de rutas (`redirigirPorSesion`), que esta aqui y no puede
/// importar un modulo. Es el mismo reparto de la bienvenida (V2-M01.02).
///
/// **Sin la clave puesta no falta nada.** Es a proposito y es lo que vuelve
/// esta compuerta inofensiva: solo aparece cuando alguien entro a su cuenta de
/// verdad, nunca porque unas preferencias vengan vacias.
class AvisosPorExplicar extends Notifier<bool> {
  @override
  bool build() {
    // Entrar a la cuenta es el momento: ya hay a quien avisarle de algo.
    ref.listen(estadoSesionProvider, (previo, nuevo) {
      if (previo is Autenticando && nuevo is Autenticada) _alEntrar();
    });
    final prefs = ref.read(preferenciasProvider);
    if (prefs == null) return false;
    return (prefs.getBool(claveAvisosPorExplicar) ?? false) &&
        !(prefs.getBool(claveAvisosRespondido) ?? false);
  }

  Future<void> _alEntrar() async {
    final prefs = ref.read(preferenciasProvider);
    if (prefs == null) return;
    // Quien ya contesto no se vuelve a preguntar, ni al cambiar de cuenta en
    // el mismo telefono: el permiso es del telefono, no de la cuenta.
    if (prefs.getBool(claveAvisosRespondido) ?? false) return;
    state = true;
    await prefs.setBool(claveAvisosPorExplicar, true);
  }

  /// Ya se explico y la persona contesto: la compuerta se cierra.
  ///
  /// Da lo mismo que haya dicho que si o que no. Lo que no se repite es la
  /// explicacion.
  void listo() => state = false;
}

final avisosPorExplicarProvider = NotifierProvider<AvisosPorExplicar, bool>(
  AvisosPorExplicar.new,
  name: 'avisosPorExplicarProvider',
);
