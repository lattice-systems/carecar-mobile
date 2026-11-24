/// Lo que el modulo `asistente` necesita del backend (V2-M24.03).
abstract interface class RepositorioAsistente {
  /// Pregunta algo del vehiculo [vehiculoId] al asistente.
  ///
  /// Falla con un [FalloAsistente].
  Future<RespuestaDelAsistente> preguntar({
    required int vehiculoId,
    required String pregunta,
  });

  /// Guarda si la respuesta [consultaId] le sirvio (V2-M24.07).
  ///
  /// Falla con un [FalloAsistente].
  Future<void> calificar({required int consultaId, required bool util});
}

/// Respuesta del asistente, con las paginas del manual que cito.
class RespuestaDelAsistente {
  const RespuestaDelAsistente({
    required this.texto,
    required this.encontrado,
    this.fuentes = const [],
    this.consultaId,
  });

  final String texto;

  /// Id con el que se califica la respuesta (V2-M24.07).
  final int? consultaId;

  /// `false` si el manual no tiene la respuesta; entonces no hay fuentes.
  final bool encontrado;
  final List<CitaDelManual> fuentes;
}

/// Pagina del manual que respalda una respuesta.
class CitaDelManual {
  const CitaDelManual({required this.manualId, required this.pagina});

  final int manualId;
  final int pagina;
}

/// Por que no hubo respuesta. La pantalla elige el texto por tipo.
sealed class FalloAsistente implements Exception {
  const FalloAsistente();

  /// Si tiene sentido volver a mandar la misma pregunta.
  bool get sePuedeReintentar;
}

/// Sin red o el servidor no contesto a tiempo.
class AsistenteSinConexion extends FalloAsistente {
  const AsistenteSinConexion();
  @override
  bool get sePuedeReintentar => true;
}

/// El modelo y anio del vehiculo no tienen un manual que se pueda leer (409).
class AsistenteSinManual extends FalloAsistente {
  const AsistenteSinManual();
  @override
  bool get sePuedeReintentar => false;
}

/// Ya hizo sus preguntas del dia (429).
class AsistenteLimiteDiario extends FalloAsistente {
  const AsistenteLimiteDiario();
  @override
  bool get sePuedeReintentar => false;
}

/// Sin cuota del dia, el proveedor de IA fallo o cualquier otro error (503 y
/// el resto).
class AsistenteNoDisponible extends FalloAsistente {
  const AsistenteNoDisponible();
  @override
  bool get sePuedeReintentar => true;
}
