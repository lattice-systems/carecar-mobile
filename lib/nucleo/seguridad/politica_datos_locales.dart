import 'package:flutter/foundation.dart';

import 'detector_integridad.dart';

/// Politica de datos del cliente en el dispositivo (V2-M22.05).
///
/// Contrato para todo lo que guarde datos del cliente fuera de
/// `flutter_secure_storage` (cache de la v1, la base local de V2-M21, el widget
/// de inicio): antes de escribir o leer una copia local, consulta
/// [permiteCacheLocal]. Si es `false`, no escribe, no lee y borra lo que ya
/// hubiera (escuchando esta politica). Los tokens no entran aqui: ya viven en
/// el almacen seguro del sistema.
///
/// Con [EstadoIntegridad.desconocido] se permite: la falta de una señal no es
/// motivo para quitarle la funcion sin conexion a quien no tiene un equipo
/// modificado.
class PoliticaDatosLocales extends ChangeNotifier {
  PoliticaDatosLocales([EstadoIntegridad estado = EstadoIntegridad.desconocido])
    : _estado = estado;

  EstadoIntegridad _estado;

  EstadoIntegridad get estado => _estado;

  /// `false` en un equipo con root o jailbreak.
  bool get permiteCacheLocal => _estado != EstadoIntegridad.comprometido;

  /// `true` si hay que avisar a la persona (sin bloquearla).
  bool get equipoComprometido => _estado == EstadoIntegridad.comprometido;

  void actualizar(EstadoIntegridad nuevo) {
    if (nuevo == _estado) return;
    _estado = nuevo;
    notifyListeners();
  }
}
