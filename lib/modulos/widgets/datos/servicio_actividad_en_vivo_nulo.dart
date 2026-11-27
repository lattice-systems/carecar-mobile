import '../dominio/actividad_en_vivo.dart';

/// Donde no hay Live Activities (Android, escritorio, web y pruebas): nunca
/// esta disponible y no hace nada, asi que la app no pide ni registra tokens.
class ServicioActividadEnVivoNulo implements ServicioActividadEnVivo {
  const ServicioActividadEnVivoNulo();

  @override
  Future<bool> disponible() async => false;

  @override
  Future<bool> iniciar(int ordenId, EstadoDeActividad estado) async => false;

  @override
  Stream<String> tokensDe(int ordenId) => const Stream.empty();

  @override
  Future<void> actualizar(int ordenId, EstadoDeActividad estado) async {}

  @override
  Future<void> terminar(int ordenId, {EstadoDeActividad? estadoFinal}) async {}

  @override
  Future<void> terminarTodas() async {}

  @override
  Future<List<int>> activas() async => const [];
}
