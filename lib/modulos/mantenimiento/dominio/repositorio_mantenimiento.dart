import 'plan_mantenimiento.dart';

/// Contrato que la presentación usa para el plan de mantenimiento y las
/// lecturas de kilometraje (V2-M05.01 a V2-M05.03).
abstract interface class RepositorioMantenimiento {
  /// El plan del vehículo `vehiculoId` con el estado de cada servicio y el
  /// próximo. Un modelo sin plan da un plan sin servicios, no un error.
  ///
  /// Un vehículo ajeno o inexistente lanza `NoEncontrado`.
  Future<PlanMantenimiento> plan(int vehiculoId);

  /// Registra el kilometraje actual que declara el cliente.
  ///
  /// Lanza `KmInvalido` si es menor a la última lectura. El km oficial del
  /// taller no se sobrescribe: solo se suma una lectura del cliente.
  Future<LecturaKm> registrarKm(int vehiculoId, int km);
}
