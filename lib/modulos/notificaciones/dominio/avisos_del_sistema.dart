/// Lo que la app necesita del sistema para los avisos · V2-M06.01.
///
/// Es una interfaz y no el plugin directo para que las pruebas no toquen la
/// plataforma -en una prueba no hay dialogo del sistema- y para que cambiar de
/// plugin sea cambiar una clase.
abstract interface class AvisosDelSistema {
  /// Dispara el dialogo del sistema. `true` si quedo concedido.
  ///
  /// En Android 13 y despues **solo se muestra una vez**: si la persona ya
  /// nego, las llamadas siguientes contestan `false` sin preguntar nada. Por
  /// eso existe [abrirAjustes].
  Future<bool> pedirPermiso();

  /// Abre la pantalla de ajustes **de la app** en el sistema.
  ///
  /// Es la unica forma real de reactivar los avisos despues de negarlos, que
  /// es un criterio de la historia.
  Future<void> abrirAjustes();
}
