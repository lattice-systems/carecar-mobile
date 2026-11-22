/// Una franja del taller con lugares libres en una fecha.
///
/// Dart puro: no sabe de Flutter ni de la red. Las horas son `HH:mm` sin zona
/// horaria, igual que el contrato.
class FranjaDisponible {
  const FranjaDisponible({
    required this.franjaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.cupo,
  });

  final int franjaId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  /// Lugares que quedan (`franja_horario.capacidad` menos citas).
  final int cupo;
}

/// Lo que el taller tiene libre en un rango de fechas.
class DisponibilidadTaller {
  DisponibilidadTaller(Iterable<FranjaDisponible> franjas)
    : _porDia = _agrupar(franjas);

  final Map<DateTime, List<FranjaDisponible>> _porDia;

  static DateTime _solo(DateTime d) => DateTime(d.year, d.month, d.day);

  static Map<DateTime, List<FranjaDisponible>> _agrupar(
    Iterable<FranjaDisponible> franjas,
  ) {
    final porDia = <DateTime, List<FranjaDisponible>>{};
    for (final f in franjas.where((f) => f.cupo > 0)) {
      porDia.putIfAbsent(_solo(f.fecha), () => []).add(f);
    }
    for (final lista in porDia.values) {
      lista.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }
    return porDia;
  }

  /// Franjas con cupo de un dia, de la mas temprana a la mas tarde.
  List<FranjaDisponible> franjasDe(DateTime dia) =>
      List.unmodifiable(_porDia[_solo(dia)] ?? const []);

  /// Falso para los dias sin franjas con cupo.
  bool tieneCupo(DateTime dia) => _porDia.containsKey(_solo(dia));

  /// Verdadero si en todo el rango no hay ningun lugar.
  bool get sinCupoEnTodoElRango => _porDia.isEmpty;
}
