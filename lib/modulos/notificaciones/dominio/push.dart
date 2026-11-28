/// De dónde sale el token de push de este teléfono (V2-M06.02).
///
/// Es una interfaz y no `firebase_messaging` directo por dos razones: las
/// pruebas no tocan la plataforma, y Firebase exige archivos de configuración
/// (`google-services.json`, `GoogleService-Info.plist`) que no van en el repo
/// (R8) y sin los que el APK de CI no compila. Mientras no exista la
/// implementación con Firebase, la app usa la nula, que no da token: no se
/// registra nada y todo lo demás funciona igual. Qué falta para el push real
/// está en `plan/modulos/M06-notificaciones.md`.
abstract interface class ServicioPush {
  /// El token actual, o `null` si este teléfono no puede recibir push.
  Future<String?> tokenActual();

  /// Cada token nuevo que entregue el proveedor: lo puede rotar en cualquier
  /// momento y el viejo deja de servir.
  Stream<String> get tokensNuevos;
}

/// La plataforma tal como la pide el contrato (`RegistroDispositivo`).
enum PlataformaPush {
  android('android'),
  ios('ios');

  const PlataformaPush(this.valor);

  /// El valor que viaja en el cuerpo del `PUT`.
  final String valor;
}

/// `PUT` y `DELETE /dispositivos/{instalacionId}` (V2-M06.02, backend#117).
///
/// Una instalación tiene un solo token; registrar otra vez la misma la
/// actualiza, y darla de baja es idempotente.
abstract interface class RepositorioDispositivos {
  Future<void> registrar({
    required String instalacionId,
    required String tokenFcm,
    required PlataformaPush plataforma,
    String? idioma,
  });

  Future<void> darDeBaja(String instalacionId);
}
