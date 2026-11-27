import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';

/// Un [AvisosDelSistema] que responde lo que la prueba le diga · V2-M06.01.
///
/// En una prueba no hay dialogo del sistema ni pantalla de ajustes: sin esto
/// la unica forma de probar el permiso seria en un celular a mano.
class AvisosDelSistemaFalso implements AvisosDelSistema {
  AvisosDelSistemaFalso({this.concede = true});

  /// Que contesta la persona en el dialogo del sistema.
  bool concede;

  int vecesQueSePidio = 0;
  int vecesQueSeAbrieronAjustes = 0;

  @override
  Future<bool> pedirPermiso() async {
    vecesQueSePidio++;
    return concede;
  }

  @override
  Future<void> abrirAjustes() async => vecesQueSeAbrieronAjustes++;
}
