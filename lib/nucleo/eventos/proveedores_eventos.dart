import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/proveedores_api.dart';
import 'eventos_en_vivo.dart';
import 'eventos_en_vivo_http.dart';

/// Canal de eventos en vivo. Usa la direccion, el token y la renovacion de
/// sesion del cliente HTTP del nucleo. En pruebas:
/// `eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake())`.
final eventosEnVivoProvider = Provider<EventosEnVivo>((ref) {
  final cliente = ref.watch(apiClienteProvider);
  return EventosEnVivoHttp(
    config: cliente.config,
    obtenerToken: () async => cliente.obtenerToken?.call(),
    renovarSesion: cliente.renovarSesion,
  );
}, name: 'eventosEnVivoProvider');

/// Los eventos que van llegando. Es `autoDispose`: la conexion solo esta
/// abierta mientras una pantalla lo escucha y se cierra al salir de ella (o
/// cuando Riverpod la pausa por no estar visible).
final eventosProvider = StreamProvider.autoDispose<EventoEnVivo>(
  (ref) => ref.watch(eventosEnVivoProvider).escuchar(),
  name: 'eventosProvider',
);
