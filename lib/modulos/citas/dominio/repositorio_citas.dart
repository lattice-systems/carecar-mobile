import 'disponibilidad_taller.dart';

/// Contrato que la presentacion usa para leer y agendar citas.
abstract interface class RepositorioCitas {
  /// Lo que el taller tiene libre entre `desde` y `hasta`, ambos incluidos.
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  });
}
