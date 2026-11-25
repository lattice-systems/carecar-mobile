import 'dart:async';
import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _config = ApiConfig.para('http://localhost:3000/api/v1/app');

http.StreamedResponse _respuesta(int estado, Stream<List<int>> cuerpo) =>
    http.StreamedResponse(cuerpo, estado);

Stream<List<int>> _texto(String texto) => Stream.value(utf8.encode(texto));

void main() {
  test('pide /eventos con el token y entrega los eventos', () async {
    late http.BaseRequest pedida;
    final cliente = MockClient.streaming((peticion, _) async {
      pedida = peticion;
      return _respuesta(
        200,
        _texto(
          ': latido\n\n'
          'event: asistencia.estado\n'
          'data: {"solicitudId":1,"estado":"en_camino"}\n\n',
        ),
      );
    });
    final eventos = EventosEnVivoHttp(
      config: _config,
      obtenerToken: () async => 'abc',
      crearCliente: () => cliente,
      dormir: (_) => Completer<void>().future,
    );

    final primero = await eventos.escuchar().first;

    expect(pedida.url.path, '/api/v1/app/eventos');
    expect(pedida.headers['authorization'], 'Bearer abc');
    expect(pedida.headers['accept'], 'text/event-stream');
    expect(primero.nombre, 'asistencia.estado');
    expect(primero.datos['estado'], 'en_camino');
  });

  test(
    'reabre la conexion tras un cierre y avisa que se restablecio',
    () async {
      var conexiones = 0;
      final esperas = <Duration>[];
      final cliente = MockClient.streaming((_, _) async {
        conexiones++;
        return _respuesta(
          200,
          _texto(
            'event: traslado.estado\ndata: {"trasladoId":$conexiones}\n\n',
          ),
        );
      });
      final eventos = EventosEnVivoHttp(
        config: _config,
        obtenerToken: () async => 'abc',
        crearCliente: () => cliente,
        dormir: (d) async {
          esperas.add(d);
          await Future<void>.delayed(Duration.zero);
        },
      );

      final recibidos = await eventos.escuchar().take(3).toList();

      expect(recibidos.map((e) => e.nombre), [
        'traslado.estado',
        eventoReconectado,
        'traslado.estado',
      ]);
      expect(recibidos.last.datos['trasladoId'], 2);
      expect(esperas, isNotEmpty);
    },
  );

  test('las esperas entre reintentos crecen y tienen tope', () async {
    final esperas = <Duration>[];
    final cliente = MockClient.streaming((_, _) async {
      throw http.ClientException('sin red');
    });
    final eventos = EventosEnVivoHttp(
      config: _config,
      obtenerToken: () async => 'abc',
      crearCliente: () => cliente,
      dormir: (d) async {
        esperas.add(d);
        await Future<void>.delayed(Duration.zero);
      },
    );
    final suscripcion = eventos.escuchar().listen((_) {});
    while (esperas.length < 8) {
      await Future<void>.delayed(Duration.zero);
    }
    await suscripcion.cancel();

    expect(esperas.first, const Duration(seconds: 1));
    expect(esperas[1], const Duration(seconds: 2));
    expect(
      esperas.reduce((a, b) => a > b ? a : b),
      const Duration(seconds: 30),
    );
  });

  test('un 401 renueva la sesion antes de reintentar', () async {
    var token = 'viejo';
    var renovaciones = 0;
    final usados = <String?>[];
    final cliente = MockClient.streaming((peticion, _) async {
      usados.add(peticion.headers['authorization']);
      if (peticion.headers['authorization'] == 'Bearer viejo') {
        return _respuesta(401, const Stream.empty());
      }
      return _respuesta(200, _texto('event: x\ndata: {"a":1}\n\n'));
    });
    final eventos = EventosEnVivoHttp(
      config: _config,
      obtenerToken: () async => token,
      renovarSesion: () async {
        renovaciones++;
        token = 'nuevo';
        return true;
      },
      crearCliente: () => cliente,
      dormir: (_) => Completer<void>().future,
    );

    final primero = await eventos.escuchar().first;

    expect(primero.nombre, 'x');
    expect(renovaciones, 1);
    expect(usados, ['Bearer viejo', 'Bearer nuevo']);
  });

  test('cancelar la suscripcion cierra el cliente y no reintenta', () async {
    var conexiones = 0;
    var cerrado = false;
    final abierta = StreamController<List<int>>();
    final cliente = _ClienteConCierre((peticion) async {
      conexiones++;
      return _respuesta(200, abierta.stream);
    }, alCerrar: () => cerrado = true);
    final eventos = EventosEnVivoHttp(
      config: _config,
      obtenerToken: () async => 'abc',
      crearCliente: () => cliente,
      dormir: (_) => Future<void>.delayed(Duration.zero),
    );

    final suscripcion = eventos.escuchar().listen((_) {});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await suscripcion.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(cerrado, isTrue);
    expect(conexiones, 1);
  });
}

class _ClienteConCierre extends http.BaseClient {
  _ClienteConCierre(this._enviar, {required this.alCerrar});

  final Future<http.StreamedResponse> Function(http.BaseRequest) _enviar;
  final void Function() alCerrar;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _enviar(request);

  @override
  void close() => alCerrar();
}
