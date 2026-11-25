/// Un aviso del servidor por el canal de eventos en vivo (`GET /app/eventos`,
/// Server-Sent Events).
class EventoEnVivo {
  const EventoEnVivo(this.nombre, [this.datos = const {}]);

  /// Nombre del evento, por ejemplo `asistencia.estado`.
  final String nombre;

  /// Cuerpo JSON del evento ya leido.
  final Map<String, Object?> datos;

  @override
  String toString() => 'EventoEnVivo($nombre, $datos)';
}

/// Evento propio de la app, no del servidor: se emite cuando el canal se
/// restablece tras una caida. Quien escucha vuelve a consultar su recurso para
/// recuperar lo que pudo perderse mientras no habia conexion.
const eventoReconectado = 'conexion.restablecida';

/// Canal de eventos en vivo del servidor.
///
/// [escuchar] abre la conexion al suscribirse y la cierra al cancelar la
/// suscripcion, asi que solo esta abierta mientras alguna pantalla la
/// escucha. Si la conexion se cae o el servidor la cierra, se reabre sola con
/// esperas crecientes y se emite [eventoReconectado].
abstract interface class EventosEnVivo {
  Stream<EventoEnVivo> escuchar();
}
