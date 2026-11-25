/// Que cita muestra el widget de la proxima cita (V2-M25.01) y los enlaces
/// `carecar://` que abre.
///
/// Dart puro. El contenido de cada widget y como se entrega al sistema viven en
/// `contenido_widgets.dart`.
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
