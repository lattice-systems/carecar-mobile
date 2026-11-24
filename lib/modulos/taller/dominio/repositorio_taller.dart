import 'dart:typed_data';

import 'orden_taller.dart';

/// Lo que el modulo `taller` necesita de la API (V2-M04.01, V2-M04.02,
/// V2-M04.04 y V2-M04.05).
abstract interface class RepositorioTaller {
  /// Ordenes sin entregar de los vehiculos del cliente; vacia si no hay.
  Future<List<OrdenEnCurso>> enCurso();

  /// La orden con sus etapas, su inspeccion y sus trabajos adicionales.
  Future<OrdenEnVivo> orden(int ordenId);

  /// Aprueba o rechaza un trabajo adicional con la firma en PNG. Devuelve la
  /// orden con los totales recalculados. Lanza [AdicionalYaRespondido] u
  /// [OrdenCerrada] si ya no se puede responder.
  Future<OrdenEnVivo> responder({
    required int ordenId,
    required int adicionalId,
    required bool aprobado,
    required Uint8List firmaPng,
  });
}

/// El trabajo adicional ya tiene respuesta (409 `ADICIONAL_YA_RESPONDIDO`).
class AdicionalYaRespondido implements Exception {
  const AdicionalYaRespondido();
}

/// La orden ya esta terminada y no acepta respuestas (409 `ORDEN_CERRADA`).
class OrdenCerrada implements Exception {
  const OrdenCerrada();
}
