/// Las guias de emergencia que la app trae empaquetadas (V2-M11.03).
///
/// Dart puro: solo dice cuales guias hay y cuantos pasos tiene cada una. Los
/// textos viven en `lib/l10n/` y la presentacion los traduce.
library;

/// Situaciones para las que hay guia.
enum TipoGuia {
  llanta('llanta'),
  corriente('corriente'),
  choque('choque');

  const TipoGuia(this.id);

  /// Identificador estable que viaja en la ruta (`/asistencia/guias/llanta`).
  final String id;

  /// La guia que corresponde a un [id] de ruta, o `null` si no existe.
  static TipoGuia? desdeId(String? id) {
    for (final tipo in values) {
      if (tipo.id == id) return tipo;
    }
    return null;
  }
}

/// Una guia: su tipo y cuantos pasos tiene.
class GuiaEmergencia {
  const GuiaEmergencia({required this.tipo, required this.pasos});

  final TipoGuia tipo;
  final int pasos;
}

/// Las guias empaquetadas, en el orden en que se listan. No dependen de la
/// red: se abren en modo avion.
const guiasDeEmergencia = <GuiaEmergencia>[
  GuiaEmergencia(tipo: TipoGuia.llanta, pasos: 5),
  GuiaEmergencia(tipo: TipoGuia.corriente, pasos: 6),
  GuiaEmergencia(tipo: TipoGuia.choque, pasos: 6),
];
