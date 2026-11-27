import '../dominio/actividad_en_vivo.dart';

/// Registro de la Live Activity en memoria para pruebas y para el flavor de
/// desarrollo sin red.
class RepositorioActividadEnVivoFake implements RepositorioActividadEnVivo {
  RepositorioActividadEnVivoFake({this.entregadas = const {}, this.falla});

  /// Ordenes que ya se entregaron: registrarlas lanza [OrdenYaEntregada].
  final Set<int> entregadas;

  /// Si no es nula, toda llamada la lanza (sin red, servidor caido).
  Object? falla;

  /// Lo registrado, en orden: (ordenId, pushToken).
  final registrados = <(int, String)>[];

  /// Lo dado de baja, en orden: (ordenId, pushToken o nulo para todas).
  final bajas = <(int, String?)>[];

  @override
  Future<void> registrar({
    required int ordenId,
    required String pushToken,
  }) async {
    if (falla != null) throw falla!;
    if (entregadas.contains(ordenId)) throw const OrdenYaEntregada();
    registrados.add((ordenId, pushToken));
  }

  @override
  Future<void> darDeBaja({required int ordenId, String? pushToken}) async {
    if (falla != null) throw falla!;
    bajas.add((ordenId, pushToken));
  }
}
