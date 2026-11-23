/// Accesos rapidos del icono de la app (V2-M25.04).
///
/// Dart puro: dice que accesos hay y como se identifican ante el sistema. Los
/// titulos viven en `lib/l10n/` y la pantalla a la que llevan, en la
/// presentacion.
library;

/// Lo que ofrece mantener presionado el icono, en el orden en que se muestra.
enum AccesoRapido {
  agendar('agendar'),
  miAuto('mi_auto'),
  sos('sos');

  const AccesoRapido(this.id);

  /// Identificador que se registra en el sistema (Android e iOS).
  final String id;

  /// El acceso que corresponde a un [id] del sistema, o `null` si no existe.
  static AccesoRapido? desdeId(String? id) {
    for (final acceso in values) {
      if (acceso.id == id) return acceso;
    }
    return null;
  }
}

/// Un acceso listo para registrarse: su identidad y el titulo que ve la
/// persona, ya traducido.
class AtajoDeIcono {
  const AtajoDeIcono({required this.acceso, required this.titulo});

  final AccesoRapido acceso;
  final String titulo;
}

/// Lo que el modulo necesita del sistema operativo; el paquete `quick_actions`
/// queda detras de esta interfaz para poder sustituirlo en pruebas.
abstract interface class PuertoAccesosRapidos {
  /// Registra los atajos del icono, reemplazando los anteriores.
  Future<void> instalar(List<AtajoDeIcono> atajos);

  /// Avisa cuando la persona abre la app desde uno de los atajos. Tambien se
  /// llama al arrancar en frio con el atajo que la abrio.
  void alElegir(void Function(AccesoRapido acceso) callback);
}
