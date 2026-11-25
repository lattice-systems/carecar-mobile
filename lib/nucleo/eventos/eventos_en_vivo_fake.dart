import 'dart:async';

import 'eventos_en_vivo.dart';

/// Canal de eventos en memoria para pruebas y el flavor `desarrollo`.
///
/// [emitir] entrega un evento a quien este escuchando; [escuchas] y
/// [aperturas] dejan comprobar que la conexion solo vive mientras hay una
/// pantalla escuchando.
class EventosEnVivoFake implements EventosEnVivo {
  final _controlador = StreamController<EventoEnVivo>.broadcast();

  int escuchas = 0;
  int aperturas = 0;

  /// Eventos que se emiten sin escuchas se pierden, como en la conexion real.
  void emitir(String nombre, [Map<String, Object?> datos = const {}]) =>
      _controlador.add(EventoEnVivo(nombre, datos));

  @override
  Stream<EventoEnVivo> escuchar() {
    late final StreamController<EventoEnVivo> salida;
    StreamSubscription<EventoEnVivo>? origen;
    salida = StreamController<EventoEnVivo>(
      onListen: () {
        aperturas++;
        escuchas++;
        origen = _controlador.stream.listen(salida.add);
      },
      onCancel: () {
        escuchas--;
        return origen?.cancel();
      },
    );
    return salida.stream;
  }
}
