/// Lo que el modulo `asistente` necesita del backend (V2-M24.03).
abstract interface class RepositorioAsistente {
  /// Pregunta algo del vehiculo [vehiculoId] al asistente.
  ///
  /// Falla con un [FalloAsistente].
  Future<RespuestaDelAsistente> preguntar({
    required int vehiculoId,
    required String pregunta,
  });

  /// Pregunta y entrega la respuesta mientras se escribe (V2-M24.09): varios
  /// [AvanceTexto] y al final un [AvanceFin].
  ///
  /// El flujo falla con un [FalloAsistente].
  Stream<AvanceRespuesta> preguntarEnFlujo({
    required int vehiculoId,
    required String pregunta,
  });

  /// Identifica el testigo del tablero en una foto (V2-M24.05). La foto solo
  /// viaja; no se guarda en el telefono.
  ///
  /// Falla con un [FalloAsistente].
  Future<TestigoDelTablero> identificarTestigo({
    required int vehiculoId,
    required List<int> imagen,
    required String tipo,
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

/// Que tan grave es un testigo del tablero (V2-M24.05).
enum GravedadTestigo {
  /// Detenerse en un lugar seguro.
  roja,

  /// Agendar una revision pronto.
  amarilla,

  /// Solo informa.
  informativa;

  static GravedadTestigo desdeCodigo(String? codigo) => switch (codigo) {
    'roja' => roja,
    'amarilla' => amarilla,
    _ => informativa,
  };
}

/// Lo que dice la foto de un testigo. Sin reconocer, solo trae [consultaId].
class TestigoDelTablero {
  const TestigoDelTablero({
    required this.consultaId,
    required this.reconocido,
    this.nombre,
    this.gravedad = GravedadTestigo.informativa,
    this.queHacer,
    this.fuentes = const [],
  });

  final int consultaId;
  final bool reconocido;
  final String? nombre;
  final GravedadTestigo gravedad;
  final String? queHacer;
  final List<CitaDelManual> fuentes;
}

/// Lo que llega de una respuesta en flujo (V2-M24.09).
sealed class AvanceRespuesta {
  const AvanceRespuesta();
}

/// Una parte mas del texto.
class AvanceTexto extends AvanceRespuesta {
  const AvanceTexto(this.texto);
  final String texto;
}

/// La respuesta terminada, con sus fuentes.
class AvanceFin extends AvanceRespuesta {
  const AvanceFin(this.respuesta);
  final RespuestaDelAsistente respuesta;
}
