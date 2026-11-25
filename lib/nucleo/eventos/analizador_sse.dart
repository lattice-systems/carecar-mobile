import 'dart:async';
import 'dart:convert';

import 'eventos_en_vivo.dart';

/// Convierte las lineas de un flujo `text/event-stream` en [EventoEnVivo].
///
/// Reglas del formato: `event:` fija el nombre (por omision `message`),
/// `data:` agrega una linea al cuerpo, una linea vacia cierra el evento y las
/// que empiezan con `:` son comentarios (el latido del servidor). Un cuerpo
/// que no es un objeto JSON se descarta: la app solo lee objetos.
class AnalizadorSse extends StreamTransformerBase<String, EventoEnVivo> {
  const AnalizadorSse();

  @override
  Stream<EventoEnVivo> bind(Stream<String> lineas) async* {
    var nombre = 'message';
    final datos = <String>[];

    EventoEnVivo? cerrar() {
      final cuerpo = datos.join('\n');
      final fijado = nombre;
      nombre = 'message';
      datos.clear();
      if (cuerpo.isEmpty) return null;
      try {
        final json = jsonDecode(cuerpo);
        if (json is Map) {
          return EventoEnVivo(fijado, json.cast<String, Object?>());
        }
      } on FormatException {
        // Un cuerpo que no es JSON no es un evento de la app.
      }
      return null;
    }

    await for (final linea in lineas) {
      if (linea.isEmpty) {
        final evento = cerrar();
        if (evento != null) yield evento;
      } else if (linea.startsWith(':')) {
        continue;
      } else {
        final dos = linea.indexOf(':');
        final campo = dos == -1 ? linea : linea.substring(0, dos);
        var valor = dos == -1 ? '' : linea.substring(dos + 1);
        if (valor.startsWith(' ')) valor = valor.substring(1);
        if (campo == 'event') {
          nombre = valor;
        } else if (campo == 'data') {
          datos.add(valor);
        }
      }
    }
  }
}
