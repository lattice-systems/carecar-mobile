/// Para que viene el cliente al taller (V2-M02.08).
///
/// `codigo` es lo que viaja en `cita.motivo`; el texto que ve la persona sale
/// de los textos localizados, no de aqui.
enum MotivoCita {
  mantenimiento('mantenimiento'),
  reparacion('reparacion'),
  revision('revision'),
  garantia('garantia'),
  otro('otro');

  const MotivoCita(this.codigo);

  final String codigo;

  /// El motivo de un `cita.motivo` guardado, o null si no se reconoce.
  static MotivoCita? desdeCodigo(String? codigo) {
    for (final m in values) {
      if (m.codigo == codigo) return m;
    }
    return null;
  }
}
