import 'package:carecar_mobile/nucleo/eventos/analizador_sse.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<EventoEnVivo>> _leer(List<String> lineas) =>
    const AnalizadorSse().bind(Stream.fromIterable(lineas)).toList();

void main() {
  test('lee el nombre y el cuerpo JSON de un evento', () async {
    final eventos = await _leer([
      'event: asistencia.estado',
      'data: {"solicitudId":12,"estado":"en_camino"}',
      '',
    ]);

    expect(eventos, hasLength(1));
    expect(eventos.single.nombre, 'asistencia.estado');
    expect(eventos.single.datos, {'solicitudId': 12, 'estado': 'en_camino'});
  });

  test('ignora el latido y los comentarios', () async {
    final eventos = await _leer([
      ': latido',
      '',
      'event: traslado.estado',
      'data: {"trasladoId":5}',
      '',
    ]);

    expect(eventos.map((e) => e.nombre), ['traslado.estado']);
  });

  test('junta varias lineas data y usa message sin nombre', () async {
    final eventos = await _leer(['data: {"a":', 'data: 1}', '']);

    expect(eventos.single.nombre, 'message');
    expect(eventos.single.datos, {'a': 1});
  });

  test('descarta un cuerpo que no es un objeto JSON', () async {
    final eventos = await _leer([
      'event: raro',
      'data: no es json',
      '',
      'event: lista',
      'data: [1,2]',
      '',
      'event: bueno',
      'data: {"x":1}',
      '',
    ]);

    expect(eventos.map((e) => e.nombre), ['bueno']);
  });

  test('un evento sin linea vacia final no se entrega', () async {
    final eventos = await _leer(['event: a', 'data: {"x":1}']);

    expect(eventos, isEmpty);
  });
}
