import '../../citas/citas.dart' show CitaAgendada, CitaCliente;

/// Los recordatorios locales de una cita, vistos desde el modulo de citas.
///
/// Es la costura que faltaba al migrar a la v2 · V2-M06.06. Los recordatorios
/// ya existian en la v1, pero **todos sus disparadores se quedaron en
/// `lib/pantallas/citas/`**: desde que V2-T01.09 dejo citas en v2, agendar no
/// deja ningun recordatorio.
///
/// Son avisos **locales**, y ahi esta el criterio de la historia: los programa
/// el telefono, no el servidor, asi que suenan sin red. Si dependieran de un
/// push, quien no tiene senal se quedaria sin recordatorio justo cuando mas le
/// sirve.
///
/// El modulo de citas habla con esta interfaz y con sus propios tipos; no se
/// entera de que debajo vive el servicio de la v1.
abstract interface class RecordatoriosDeCita {
  /// Cita recien confirmada por el taller: aviso inmediato y recordatorios.
  ///
  /// Va aparte de [alAgendar] porque [CitaAgendada] no trae estado -esta
  /// confirmada por definicion- ni nombre de vehiculo, que la pantalla si
  /// tiene a mano.
  Future<void> alConfirmar(CitaAgendada cita, {String? vehiculo});

  /// Una cita de la lista: deja sus recordatorios al dia.
  Future<void> alAgendar(CitaCliente cita, {String? vehiculo});

  /// Cita cancelada: se quitan sus recordatorios.
  Future<void> alCancelar(int citaId);

  /// Pone la lista completa al dia: quita los que ya no van y agrega los que
  /// faltan. Es lo que se llama al abrir «Mis citas».
  Future<void> sincronizar(List<CitaCliente> citas);
}
