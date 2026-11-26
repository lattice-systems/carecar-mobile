import 'dart:math';

int estimarCuadrosPerdidos(Duration compilacion, Duration raster, double hz) {
  final frecuencia = hz.isFinite && hz > 0 ? hz : 60.0;
  final costo = max(compilacion.inMicroseconds, raster.inMicroseconds);
  return max(
    0,
    (costo * frecuencia / Duration.microsecondsPerSecond).ceil() - 1,
  );
}

typedef EnviarAnalitica = Future<void> Function(
  Map<String, Object> evento,
  bool Function() siguePermitido,
);

class Analitica {
  const Analitica(this._habilitada, this._enviar, {int Function()? revision})
    : _revision = revision;

  final bool Function() _habilitada;
  final EnviarAnalitica _enviar;
  final int Function()? _revision;

  bool get habilitada => _habilitada();
  int get revision => _revision?.call() ?? 0;

  Future<void> registrar(Map<String, Object> evento) async {
    if (!habilitada) return;
    final permiso = revision;
    try {
      await _enviar(evento, () => habilitada && revision == permiso);
    } on Object {
      // La telemetría es de mejor esfuerzo y no conserva eventos fallidos.
    }
  }
}

/// Un recorrido de agenda. Se descarta cuando se apaga la analítica o se sale.
class EmbudoCitas {
  String? _intento;
  int? _revision;
  bool _eligio = false;

  String? get intento => _intento;

  void descartar() {
    _intento = null;
    _revision = null;
    _eligio = false;
  }

  Future<void> mostrarDisponibilidad(Analitica analitica) async {
    if (_revision != analitica.revision) descartar();
    if (!analitica.habilitada || _intento != null) return;
    final azar = Random.secure();
    final octetos = List<int>.generate(16, (_) => azar.nextInt(256));
    octetos[6] = (octetos[6] & 15) | 64;
    octetos[8] = (octetos[8] & 63) | 128;
    final id = octetos.map((n) => n.toRadixString(16).padLeft(2, '0')).join();
    final intento =
        '${id.substring(0, 8)}-${id.substring(8, 12)}-'
        '${id.substring(12, 16)}-${id.substring(16, 20)}-${id.substring(20)}';
    _intento = intento;
    _revision = analitica.revision;
    await analitica.registrar({'tipo': 'DISPONIBILIDAD', 'intento': intento});
  }

  Future<void> elegirFranja(Analitica analitica) async {
    final intento = _intento;
    if (!analitica.habilitada ||
        _revision != analitica.revision ||
        intento == null ||
        _eligio)
      return;
    _eligio = true;
    await analitica.registrar({'tipo': 'FRANJA', 'intento': intento});
  }

  Future<void> confirmar(
    Analitica analitica,
    int citaId,
    String? intento,
  ) async {
    if (!analitica.habilitada ||
        _revision != analitica.revision ||
        intento == null ||
        intento != _intento ||
        !_eligio)
      return;
    descartar();
    await analitica.registrar({
      'tipo': 'CONFIRMADA',
      'intento': intento,
      'citaId': citaId,
    });
  }
}
