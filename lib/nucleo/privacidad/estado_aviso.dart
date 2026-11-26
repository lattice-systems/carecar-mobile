import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sesion/controlador_sesion.dart';
import '../sesion/proveedores_sesion.dart';

/// Si la cuenta de la sesión ya aceptó el aviso de privacidad vigente
/// (V2-M22.01).
///
/// Lo escribe quien lo averigua (el módulo `privacidad`, que sí conoce al
/// servidor) y lo lee la guardia del enrutador, que vive en el núcleo y no
/// puede importar módulos.
enum EstadoAviso {
  /// Nadie lo pide: no hay verificador, no hay sesión o no se pudo averiguar.
  /// No bloquea a nadie: la falta de conexión no deja a la persona fuera.
  noRequerido,

  /// Se le está preguntando al servidor. La puerta espera para que la persona
  /// no vea el inicio un instante antes de que le pidan aceptar.
  verificando,

  /// Falta aceptar la versión vigente.
  pendiente,

  /// Ya la aceptó.
  aceptado;

  /// Si la guardia debe llevar a la puerta del aviso.
  bool get porAceptar => this == verificando || this == pendiente;
}

/// Estado del aviso de privacidad de la sesión en curso. Se apaga solo al
/// cerrarla: la cuenta que entre después tiene que aceptar por su cuenta.
final estadoAvisoProvider = NotifierProvider<EstadoAvisoNotifier, EstadoAviso>(
  EstadoAvisoNotifier.new,
  name: 'estadoAvisoProvider',
);

class EstadoAvisoNotifier extends Notifier<EstadoAviso> {
  @override
  EstadoAviso build() {
    ref.listen(estadoSesionProvider, (_, estado) {
      if (estado is! Autenticada) state = EstadoAviso.noRequerido;
    });
    return EstadoAviso.noRequerido;
  }

  void verificando() => state = EstadoAviso.verificando;

  void pendiente() => state = EstadoAviso.pendiente;

  void aceptado() => state = EstadoAviso.aceptado;

  void noRequerido() => state = EstadoAviso.noRequerido;
}
