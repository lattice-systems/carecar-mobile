class PreguntaFrecuente {
  const PreguntaFrecuente({
    required this.id,
    required this.tema,
    required this.pregunta,
    required this.respuesta,
    required this.orden,
  });
  final int id;
  final String tema;
  final String pregunta;
  final String respuesta;

  factory PreguntaFrecuente.desdeJson(Map<String, Object?> json) =>
      PreguntaFrecuente(
        id: (json['id'] as num).toInt(),
        tema: json['tema'] as String,
        pregunta: json['pregunta'] as String,
        respuesta: json['respuesta'] as String,
        orden: (json['orden'] as num).toInt(),
      );
  final int orden;
}

abstract interface class RepositorioCentroAyuda {
  Future<List<PreguntaFrecuente>> preguntas();
  Future<void> reportar({
    required String descripcion,
    required String version,
    required String sistema,
    required String dispositivo,
  });
}
