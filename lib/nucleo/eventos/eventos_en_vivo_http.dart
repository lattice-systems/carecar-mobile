import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api/api_config.dart';
import 'analizador_sse.dart';
import 'eventos_en_vivo.dart';

/// Esperas entre reintentos: crecen al doble y se detienen en 30 s.
Duration esperaDeReintento(int intento) {
  final segundos = 1 << (intento < 5 ? intento : 5);
  return Duration(seconds: segundos > 30 ? 30 : segundos);
}

/// `GET /app/eventos` (Server-Sent Events) con el token de la sesion.
///
/// La conexion se abre al escuchar y se cierra al cancelar. Si el servidor la
/// cierra (lo hace cada 30 min para que la app presente un token vigente) o se
/// cae la red, se reabre con [esperaDeReintento] y se emite
/// [eventoReconectado] para que quien escucha recupere lo que se perdio. Un
/// 401 renueva la sesion con [renovarSesion] antes de reintentar.
///
/// No guarda nada: los eventos solo avisan que algo cambio y los datos se
/// vuelven a consultar por los endpoints normales.
class EventosEnVivoHttp implements EventosEnVivo {
  EventosEnVivoHttp({
    required this.config,
    required this.obtenerToken,
    this.renovarSesion,
    http.Client Function()? crearCliente,
    Future<void> Function(Duration)? dormir,
  }) : _crearCliente = crearCliente ?? http.Client.new,
       _dormir = dormir ?? Future<void>.delayed;

  final ApiConfig config;
  final Future<String?> Function() obtenerToken;
  final Future<bool> Function()? renovarSesion;
  final http.Client Function() _crearCliente;
  final Future<void> Function(Duration) _dormir;

  @override
  Stream<EventoEnVivo> escuchar() {
    late final StreamController<EventoEnVivo> salida;
    http.Client? actual;
    var cancelado = false;

    Future<void> ciclo() async {
      var intento = 0;
      var reconexion = false;
      while (!cancelado) {
        final cliente = _crearCliente();
        actual = cliente;
        try {
          final respuesta = await _abrir(cliente);
          if (respuesta.statusCode == 200) {
            intento = 0;
            if (reconexion && !cancelado) {
              salida.add(const EventoEnVivo(eventoReconectado));
            }
            await for (final evento
                in respuesta.stream
                    .transform(utf8.decoder)
                    .transform(const LineSplitter())
                    .transform(const AnalizadorSse())) {
              if (cancelado) break;
              salida.add(evento);
            }
          } else if (respuesta.statusCode == 401) {
            await respuesta.stream.drain<void>();
            final renovar = renovarSesion;
            if (renovar != null && !cancelado && await renovar()) {
              cliente.close();
              continue;
            }
          } else {
            await respuesta.stream.drain<void>();
          }
        } on Object {
          // Sin red o conexion cortada: se reintenta mas abajo.
        } finally {
          cliente.close();
        }
        if (cancelado) break;
        reconexion = true;
        await _dormir(esperaDeReintento(intento++));
      }
    }

    salida = StreamController<EventoEnVivo>(
      onListen: () => unawaited(ciclo()),
      onCancel: () {
        cancelado = true;
        actual?.close();
      },
    );
    return salida.stream;
  }

  Future<http.StreamedResponse> _abrir(http.Client cliente) async {
    final token = await obtenerToken();
    final peticion = http.Request('GET', config.ruta('/eventos'))
      ..headers.addAll({
        'accept': 'text/event-stream',
        'cache-control': 'no-cache',
        if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
      });
    return cliente.send(peticion);
  }
}
