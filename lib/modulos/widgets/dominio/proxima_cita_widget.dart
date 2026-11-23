/// Contenido del widget de pantalla de inicio con la proxima cita (V2-M25.01).
///
/// Dart puro. Dice que cita se muestra y que texto y enlace viajan al widget
/// nativo; como se entrega al sistema (Android, iOS) vive detras de
/// [PuertoWidgetCita].
library;

import '../../../nucleo/navegacion/enlaces.dart';
import '../../citas/citas.dart' show CitaCliente;

/// Enlace `carecar://` del comprobante de la cita [citaId]: lo que abre el
/// widget al tocarlo. Es la misma ruta `/citas/:id/comprobante` de la app.
String enlaceDeCitaWidget(int citaId) =>
    '${EnlacesApp.esquema}://citas/$citaId/comprobante';

/// Enlace `carecar://` del flujo de agendar: lo que abre el widget sin cita.
const enlaceAgendarWidget = '${EnlacesApp.esquema}://citas/agendar';

/// La cita que el widget muestra: la confirmada que empieza primero y que
/// todavia no ha empezado. `null` si no hay ninguna.
CitaCliente? proximaCita(Iterable<CitaCliente> citas, DateTime ahora) {
  CitaCliente? elegida;
  for (final cita in citas) {
    if (!cita.esProxima(ahora)) continue;
    if (elegida == null || cita.inicio.isBefore(elegida.inicio)) {
      elegida = cita;
    }
  }
  return elegida;
}

/// Lo que se le entrega al widget: textos ya traducidos y el enlace al tocar.
///
/// Solo lleva lo necesario para pintar (dia, horario y nombre del vehiculo):
/// nada del cliente ni el codigo firmado del QR.
class ContenidoWidgetCita {
  const ContenidoWidgetCita.conCita({
    required this.titulo,
    required String this.fecha,
    required String this.horario,
    required int citaId,
    this.vehiculo,
  }) : hayCita = true,
       enlace = '${EnlacesApp.esquema}://citas/$citaId/comprobante',
       mensaje = null,
       accion = null;

  const ContenidoWidgetCita.sinCita({
    required this.titulo,
    required String this.mensaje,
    required String this.accion,
  }) : hayCita = false,
       enlace = enlaceAgendarWidget,
       fecha = null,
       horario = null,
       vehiculo = null;

  final bool hayCita;
  final String titulo;
  final String? fecha;
  final String? horario;
  final String? vehiculo;

  /// Solo sin cita: la invitacion a agendar y el texto de su boton.
  final String? mensaje;
  final String? accion;

  /// Enlace `carecar://` que abre el widget al tocarlo.
  final String enlace;
}

/// Lo que el modulo necesita del sistema para mostrar el widget; el paquete
/// `home_widget` queda detras de esta interfaz para sustituirlo en pruebas.
abstract interface class PuertoWidgetCita {
  /// Guarda [contenido] para el widget y le pide repintarse.
  Future<void> publicar(ContenidoWidgetCita contenido);
}
