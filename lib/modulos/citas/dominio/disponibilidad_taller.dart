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

  /// Hasta `maximo` franjas con cupo para ofrecer cuando `llena` se quedo sin
  /// lugares: primero las de su dia, de la hora mas cercana a la mas lejana,
  /// luego las de los dias mas cercanos. Nunca incluye a `llena`.
  List<FranjaDisponible> cercanas(FranjaDisponible llena, {int maximo = 3}) {
    final dia = _solo(llena.fecha);
    final minutos = _minutos(llena.horaInicio);
    final candidatas = [
      for (final lista in _porDia.values)
        for (final f in lista)
          if (f.franjaId != llena.franjaId) f,
    ];
    int distanciaDias(FranjaDisponible f) =>
        _solo(f.fecha).difference(dia).inDays.abs();
    candidatas.sort((a, b) {
      final porDia = distanciaDias(a).compareTo(distanciaDias(b));
      if (porDia != 0) return porDia;
      final porHora = (_minutos(a.horaInicio) - minutos).abs().compareTo(
        (_minutos(b.horaInicio) - minutos).abs(),
      );
      if (porHora != 0) return porHora;
      return a.fecha.compareTo(b.fecha);
    });
    return List.unmodifiable(candidatas.take(maximo));
  }

  static int _minutos(String hhmm) {
    final partes = hhmm.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }
}
