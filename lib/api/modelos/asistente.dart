import 'comun.dart';

/// Respuesta de `POST /asistente/preguntas` (V2-M24.03).
class RespuestaAsistente {
  const RespuestaAsistente({
    required this.consultaId,
    required this.respuesta,
    required this.encontrado,
    required this.fuentes,
  });

  factory RespuestaAsistente.fromJson(Map<String, Object?> json) =>
      RespuestaAsistente(
        consultaId: leerEntero(json['consultaId'], 'consultaId'),
        respuesta: leerTexto(json['respuesta'], 'respuesta'),
        encontrado: json['encontrado'] == true,
        fuentes: [
          for (final f in (json['fuentes'] as List<Object?>? ?? const []))
            FuenteAsistente.fromJson(f! as Map<String, Object?>),
        ],
      );

  final int consultaId;
  final String respuesta;

  /// `false` si el manual no tiene la respuesta; entonces no hay fuentes.
  final bool encontrado;
  final List<FuenteAsistente> fuentes;
}

/// Página del manual citada en una respuesta.
class FuenteAsistente {
  const FuenteAsistente({required this.manualId, required this.pagina});

  factory FuenteAsistente.fromJson(Map<String, Object?> json) =>
      FuenteAsistente(
        manualId: leerEntero(json['manualId'], 'manualId'),
        pagina: leerEntero(json['pagina'], 'pagina'),
      );

  final int manualId;
  final int pagina;
}
