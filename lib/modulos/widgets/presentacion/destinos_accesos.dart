import '../../asistencia/asistencia.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/acceso_rapido.dart';

/// Pantalla a la que lleva cada acceso rapido. Usa las constantes que publican
/// los otros modulos en su contrato, nunca su `presentacion/`.
String rutaDeAcceso(AccesoRapido acceso) => switch (acceso) {
  AccesoRapido.agendar => rutaAgendarCita,
  AccesoRapido.miAuto => rutaGaraje,
  // Hasta que exista la pantalla SOS (V2-M11.01) es la lista de guias.
  AccesoRapido.sos => rutaSos,
};
