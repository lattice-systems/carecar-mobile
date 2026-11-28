class EncuestaPendiente {
  const EncuestaPendiente(this.ordenId, this.modelo, this.cerradaEn);

  factory EncuestaPendiente.desdeJson(Map<String, Object?> json) =>
      EncuestaPendiente(
        (json['ordenId'] as num).toInt(),
        json['modelo'] as String,
        DateTime.parse(json['cerradaEn'] as String),
      );

  final int ordenId;
  final String modelo;
  final DateTime cerradaEn;
}

enum CalificacionEncuesta { nps, tiempo, trato, limpieza, asesor }
