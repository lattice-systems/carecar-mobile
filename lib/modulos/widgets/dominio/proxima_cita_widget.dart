/// Contenido del widget de pantalla de inicio: la proxima cita (V2-M25.01) o,
/// si hay una orden abierta, el estado del auto en el taller (V2-M25.02).
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

/// Enlace `carecar://` de la orden [ordenId] en el taller: lo que abre el
/// widget con el auto en el taller. Es la misma ruta `/taller/:id` de la app.
String enlaceDeOrdenWidget(int ordenId) =>
    '${EnlacesApp.esquema}://taller/$ordenId';

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

  /// El auto en el taller. Usa el mismo bloque del widget que la cita: [etapa]
  /// ocupa el lugar del dia, [entrega] el del horario y [vehiculo] el del auto.
  /// Solo viajan textos de pantalla y el id de la orden dentro del enlace.
  const ContenidoWidgetCita.enTaller({
    required this.titulo,
    required String etapa,
    required String this.vehiculo,
    required int ordenId,
    String? entrega,
  }) : hayCita = true,
       fecha = etapa,
       horario = entrega,
       enlace = '${EnlacesApp.esquema}://taller/$ordenId',
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

  /// Si el widget muestra un bloque con datos (cita o auto en el taller) y no la
  /// invitacion a agendar.
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
