import '../dominio/push.dart';

/// El `ServicioPush` que usa la app mientras no exista la implementación con
/// Firebase (V2-M06.02): no hay token, así que no se registra nada en el
/// servidor y ninguna pantalla cambia.
///
/// Activar el push real es inyectar otra implementación en
/// `servicioPushProvider`; los pasos están en `plan/modulos/M06-notificaciones.md`.
class ServicioPushNulo implements ServicioPush {
  const ServicioPushNulo();

  @override
  Future<String?> tokenActual() async => null;

  @override
  Stream<String> get tokensNuevos => const Stream.empty();
}
